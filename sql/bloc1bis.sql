-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc1bis.sql
-- Objectif: Analyse de la tendance mois par mois
--           Répondre à la question : la tendance est-elle
--           haussière ou baissière sur 2025 ?
-- KPIs    : Volume · CA · Coût · Marge · Retours/mois
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

SELECT
  -- Dimension temporelle
  FORMAT_DATE('%Y-%m', DATE(oi.created_at)) AS mois,
  FORMAT_DATE('%B %Y', DATE(oi.created_at)) AS mois_libelle,

  -- Volume
  COUNT(*) AS volume_ventes,
  COUNT(DISTINCT oi.order_id) AS nb_commandes,

  -- Performance financière
  ROUND(SUM(oi.sale_price), 2) AS chiffre_affaires,
  ROUND(SUM(p.cost), 2) AS cout_total,
  ROUND(SUM(oi.sale_price) - SUM(p.cost), 2) AS marge_brute,
  ROUND(
    (SUM(oi.sale_price) - SUM(p.cost))
    / NULLIF(SUM(oi.sale_price), 0) * 100
  , 2) AS taux_marge_pct,

  -- Retours du mois
  COUNTIF(oi.status = 'Returned') AS nb_retours,
  ROUND(
    COUNTIF(oi.status = 'Returned')
    / NULLIF(COUNT(*), 0) * 100
  , 2) AS taux_retour_pct

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id

WHERE
  p.category = 'Fashion Hoodies & Sweatshirts'
  AND DATE(oi.created_at) BETWEEN date_debut AND date_fin
  AND oi.status != 'Cancelled'

GROUP BY mois, mois_libelle
ORDER BY mois ASC -- pour visualiser la tendance de façon chronologique