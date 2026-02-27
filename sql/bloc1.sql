-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc1.sql
-- Objectif: Extraction et filtrage des données brutes
--           Socle de toute l'analyse
-- Tables  : order_items + products + users
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

SELECT
  oi.id AS id_ligne_commande,
  oi.order_id AS id_commande,
  oi.user_id AS id_client,
  oi.product_id AS id_produit,
  oi.status AS statut_commande,
  oi.sale_price AS prix_vente_unitaire,
  p.cost AS cout_achat_unitaire,
  p.name AS nom_produit,
  p.category AS categorie_produit,
  p.brand AS marque,
  DATE(oi.created_at) AS date_commande,
  DATE(oi.shipped_at) AS date_expedition,
  DATE(oi.delivered_at) AS date_livraison,
  DATE(oi.returned_at) AS date_retour,
  u.country AS pays_client,
  u.traffic_source AS canal_acquisition

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi

-- INNER JOIN : on garde uniquement les articles avec un produit référencé dans le catalogue
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id

-- INNER JOIN : on garde uniquement les commandes avec un client identifié (pour la géo et le canal)
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id

WHERE
  p.category = 'Fashion Hoodies & Sweatshirts' -- Filtre produit
  AND DATE(oi.created_at) BETWEEN date_debut AND date_fin -- Filtre période
  AND oi.status != 'Cancelled' -- Exclusion des annulées

LIMIT 100