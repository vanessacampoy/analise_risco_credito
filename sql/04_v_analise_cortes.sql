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
    CASE WHEN b.score_de_risco < t.corte_score AND b.classe_real = 0 THEN 1 ELSE 0 END AS VN
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
  corte_score