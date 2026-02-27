-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc5.sql
-- Objectif: Mesurer la performance logistique
-- KPIs    : Délai moyen expédition · Délai moyen livraison
--           Délai min/max · Taux expédition lente
--           Taux livraison rapide
-- Formule : DATE_DIFF(shipped_at, created_at, DAY)
-- Seuils  : Expédition lente > 3 jours
--           Livraison rapide ≤ 7 jours
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

SELECT
  -- Délais moyens
  ROUND(AVG(
    DATE_DIFF(DATE(oi.shipped_at), DATE(oi.created_at), DAY)
  ), 1) AS delai_moyen_expedition_jours,

  ROUND(AVG(
    DATE_DIFF(DATE(oi.delivered_at), DATE(oi.created_at), DAY)
  ), 1) AS delai_moyen_livraison_jours,

  -- Distribution des délais
  MIN(DATE_DIFF(DATE(oi.shipped_at), DATE(oi.created_at), DAY)) AS delai_min_expedition_jours,
  MAX(DATE_DIFF(DATE(oi.shipped_at), DATE(oi.created_at), DAY)) AS delai_max_expedition_jours,

  -- Commandes en retard (> 3 jours avant expédition)
  COUNTIF(
    DATE_DIFF(DATE(oi.shipped_at), DATE(oi.created_at), DAY) > 3
  ) AS nb_commandes_expedition_lente,

  -- Base de calcul
  COUNT(*) AS nb_commandes_expediees,

  -- Taux de retard logistique
  ROUND(
    COUNTIF(DATE_DIFF(DATE(oi.shipped_at), DATE(oi.created_at), DAY) > 3)
    / NULLIF(COUNT(*), 0) * 100
  , 2) AS taux_expedition_lente_pct,

  -- Taux de livraison rapide (≤ 7 jours)
  ROUND(
    COUNTIF(DATE_DIFF(DATE(oi.delivered_at), DATE(oi.created_at), DAY) <= 7)
    / NULLIF(COUNT(*), 0) * 100
  , 2) AS taux_livraison_rapide_pct

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id

WHERE
  p.category = 'Fashion Hoodies & Sweatshirts'
  AND DATE(oi.created_at) BETWEEN date_debut AND date_fin
  AND oi.status IN ('Shipped', 'Complete', 'Delivered')
  AND oi.shipped_at IS NOT NULL
  AND oi.delivered_at IS NOT NULL