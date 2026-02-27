-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc2.sql
-- Objectif: KPIs financiers globaux sur toute la période
-- KPIs    : CA · Coût · Marge brute · Taux marge
--           Volume · Nb commandes · Clients · Panier moyen
--           Nb retours · Taux de retour
-- Formules:
--   Marge brute    = CA - Coût
--   Taux de marge  = (Marge / CA) × 100
--   Panier moyen   = CA / Nb commandes
--   Taux de retour = (Retours / Total articles) × 100
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

WITH cte_hoodies_base AS (
  SELECT
    oi.order_id AS id_commande,
    oi.user_id AS id_client,
    oi.status AS statut_commande,
    oi.sale_price AS prix_vente_unitaire,
    p.cost AS cout_achat_unitaire

  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
  INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id

  WHERE
    p.category = 'Fashion Hoodies & Sweatshirts'
    AND DATE(oi.created_at) BETWEEN date_debut AND date_fin
    AND oi.status != 'Cancelled'
)

SELECT
  -- Volume
  COUNT(*) AS volume_ventes_unites,
  COUNT(DISTINCT id_commande) AS nb_commandes,
  COUNT(DISTINCT id_client) AS nb_clients_actifs,

  -- Financier (hors retours car argent remboursé)
  ROUND(SUM(prix_vente_unitaire), 2) AS chiffre_affaires_brut,
  ROUND(SUM(cout_achat_unitaire), 2) AS cout_total,
  ROUND(SUM(prix_vente_unitaire) - SUM(cout_achat_unitaire), 2) AS marge_brute,

  -- Ratios
  ROUND(
    (SUM(prix_vente_unitaire) - SUM(cout_achat_unitaire))
    / NULLIF(SUM(prix_vente_unitaire), 0) * 100
  , 2) AS taux_marge_pct,
  ROUND(
    SUM(prix_vente_unitaire) / NULLIF(COUNT(DISTINCT id_commande), 0)
  , 2) AS panier_moyen,

  -- Retours
  COUNTIF(statut_commande = 'Returned') AS nb_articles_retournes,
  ROUND(
    COUNTIF(statut_commande = 'Returned')
    / NULLIF(COUNT(*), 0) * 100
  , 2) AS taux_retour_pct

FROM cte_hoodies_base