-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc4.sql
-- Objectif: Identifier les canaux marketing les plus performants
-- KPIs    : Clients · Commandes · CA · Marge · Panier moyen
--           Part CA % par canal
-- Source  : users.traffic_source
--           (Search · Organic · Facebook · Email · Display...)
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

SELECT
  u.traffic_source AS canal_acquisition,

  -- Volume
  COUNT(DISTINCT oi.user_id) AS nb_clients_uniques,
  COUNT(DISTINCT oi.order_id) AS nb_commandes,
  COUNT(*) AS nb_articles_vendus,

  -- Performance financière par canal
  ROUND(SUM(oi.sale_price), 2) AS chiffre_affaires,
  ROUND(SUM(oi.sale_price) - SUM(p.cost), 2) AS marge_brute,
  ROUND(
    (SUM(oi.sale_price) - SUM(p.cost))
    / NULLIF(SUM(oi.sale_price), 0) * 100
  , 2) AS taux_marge_pct,

  -- Panier moyen : canal qui génère les clients les plus dépensiers
  ROUND(
    SUM(oi.sale_price) / NULLIF(COUNT(DISTINCT oi.order_id), 0)
  , 2) AS panier_moyen,

  -- Part du CA total par canal (fonction fenêtre OVER)
  ROUND(
    SUM(oi.sale_price) * 100
    / SUM(SUM(oi.sale_price)) OVER ()
  , 2) AS part_ca_pct

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id

WHERE
  p.category = 'Fashion Hoodies & Sweatshirts'
  AND DATE(oi.created_at) BETWEEN date_debut AND date_fin
  AND oi.status NOT IN ('Cancelled', 'Returned')

GROUP BY canal_acquisition
ORDER BY chiffre_affaires DESC