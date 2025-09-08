# Projeto: Análise de Risco de Crédito – Banco Caja

**Autora:** Vanessa Campoy Costa  
**Data:** Setembro de 2025  

## Visão Geral

Este projeto aborda um desafio comum no setor financeiro, usando o Banco Caja como um caso de estudo. O problema central era o aumento no volume de solicitações de crédito, que sobrecarregava a equipe de análise de crédito. A lentidão do processo e o risco de inadimplência exigiam uma solução mais ágil, escalável e baseada em dados.

A proposta foi desenvolver um modelo de análise de risco que substituísse o processo manual por uma abordagem automatizada, capaz de classificar clientes, apoiar decisões de crédito e tornar as políticas internas mais claras e estratégicas.

## Etapas do Projeto

O projeto foi conduzido em etapas bem definidas, que combinam técnicas de engenharia de dados, análise exploratória e visualização:

1. **Entendimento do Problema e Estruturação da Solução**  
   Mapeei os principais gargalos do processo atual e defini os objetivos da solução: agilidade, consistência e suporte à decisão.

2. **ETL e Preparação dos Dados**  
   Nesta etapa, realizei o processo de ETL completo para garantir a qualidade dos dados. Extraí as informações das 4 tabelas de origem e as carreguei no BigQuery. A fase de Transformação envolveu a limpeza da base, com o tratamento de valores nulos e duplicados, substituição de valores divergentes, além da padronização dos campos para garantir a consistência das informações.

3. **Modelagem de Dados e e Criação de Variáveis**  
   Com os dados limpos, iniciei a modelagem para estruturar a base de análise. Realizei uma análise de correlação para selecionar as variáveis de maior impacto no risco de inadimplência. Em seguida, criei novas variáveis para segmentar os clientes e enriquecer a análise. O resultado desta etapa foi a criação de **`views` segmentadas**, cada uma com um propósito analítico:
* **Views de Preparação:** Para consolidar e enriquecer os dados em um nível de cliente.
* **Views de Análise:** Para agregar os resultados e avaliar a performance do score de risco, servindo como os modelos de dados finais para o dashboard.

4. **Análise Exploratória e Identificação de Padrões**  
   Realizei a Análise Exploratória diretamente no BigQuery, utilizando consultas SQL para calcular estatísticas descritivas e investigar a distribuição das variáveis. O objetivo desta etapa foi entender o perfil geral dos clientes, a qualidade dos dados e identificar os primeiros padrões e outliers.

5. **Construção do Score de Risco**  
   Para validar a eficácia do score, testei múltiplos pontos de corte (de 2 a 6) e avaliei a performance de cada cenário com uma matriz de confusão e as métricas de Acurácia, Precisão, Recall e F1-Score.

6. **Dashboard Interativo e Recomendação de Negócio**  
   Para apresentar os resultados da análise e as conclusões do modelo, criei um dashboard interativo no Looker Studio. A ferramenta foi utilizada para visualizar os dados das views finais, permitindo a criação de gráficos, tabelas e filtros interativos para a exploração dos diferentes cenários de risco pela equipe do banco.

## Estrutura do Repositório

- `sql/` → Scripts de ETL, modelagem e score  
- `dashboard/` → Prints e link do painel interativo  
- `documentacao/` → PDFs com documentação técnica e análise de risco  
- `apresentacao/` → Slides com resumo executivo e recomendações  

---

Este projeto representa não só uma solução técnica, mas uma forma de pensar dados como ferramenta estratégica. Se quiser ver mais detalhes ou discutir como aplicar algo parecido em outro contexto, estou aberta a conversas.
