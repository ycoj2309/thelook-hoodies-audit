-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc6.sql
-- Objectif: Cartographier les marchés géographiques
-- KPIs    : Clients · Commandes · CA · Marge
--           Part CA % · Part cumulée % (Pareto)
-- Lecture : part_ca_cumulee_pct → quand elle atteint 80%,
--           on a identifié les marchés clés (loi de Pareto)
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

SELECT
  u.country AS pays,

  -- Volume & Clients
  COUNT(DISTINCT oi.user_id) AS nb_clients,
  COUNT(DISTINCT oi.order_id) AS nb_commandes,
  COUNT(*) AS nb_articles_vendus,

  -- Performance financière
  ROUND(SUM(oi.sale_price), 2) AS chiffre_affaires,
  ROUND(SUM(oi.sale_price) - SUM(p.cost), 2) AS marge_brute,
  ROUND(
    (SUM(oi.sale_price) - SUM(p.cost))
    / NULLIF(SUM(oi.sale_price), 0) * 100
  , 2) AS taux_marge_pct,

  -- Panier moyen par pays
  ROUND(
    SUM(oi.sale_price) / NULLIF(COUNT(DISTINCT oi.order_id), 0)
  , 2) AS panier_moyen,

  -- Part du CA total (OVER = calcul sur tous les pays)
  ROUND(
    SUM(oi.sale_price) * 100
    / SUM(SUM(oi.sale_price)) OVER ()
  , 2) AS part_ca_pct,

  -- Part cumulée → Analyse de Pareto (80/20)
  ROUND(SUM(SUM(oi.sale_price)) OVER (
    ORDER BY SUM(oi.sale_price) DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) * 100 / SUM(SUM(oi.sale_price)) OVER (), 2) AS part_ca_cumulee_pct

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id

WHERE
  p.category = 'Fashion Hoodies & Sweatshirts'
  AND DATE(oi.created_at) BETWEEN date_debut AND date_fin
  AND oi.status NOT IN ('Cancelled', 'Returned')

GROUP BY pays
ORDER BY chiffre_affaires DESC
LIMIT 15