WITH base AS (
  SELECT
    id_usuario,
    CAST(score AS FLOAT64)            AS score,
    CAST(flag_inadimplencia AS INT64) AS flag_inadimplencia,
    CASE
      WHEN CAST(score AS FLOAT64) >= 0.50 THEN "Previsto: Inadimplente"
      ELSE "Previsto: Bom"
    END AS classe_prevista
  FROM `risco-relativo-468223.Analise_de_credito.t_score_credito`
),

-- Agregados globais (para cards)
confusao AS (
  SELECT
    COUNT(DISTINCT id_usuario) AS total,
    SUM(CASE WHEN flag_inadimplencia = 1 AND classe_prevista = "Previsto: Inadimplente" THEN 1 ELSE 0 END) AS VP,
    SUM(CASE WHEN flag_inadimplencia = 0 AND classe_prevista = "Previsto: Bom"          THEN 1 ELSE 0 END) AS VN,
    SUM(CASE WHEN flag_inadimplencia = 0 AND classe_prevista = "Previsto: Inadimplente" THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN flag_inadimplencia = 1 AND classe_prevista = "Previsto: Bom"          THEN 1 ELSE 0 END) AS FN
  FROM base
),

-- Agregados por classe real (para barras empilhadas Acertos x Erros)
por_classe_real AS (
  SELECT
    CASE WHEN flag_inadimplencia = 1 THEN "Real: Inadimplente" ELSE "Real: Bom" END AS classe_real,
    -- Acertos = VP+VN por classe real
    SUM(
      CASE
        WHEN flag_inadimplencia = 1 AND classe_prevista = "Previsto: Inadimplente" THEN 1  -- VP
        WHEN flag_inadimplencia = 0 AND classe_prevista = "Previsto: Bom"          THEN 1  -- VN
        ELSE 0
      END
    ) AS acertos_por_classe,
    -- Erros = FP+FN por classe real
    SUM(
      CASE
        WHEN flag_inadimplencia = 1 AND classe_prevista = "Previsto: Bom"          THEN 1  -- FN
        WHEN flag_inadimplencia = 0 AND classe_prevista = "Previsto: Inadimplente" THEN 1  -- FP
        ELSE 0
      END
    ) AS erros_por_classe,
    COUNT(*) AS total_classe
  FROM base
  GROUP BY 1
)

SELECT
  -- nível linha-a-linha (útil para matriz 2x2 com COUNT_DISTINCT)
  b.id_usuario,
  b.score,
  b.flag_inadimplencia,
  b.classe_prevista,

  -- agregados globais (replicados para facilitar os cards no Looker)
  c.total,
  c.VP, c.VN, c.FP, c.FN,
  SAFE_DIVIDE(c.VP + c.VN, c.total) AS acuracia,
  SAFE_DIVIDE(c.VP, c.VP + c.FP)    AS precisao,
  SAFE_DIVIDE(c.VP, c.VP + c.FN)    AS recall,
  SAFE_DIVIDE(2 * c.VP, (2 * c.VP) + c.FP + c.FN) AS f1,

  -- agregados por classe real (para barras empilhadas)
  p.classe_real,
  p.acertos_por_classe,
  p.erros_por_classe,
  p.total_classe

FROM base b
CROSS JOIN confusao c
LEFT JOIN por_classe_real p
  ON p.classe_real = CASE WHEN b.flag_inadimplencia = 1 THEN "Real: Inadimplente" ELSE "Real: Bom" END