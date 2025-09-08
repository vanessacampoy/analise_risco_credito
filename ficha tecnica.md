# Ficha Técnica do Projeto: Análise de Risco de Crédito – Banco Caja

**Desenvolvido por:** Vanessa Campoy Costa
**Data:** Setembro de 2025

---

## 1. Resumo do Projeto

#### 1.1. Contexto de Negócio
O Banco Caja enfrentava um desafio operacional significativo: um aumento no volume de solicitações de crédito sobrecarregou a equipe, que realizava as análises de forma manual. Esse processo lento e a crescente preocupação com a inadimplência exigiam uma solução que trouxesse mais agilidade e segurança para o banco.

#### 1.2. Meu Objetivo
Meu objetivo com este projeto foi substituir o processo manual por uma solução baseada em dados. Para isso, propus a criação de um score de risco e um dashboard interativo para classificar clientes, automatizar aprovações de baixo risco e permitir que a equipe de crédito definisse suas políticas de forma mais clara e informada.

#### 1.3. Ferramentas Utilizadas
* **Banco de Dados:** Google BigQuery
* **Linguagem:** SQL
* **Visualização de Dados:** Looker Studio

---

## 2. Dicionário de Dados
Para este projeto, utilizei 4 tabelas principais que continham os dados de 36.000 clientes do Banco Caja:

| Tabela Original | Meu Nome | Descrição |
| :--- | :--- | :--- |
| `user_info` | `t_informacoes_clientes` | Dados demográficos dos clientes (idade, salário, dependentes). |
| `default` | `t_inadimplencia_clientes` | `flag_inadimplencia`, indicando se um cliente já foi inadplente. |
| `loans_detail` | `t_detalhes_emprestimos`| Comportamento financeiro (índice de endividamento, histórico de atrasos). |
| `loans_outstanding`| `t_emprestimos_contratados`| Detalhes de cada contrato de empréstimo, como o tipo. |

---

## 3. Metodologia da Análise
Conduzi a análise seguindo um processo estruturado, que descrevo nos passos abaixo:

**1. Carga e Estruturação Inicial dos Dados**
Iniciei o projeto importando as 4 tabelas de origem para o Google BigQuery. Para facilitar a análise e a clareza do projeto, renomeei as tabelas para nomes em português.

**2. Tratamento de Valores Nulos**
Realizei uma verificação de dados nulos em todas as tabelas. A análise apontou valores ausentes nas colunas `numero_dependentes` e `salario_mes_anterior`. Decidi substituir os nulos de `numero_dependentes` por 0, e manter os de `salario_mes_anterior` como nulos para uma categorização posterior como "Desconhecido".

**3. Verificação de Registros Duplicados**
Verifiquei todas as tabelas em busca de registros duplicados em chaves primárias (como `id_usuario` e `id_emprestimo`) e confirmei que não havia nenhuma duplicata.

**4. Análise de Correlação e Seleção de Variáveis**
Para evitar redundância de informações no modelo, realizei uma análise de correlação (`CORR()`) entre as variáveis de dias de atraso. A variável `mais_90_dias_atraso` foi a selecionada para o modelo, pois apresentou a maior correlação com a inadimplência (0.307).

**5. Análise e Tratamento de Outliers e Inconsistências**
Utilizei o Looker Studio e o Excel para fazer uma análise exploratória e entender a distribuição de variáveis como `idade` e `salario_mes_anterior`, o que me permitiu identificar outliers. Também padronizei as colunas de texto, como `tipo_emprestimo`, para garantir a consistência dos dados, agrupando valores como "other" e "others".

**6. Engenharia de Features e Unificação da Base**
Criei novas colunas (`features`) para segmentar os clientes, como `faixa_etaria` e `faixa_salario`. Ao final desta etapa, unifiquei todas as tabelas tratadas e as novas features em uma `view` base no BigQuery, com um registro único por cliente, pronta para a modelagem.

**7. Construção do Score de Risco**
Com base nos perfis de risco que identifiquei na Análise de Risco Relativo, construí um scorecard para gerar o `score_de_risco` de cada cliente. A lógica que utilizei para pontuar o risco foi:
```sql
(
  CASE WHEN faixa_etaria = '18-29' THEN 2 ELSE 0 END +
  CASE WHEN faixa_etaria = '30-44' THEN 1 ELSE 0 END +
  CASE WHEN indice_endividamento > 0.8 THEN 2 ELSE 0 END +
  CASE WHEN numero_dependentes >= 3 THEN 1 ELSE 0 END
) AS score_de_risco
