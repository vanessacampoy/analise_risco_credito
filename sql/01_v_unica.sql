WITH base AS (
  SELECT *
  FROM `risco-relativo-468223.Analise_de_credito.v_unica`
),

-- 2) Empréstimos canonizados (grão: empréstimo)
emprestimos AS (
  SELECT
    COALESCE(e.id_usuario, e.id_usuario)         AS id_usuario,
    CASE
      WHEN e.tipo_emprestimo IS NULL OR TRIM(e.tipo_emprestimo) = '' THEN 'Não informado'
      WHEN REGEXP_CONTAINS(LOWER(TRIM(e.tipo_emprestimo)), r'^real\s*estate$') THEN 'Imobiliário'
      WHEN REGEXP_CONTAINS(LOWER(TRIM(e.tipo_emprestimo)), r'^others?$') THEN 'Outro'
      ELSE 'Outro'
    END                                       AS tipo_emprestimo_pt,
    COALESCE(e.id_emprestimo, e.id_emprestimo)      AS id_emprestimo
  FROM `risco-relativo-468223.Analise_de_credito_arquivo.t_emprestimos_contratados` e
),

-- 3) Totais emprestimos
agg_tipo AS (
  SELECT
    tipo_emprestimo_pt,
    COUNT(DISTINCT id_emprestimo) AS total_emprestimos_tipo
  FROM emprestimos
  GROUP BY 1
),
agg_total AS (
  SELECT COUNT(DISTINCT id_emprestimo) AS total_emprestimos_geral
  FROM emprestimos
),

-- 4) Contagens por cliente
por_cliente_total AS (
  SELECT id_usuario, COUNT(DISTINCT id_emprestimo) AS total_emprestimos_cliente
  FROM emprestimos
  GROUP BY 1
),
por_cliente_tipo AS (
  SELECT id_usuario, tipo_emprestimo_pt, COUNT(DISTINCT id_emprestimo) AS qtd_emprestimos_cliente_tipo
  FROM emprestimos
  GROUP BY 1,2
)

-- 5) Resultado final
SELECT
  b.*,
  pct.qtd_emprestimos_cliente_tipo,                   -- empréstimos do cliente
  pctt.total_emprestimos_cliente,                     -- total de empréstimos do cliente
  atp.total_emprestimos_tipo,                         -- TOTAL por tipo (usar MAX no Looker)
  agt.total_emprestimos_geral                         -- TOTAL geral (usar MAX no Looker)
FROM base b
LEFT JOIN por_cliente_total pctt
  ON b.id_usuario = pctt.id_usuario
LEFT JOIN por_cliente_tipo  pct
  ON b.id_usuario = pct.id_usuario
 AND COALESCE(b.tipo_emprestimo_pt,'Não informado') = pct.tipo_emprestimo_pt
LEFT JOIN agg_tipo atp
  ON COALESCE(b.tipo_emprestimo_pt,'Não informado') = atp.tipo_emprestimo_pt
CROSS JOIN agg_total agt