-- ================================================================
-- THELOOK ECOMMERCE — Fashion Hoodies & Sweatshirts
-- Auteur  : [Jahdiel Kinvi] — Eugenia School 2026
-- Fichier : bloc3.sql
-- Objectif: Évaluer l'efficacité de la gestion des stocks
-- KPIs    : Unités en stock · Valeur stock · Rotation
--           Jours de stock restants
-- RÈGLE CLÉ : On prend la valeur du DERNIER JOUR de la période (snapshot), pas la somme des mouvements
-- Formules:
--   Rotation = CA / Valeur stock (dernier jour)
--   Jours restants = Valeur stock / (CA / nb jours période)
-- ================================================================

DECLARE date_debut DATE DEFAULT '2025-01-01';
DECLARE date_fin   DATE DEFAULT CURRENT_DATE();

WITH

-- Stock disponible au dernier jour de la période
-- Article "en stock" = entré avant date_fin ET pas encore vendu
cte_stock_snapshot AS (
  SELECT
    COUNT(*) AS unites_en_stock,
    ROUND(SUM(inv.cost), 2) AS valeur_stock_euros,
    ROUND(AVG(inv.cost), 2) AS cout_unitaire_moyen_stock

  FROM `bigquery-public-data.thelook_ecommerce.inventory_items` inv

  WHERE
    inv.product_category = 'Fashion Hoodies & Sweatshirts'
    AND DATE(inv.created_at) <= date_fin    -- Entré avant la fin de période
    AND (
      inv.sold_at IS NULL                   -- Pas encore vendu
      OR DATE(inv.sold_at) > date_fin       -- Vendu après notre période
    )
),

-- CA de référence pour calculer la rotation
cte_ca_reference AS (
  SELECT
    ROUND(SUM(oi.sale_price), 2) AS chiffre_affaires_brut,
    ROUND(SUM(p.cost), 2) AS cout_marchandises_vendues

  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id

  WHERE
    p.category = 'Fashion Hoodies & Sweatshirts'
    AND DATE(oi.created_at) BETWEEN date_debut AND date_fin
    AND oi.status NOT IN ('Cancelled', 'Returned')
)

SELECT
  -- État du stock au dernier jour
  stk.unites_en_stock,
  stk.valeur_stock_euros,
  stk.cout_unitaire_moyen_stock,

  -- Référence financière
  ca.chiffre_affaires_brut,
  ca.cout_marchandises_vendues,

  -- Rotation : combien de fois le stock a été "vendu"
  ROUND(
    ca.chiffre_affaires_brut / NULLIF(stk.valeur_stock_euros, 0)
  , 2) AS rotation_stocks_ca,

  -- Rotation méthode comptable (COGS / Stock)
  ROUND(
    ca.cout_marchandises_vendues / NULLIF(stk.valeur_stock_euros, 0)
  , 2) AS rotation_stocks_cogs,

  -- Jours de stock restants avant rupture théorique
  ROUND(
    stk.valeur_stock_euros
    / NULLIF(ca.chiffre_affaires_brut / DATE_DIFF(date_fin, date_debut, DAY), 0)
  , 0) AS jours_de_stock_restants

FROM cte_stock_snapshot stk
CROSS JOIN cte_ca_reference ca