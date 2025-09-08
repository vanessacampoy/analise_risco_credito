Ficha Técnica do Projeto: Análise de Risco de Crédito – Banco Caja
Desenvolvido por: Vanessa Campoy Costa
Data: Setembro de 2025

1. Resumo do Projeto
1.1. Contexto de Negócio
O Banco Caja enfrentava um desafio operacional significativo: um aumento no volume de solicitações de crédito sobrecarregou a equipe, que realizava as análises de forma manual. Esse processo lento e a crescente preocupação com a inadimplência exigiam uma solução que trouxesse mais agilidade e segurança para o banco.

1.2. Meu Objetivo
Meu objetivo com este projeto foi substituir o processo manual por uma solução baseada em dados. Para isso, propus a criação de um score de risco e um dashboard interativo para classificar clientes, automatizar aprovações de baixo risco e permitir que a equipe de crédito definisse suas políticas de forma mais clara e informada.

1.3. Ferramentas Utilizadas
Banco de Dados: Google BigQuery

Linguagem: SQL

Visualização de Dados: Looker Studio

2. Dicionário de Dados
Para este projeto, utilizei 4 tabelas principais que continham os dados de 36.000 clientes do Banco Caja:

Tabela Original	Meu Nome	Descrição
user_info	t_informacoes_clientes	Dados demográficos dos clientes (idade, salário, dependentes).
default	t_inadimplencia_clientes	flag_inadimplencia, indicando se um cliente já foi inadimplente.
loans_detail	t_detalhes_emprestimos	Comportamento financeiro (índice de endividamento, histórico de atrasos).
loans_outstanding	t_emprestimos_contratados	Detalhes de cada contrato de empréstimo, como o tipo.

Exportar para as Planilhas
3. Metodologia da Análise
Conduzi a análise seguindo um processo estruturado, passo a passo:

1. Carga e Estruturação Inicial dos Dados
Iniciei o projeto importando as 4 tabelas de origem para o Google BigQuery e as renomeei para nomes em português para facilitar a análise.

2. Limpeza e Tratamento dos Dados
Realizei uma verificação completa de dados nulos, substituindo os valores ausentes em numero_dependentes por 0. Verifiquei todas as tabelas em busca de registros duplicados e confirmei que não havia nenhum. Por fim, padronizei as colunas de texto, como tipo_emprestimo, para garantir a consistência dos dados.

3. Análise Exploratória e Engenharia de Features
Utilizei o Looker Studio para fazer uma análise exploratória e entender a distribuição de variáveis como idade e salario_mes_anterior, o que me permitiu identificar outliers. Para aprofundar a análise, criei novas colunas (features) para segmentar os clientes, como faixa_etaria.

4. Análise de Correlação e Seleção de Variáveis
Para evitar redundância de informações no modelo, realizei uma análise de correlação (CORR()) entre as variáveis de dias de atraso. A variável mais_90_dias_atraso foi a selecionada, pois apresentou a maior correlação com a inadimplência (0.307).

5. Construção do Score de Risco
Com base nos perfis de risco que identifiquei, construí um scorecard para gerar o score_de_risco de cada cliente. A lógica que utilizei para pontuar o risco foi a seguinte:

SQL

(
  CASE WHEN faixa_etaria = '18-29' THEN 2 ELSE 0 END +
  CASE WHEN faixa_etaria = '30-44' THEN 1 ELSE 0 END +
  CASE WHEN indice_endividamento > 0.8 THEN 2 ELSE 0 END +
  CASE WHEN numero_dependentes >= 3 THEN 1 ELSE 0 END
) AS score_de_risco
6. Validação do Modelo de Score
Para validar a eficácia do score, testei múltiplos pontos de corte (de 2 a 6). Avaliei a performance de cada cenário com uma matriz de confusão e as métricas de Acurácia, Precisão, Recall e F1-Score, o que me permitiu identificar a estratégia com o melhor equilíbrio entre a captura de risco e a eficiência operacional.

4. Script SQL Principal
Abaixo está o código SQL completo da view final (v_analise_cortes) que consolida toda a análise e serve como a única fonte de dados para o dashboard.

SQL

CREATE OR REPLACE VIEW `risco-relativo-468223.Analise_de_credito_arquivo.v_analise_cortes` AS

WITH
-- ETAPA 1: PREPARAÇÃO COMPLETA DOS DADOS
info AS (
  SELECT id_usuario, idade, salario_mes_anterior, COALESCE(numero_dependentes, 0) AS numero_dependentes
  FROM `risco-relativo-468223.Analise_de_credito_arquivo.t_informacoes_clientes`
),
inad AS (
  SELECT id_usuario, MAX(flag_inadimplencia) AS flag_inadimplencia
  FROM `risco-relativo-468223.Analise_de_credito_arquivo.t_inadimplencia_clientes`
  GROUP BY id_usuario
),
det AS (
  SELECT id_usuario, AVG(indice_endividamento) AS indice_endividamento
  FROM `risco-relativo-468223.Analise_de_credito_arquivo.t_detalhes_emprestimos`
  GROUP BY id_usuario
),
base_com_features AS (
  SELECT
    i.id_usuario,
    i.idade,
    i.salario_mes_anterior,
    i.numero_dependentes,
    det.indice_endividamento,
    COALESCE(inad.flag_inadimplencia, 0) AS classe_real,
    CASE
      WHEN i.idade BETWEEN 18 AND 29 THEN '18-29'
      WHEN i.idade BETWEEN 30 AND 44 THEN '30-44'
      WHEN i.idade BETWEEN 45 AND 59 THEN '45-59'
      WHEN i.idade >= 60 THEN '60+'
      ELSE 'Não informado'
    END AS faixa_etaria
  FROM info i
  LEFT JOIN det ON i.id_usuario = det.id_usuario
  LEFT JOIN inad ON i.id_usuario = inad.id_usuario
),
-- ETAPA 2: CÁLCULO DO SCORE DE RISCO
base_com_score AS (
  SELECT
    id_usuario,
    classe_real,
    (
      CASE WHEN faixa_etaria = '18-29' THEN 2 ELSE 0 END +
      CASE WHEN faixa_etaria = '30-44' THEN 1 ELSE 0 END +
      CASE WHEN indice_endividamento > 0.8 THEN 2 ELSE 0 END +
      CASE WHEN numero_dependentes >= 3 THEN 1 ELSE 0 END
    ) AS score_de_risco
  FROM base_com_features
),
-- ETAPA 3: ANÁLISE DE PERFORMANCE PARA CADA CORTE
cortes_para_teste AS (
  SELECT 2 AS corte_score UNION ALL
  SELECT 3 AS corte_score UNION ALL
  SELECT 4 AS corte_score UNION ALL
  SELECT 5 AS corte_score UNION ALL
  SELECT 6 AS corte_score
),
classificacao_expandida AS (
  SELECT
    t.corte_score,
    CASE WHEN b.score_de_risco >= t.corte_score AND b.classe_real = 1 THEN 1 ELSE 0 END AS VP,
    CASE WHEN b.score_de_risco >= t.corte_score AND b.classe_real = 0 THEN 1 ELSE 0 END AS FP,
    CASE WHEN b.score_de_risco < t.corte_score AND b.classe_real = 1 THEN 1 ELSE 0 END AS FN,
    CASE WHEN b.score_de_risco < t.c_score AND b.classe_real = 0 THEN 1 ELSE 0 END AS VN
  FROM
    base_com_score AS b
  CROSS JOIN
    cortes_para_teste AS t
),
metricas_agregadas AS (
  SELECT
    corte_score,
    SUM(VP) AS VP,
    SUM(FP) AS FP,
    SUM(FN) AS FN,
    SUM(VN) AS VN
  FROM
    classificacao_expandida
  GROUP BY
    corte_score
)
-- Seleção final com todos os resultados calculados
SELECT
  corte_score,
  VN AS Verdadeiros_Negativos,
  FP AS Falsos_Positivos,
  FN AS Falsos_Negativos,
  VP AS Verdadeiros_Positivos,
  (VP + FP + FN + VN) AS total,
  SAFE_DIVIDE(VP + VN, VP + FP + FN + VN) AS Acuracia,
  SAFE_DIVIDE(VP, VP + FP) AS Precisao,
  SAFE_DIVIDE(VP, VP + FN) AS Recall,
  SAFE_DIVIDE(2 * (SAFE_DIVIDE(VP, VP + FP) * SAFE_DIVIDE(VP, VP + FN)), (SAFE_DIVIDE(VP, VP + FP) + SAFE_DIVIDE(VP, VP + FN))) AS F1
FROM
  metricas_agregadas
ORDER BY
  corte_score;
5. Entregáveis Finais
Dashboard Interativo no Looker Studio:
https://lookerstudio.google.com/reporting/42a5e84c-d7cb-42cf-9cba-6fb903fd1f8e

Apresentação do Projeto:
https://docs.google.com/presentation/d/1rdD61zwfBs6bMZKtprYMuiPibU-X4Itjh6LFMJtr_hQ/edit?usp=sharing

