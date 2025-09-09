# Ficha Técnica – Projeto: Análise de Risco Relativo | Banco Super Caja

**Autora:** Vanessa Campoy Costa  
**Data:** Setembro de 2025  

## Visão Geral

Este documento registra os detalhes técnicos do projeto de análise de risco de crédito do **Banco Super Caja**. O objetivo foi substituir o processo manual de avaliação de crédito por uma abordagem automatizada, baseada em dados e métricas de risco relativo.

Ferramentas utilizadas:

* **Google BigQuery** – manipulação e modelagem de dados (SQL)
* **Looker Studio** – visualização e dashboard
* **Google Apresentações** – apresentação executiva
* (Opcional) **Google Colab** – regressão logística em Python

---

## 2. Estrutura de Dados

**Tabelas originais:**

* `informacoes_clientes` – idade, salário, número de dependentes
* `emprestimos_contratados` – contratos ativos, tipo de empréstimo
* `detalhes_emprestimos` – histórico de pagamentos, índice de endividamento
* `inadimplencia_clientes` – classificação inadimplente

**Views finais consolidadas:**

* **`v_unica`** – base unificada de clientes, já tratada e com variáveis derivadas.
* **`v_analise_cortes`** – cálculo dos scores por cliente, segmentados em diferentes pontos de corte.
* **`v_score_validacao`** – resultados das métricas de performance (acurácia, precisão, recall, F1) e matriz de confusão.

---

## 3. Preparação e Limpeza de Dados

### 3.1 Tratamento de Nulos

* **salario\_mes\_anterior**: mantido como NULL → categorizado como *“desconhecido”*.
* **numero\_dependentes**: substituído NULL → 0.

### 3.2 Duplicados

Não foram encontrados registros duplicados nas tabelas.

### 3.3 Inconsistências Categóricas

* Padronização de texto (`lower(trim())`).

### 3.4 Outliers

* **Idade**: valores > 100 anos mantidos (possíveis clientes válidos).
* **Dependentes**: outliers (até 13) agrupados em categorias.
* **Salário**: alta dispersão (> R\$ 1 milhão), analisado por faixas.

### 3.5 Feature Engineering

Variáveis criadas:

* Faixas de **salário**, **idade**, **endividamento** e **dependentes**
* **Renda per capita**: salário / (dependentes + 1)

---

## 4. Análise Exploratória (EDA)

* Base de **36 mil clientes**.
* **Inadimplência geral: 1,9%**.
* **Média salarial: R\$ 6.668,57** (mediana R\$ 5.400).
* **Média de idade: 52 anos**.

**Padrões encontrados (contexto de inadimplência por segmentos):**

* Jovens (18–29) → inadimplência 3,5% (≈6x idosos).
* Crédito imobiliário → 3,4% (2x outros).
* Endividamento alto (81–100% renda) → 3,1% inadimplência.
* Salário desconhecido → aparente menor risco, mas provavelmente relacionado à ausência de informação.

---

## 5. Risco Relativo

* **Idade jovem**: 5x maior risco que idosos.
* **Imobiliário**: 2x maior risco que “outros”.
* **Endividamento alto**: +63% de risco vs. baixo/médio.
* **Salário desconhecido**: risco menor aparente, mas viés de informação.

---

## 6. Classificação por Score

Foram testados diferentes pontos de corte (2 a 6).

| Corte | Acurácia | Precisão | Recall | F1-Score |
| ----- | -------- | -------- | ------ | -------- |
| 2     | 65,8%    | 2,4%     | 42%    | 4,5%     |
| 3     | 91,1%    | 3,9%     | 16%    | 6,2%     |
| 4     | 96,6%    | 3,9%     | 3%     | 3,6%     |
| 5     | 98,1%    | 12,5%    | 0%     | 0,3%     |

**Escolha recomendada:** Corte 3 → melhor equilíbrio entre acurácia (91%) e recall (16%).

---

## 7. Dashboard

Construído no **Looker Studio** com:

* **Scorecards gerais**: total de clientes, % inadimplentes, % bons pagadores, média de idade, média salarial.
* Gráficos de inadimplência por faixa etária, tipo de empréstimo, salário e endividamento.
* Tabela de cortes do score.
* Matriz de confusão.
* Filtros interativos por segmento.

---

## 8. Conclusões e Recomendações

1. **Estratégia de crédito**: adotar corte 3 como política padrão. 
   Para segmentos com maior risco (ex.: jovens, imobiliário, maior comprometimento da renda), adotar postura **mais conservadora** (limites iniciais menores, maior análise manual). 
   
2. **Otimização operacional**:

   * Aprovação automática para clientes de baixo risco.
   * Políticas específicas para jovens e crédito imobiliário.
3. **Melhoria contínua**:

   * Ampliar coleta de dados de renda (20% da base sem informação).
   * Monitorar e retreinar o modelo a cada 6 meses.

---

## 9. Estrutura do Repositório

```
sql/          # Scripts SQL de ETL, modelagem e score
notebooks/    # (opcional) Regressão logística em Python
dashboard/    # Capturas do painel no Looker Studio
docs/         # Ficha técnica e documentação
presentation/ # Apresentação executiva
```

---

## 10. Próximos Passos

* Aplicar regressão logística para melhorar recall.
* Monitorar métricas do score em produção.
* Expandir variáveis disponíveis para enriquecer o modelo:

  * Histórico de relacionamento com o banco (tempo de cliente, produtos contratados).
  * Variáveis comportamentais (frequência de atrasos, uso de crédito rotativo).
  * Dados socioeconômicos adicionais (região, ocupação, escolaridade).
  * Variáveis externas (indicadores macroeconômicos, mercado de crédito).


### Entregáveis Finais

* **[Clique aqui para ver o Dashboard Interativo no Looker Studio](https://lookerstudio.google.com/reporting/42a5e84c-d7cb-42cf-9cba-6fb903fd1f8e)**

* **[Clique aqui para ver a Apresentação Executiva](https://docs.google.com/presentation/d/1rdD61zwfBs6bMZKtprYMuiPibU-X4Itjh6LFMJtr_hQ/edit?usp=sharing)**

---

Este projeto representa não só uma solução técnica, mas uma forma de pensar dados como ferramenta estratégica. Se quiser ver mais detalhes ou discutir como aplicar algo parecido em outro contexto, estou aberta a conversas.



