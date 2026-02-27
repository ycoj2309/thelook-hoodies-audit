-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc7.sql
-- Objectif: Analyser le tunnel de conversion
-- KPIs    : Sessions totales · Visiteurs · Funnel complet
--           Taux de conversion · Taux abandon panier
--           Taux conversion Hoodies spécifique
-- Formules:
--   Taux conversion = Sessions achat / Total sessions × 100
--   Taux abandon    = (Panier - Achat) / Panier × 100
-- NOTE : Dataset synthétique → taux globaux surévalués
--    Les ratios du funnel restent exploitables
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

WITH

-- Total sessions sur le site
cte_sessions_totales AS (
  SELECT
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT user_id)    AS total_visiteurs
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE DATE(created_at) BETWEEN date_debut AND date_fin
),

-- Funnel : home → product → cart → purchase
cte_funnel AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'home'
      THEN session_id END) AS sessions_page_accueil,
    COUNT(DISTINCT CASE WHEN event_type = 'product'
      THEN session_id END) AS sessions_vue_produit,
    COUNT(DISTINCT CASE WHEN event_type = 'cart'
      THEN session_id END) AS sessions_ajout_panier,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase'
      THEN session_id END) AS sessions_avec_achat
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE DATE(created_at) BETWEEN date_debut AND date_fin
),

-- Acheteurs réels de Hoodies
cte_acheteurs_hoodies AS (
  SELECT
    COUNT(DISTINCT oi.user_id) AS nb_acheteurs_hoodies
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
  WHERE
    p.category = 'Fashion Hoodies & Sweatshirts'
    AND DATE(oi.created_at) BETWEEN date_debut AND date_fin
    AND oi.status NOT IN ('Cancelled', 'Returned')
)

SELECT
  -- Volume global
  st.total_sessions,
  st.total_visiteurs,

  -- Funnel étape par étape
  f.sessions_page_accueil,
  f.sessions_vue_produit,
  f.sessions_ajout_panier,
  f.sessions_avec_achat,

  -- Taux de conversion global
  ROUND(
    f.sessions_avec_achat * 100.0
    / NULLIF(st.total_sessions, 0)
  , 2) AS taux_conversion_global_pct,

  -- Taux panier converti en achat
  ROUND(
    f.sessions_avec_achat * 100.0
    / NULLIF(f.sessions_ajout_panier, 0)
  , 2) AS taux_panier_converti_pct,

  -- Taux d'abandon panier
  ROUND(
    (f.sessions_ajout_panier - f.sessions_avec_achat) * 100.0
    / NULLIF(f.sessions_ajout_panier, 0)
  , 2) AS taux_abandon_panier_pct,

  -- Conversion spécifique Hoodies
  ah.nb_acheteurs_hoodies,
  ROUND(
    ah.nb_acheteurs_hoodies * 100.0
    / NULLIF(st.total_visiteurs, 0)
  , 2) AS taux_conversion_hoodies_pct

FROM cte_sessions_totales AS st
CROSS JOIN cte_funnel AS f
CROSS JOIN cte_acheteurs_hoodies AS ah