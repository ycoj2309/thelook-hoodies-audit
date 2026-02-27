# thelook-hoodies-audit
Atelier : Audit performance Fashion Hoodies - BigQuery SQL
# Atelier CTE E-Commerce — Fashion Hoodies & Sweatshirts
### TheLook Ecommerce | BigQuery | Période : Janvier 2025 à AUJ (Février 2026)

![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)
![School](https://img.shields.io/badge/Eugenia_School-2026-purple?style=for-the-badge)

---

## Problématique Métier

> **Comment évaluer la performance macro des Fashion Hoodies & Sweatshirts
> sur le marché e-commerce TheLook entre janvier 2025 et aujourd'hui ?**

Dans un contexte de forte croissance du marché du streetwear,
l'entreprise TheLook souhaite auditer la performance de sa catégorie
**Fashion Hoodies & Sweatshirts** sur 10 axes clés :
rentabilité, volumes, stocks, acquisition, logistique et conversion.

---

## Objectifs de l'Analyse

| # | KPI | Objectif |
|---|---|---|
| 1 | Chiffre d'affaires | Mesurer le revenu généré |
| 2 | Coût & Marge brute | Évaluer la rentabilité |
| 3 | Taux de marge | Efficacité financière |
| 4 | Volume des ventes | Dynamique commerciale |
| 5 | Taux de retours | Qualité produit & satisfaction |
| 6 | Rotation des stocks | Efficacité gestion des stocks |
| 7 | Top canaux d'acquisition | Performance marketing |
| 8 | Délai d'expédition | Performance logistique |
| 9 | Répartition géographique | Présence marché |
| 10 | Taux de conversion | Efficacité du tunnel de vente |

---

## Dataset & Sources

```
Source      : bigquery-public-data.thelook_ecommerce
Tables      : order_items · products · users · events · inventory_items
Filtre      : category = 'Fashion Hoodies & Sweatshirts'
Période     : 2025-01-01 → CURRENT_DATE() (2026-02-27)
Produits    : 1 866 références cataloguées
```

---

## Architecture SQL — Structure des CTEs

L'analyse est construite de manière **modulaire** avec une approche
bloc par bloc, chaque CTE ayant un objectif métier précis.

```
DECLARE date_debut / date_fin          ← Paramètres centralisés
│
├── BLOC 1   : Base de données          → Socle filtré (jointures INNER)
├── BLOC 1B  : Tendance mensuelle       → FORMAT_DATE + GROUP BY mois
├── BLOC 2   : Performance commerciale  → SUM, COUNT, ratios financiers
├── BLOC 3   : Stock & Rotation         → Snapshot dernier jour (règle clé)
├── BLOC 4   : Canaux d'acquisition     → GROUP BY traffic_source
├── BLOC 5   : Délai d'expédition       → DATE_DIFF + COUNTIF
├── BLOC 6   : Répartition géo          → SUM OVER() fenêtrage Pareto
└── BLOC 7   : Taux de conversion       → Funnel events (home→cart→purchase)
```

### Justification des JOIN

| JOIN | Tables | Raison |
|---|---|---|
| `INNER JOIN` | order_items ↔ products | On veut uniquement les items avec un produit catalogué |
| `INNER JOIN` | order_items ↔ users | On veut uniquement les commandes avec un client identifié |
| `CROSS JOIN` | CTEs agrégées | Chaque CTE retourne 1 ligne → assemblage en vue synthétique |

### Formules clés

$$\text{Taux de Marge} = \frac{\text{CA} - \text{Coût}}{\text{CA}} \times 100$$

$$\text{Rotation des Stocks} = \frac{\text{CA}}{\text{Valeur Stock (dernier jour)}}$$

$$\text{Taux de Conversion} = \frac{\text{Sessions avec achat}}{\text{Total sessions}} \times 100$$

> **Règle stocks** : On prend la valeur du **dernier jour** de la période
> (snapshot), et non la somme des mouvements — pour avoir une image
> réelle du stock disponible.

---

## Résultats & Insights

### Performance Commerciale

| KPI | Valeur |
|---|---|
| **Chiffre d'affaires brut** | **254 435 €** |
| **Coût total (COGS)** | **132 164 €** |
| **Marge brute** | **122 270 €** |
| **Taux de marge** | **48%**  |
| **Volume vendu** | **4 657 unités** |
| **Nb commandes** | **4 551** |
| **Clients actifs** | **4 434** |
| **Panier moyen** | **55.91 €** |

> **Insight** : Avec un taux de marge à **48%**, la catégorie est
> financièrement très saine (norme textile e-commerce : 40-60%).
> Chaque euro de CA génère **0,48€ de marge nette de coûts d'achat**.

---

### Tendance Mensuelle

| Période | Volume | CA |
|---|---|---|
| Janvier 2025 | 206 unités | 11 664 € |
| Juillet 2025 | 291 unités | 16 343 € |
| Octobre 2025 | 345 unités | 18 863 € |
| **Croissance** | **+67%** | **+62%** |

> **Insight** : Tendance **fortement haussière** sur toute la période.
> Légère saisonnalité estivale (baisses en juin et août),
> forte accélération en **automne** (Sep-Oct) — logique pour des hoodies. 

---

### Stocks & Rotation — Point critique

| KPI | Valeur | Benchmark |
|---|---|---|
| **Unités en stock** | 19 950 | — |
| **Valeur stock** | **564 122 €** | — |
| **Rotation stocks** | **0.40** | Idéal : 3-6 |
| **Jours de stock restants** | **~1 051 jours** | Idéal : 30-90j |

> **ALERTE CRITIQUE** : La valeur du stock (**564k€**) représente
> **2.5× le CA généré** sur la période. Avec une rotation à **0.40**,
> le stock n'a pas fait un demi-tour en 14 mois.
> À ce rythme, il faudrait **~3 ans** pour écouler le stock actuel.
> C'est le **risque n°1** identifié dans cet audit.

---

### Top Canaux d'Acquisition

| Canal | Clients | CA | Part CA | Panier Moyen |
|---|---|---|---|---|
| 1 **Search** | 2 767 | 156 136 € | **69.1%** | 55.07 € |
| 2 **Organic** | 582 | 34 652 € | 15.3% | 58.04 € |
| 3 **Facebook** | 238 | 15 071 € | 6.7% | **61.77 €** |
| 4️ **Email** | 190 | 11 441 € | 5.1% | 59.59 € |

> **Insight 1** : **Search concentre 69% du CA** → dépendance critique.
> Une hausse des CPC ou un changement d'algorithme Google peut
> faire effondrer le CA du jour au lendemain.
>
> **Insight 2** : **Facebook génère le meilleur panier moyen** (61.77€)
> malgré un faible volume → canal sous-exploité à très fort potentiel.

---

### Performance Logistique

| KPI | Valeur | Benchmark | Statut |
|---|---|---|---|
| **Délai moyen expédition** | **0.6 jours** | ≤ 2 jours | Excellent |
| **Délai moyen livraison** | **3.1 jours** | ≤ 7 jours | Excellent |
| **Taux expédition lente (>3j)** | **0.07%** | < 10% | Quasi zéro |

> **Insight** : La logistique est un **avantage compétitif fort**.
> Expédition le jour même (0.6j) et livraison en 3 jours = expérience
> client premium qui réduit les retours et favorise les avis positifs.
>
> **Anomalie data** : Quelques délais négatifs détectés
> (shipped_at < created_at) — artefact du dataset synthétique TheLook.

---

### Répartition Géographique

| Rang | Pays | Clients | CA | Part CA |
|---|---|---|---|---|
| 1 | **China** | 1 325 | 75 498 € | **33.4%** |
| 2 | **United States** | 868 | 47 952 € | **21.2%** |
| 3 | **Brasil** | 625 | 35 295 € | **15.6%** |
| 4️ | **South Korea** | 231 | 14 237 € | **6.3%** |
| - | **9 autres pays** | — | ~52 932 € | **23.5%** |

> **Insight** : Le Top 3 pays (Chine, USA, Brésil) concentre **70.2%**
> du CA. La Chine domine largement avec 33.4% — marché prioritaire
> pour toute stratégie de croissance.

---

### Taux de Conversion — Funnel

```
43 731 visiteurs
    ↓
41 072 sessions accueil    (24.7%)
    ↓
166 363 vues produit        (99.9%)
    ↓
 125 748 ajouts panier       (75.5%)
    ↓
  84 391 achats               (67.1% des paniers)
```

| KPI | Valeur |
|---|---|
| **Taux abandon panier** | **32.89%** |
| **Taux conversion Hoodies** | **~10.1%** |

> **Note méthodologique** : Le taux de conversion global (50.68%)
> est surévalué en raison de la nature **synthétique** du dataset TheLook.
> Les ratios du funnel (abandon panier 32.89%) restent exploitables.

---

## Recommandations Stratégiques

### PRIORITÉ 1 — Réduire le sur-stockage (Impact : fort)
> **Problème** : 564k€ immobilisés, rotation à 0.40, ~3 ans de stock.
>
> **Actions** :
> - Lancer des **promotions ciblées** sur les modèles les plus anciens
> - Mettre en place des **ventes flash** en période creuse (juin/août)
> - **Revoir la politique d'achat** : réduire les volumes commandés
>   de 50% jusqu'au retour à une rotation > 2

### PRIORITÉ 2 — Diversifier les canaux d'acquisition (Impact : moyen)
> **Problème** : 69% du CA dépend de Search → risque systémique.
>
> **Actions** :
> - **Scaler Facebook Ads** : meilleur panier moyen (61.77€),
>   augmenter le budget de 30%
> - **Activer l'Email marketing** : canal pas cher, bon panier (59.59€),
>   séquences de relance automatisées
> - **Développer l'Organic** : investir dans le SEO contenu
>   (guides styling hoodies, lookbooks)

### PRIORITÉ 3 — Capitaliser sur la saisonnalité (Impact : rapide)
> **Problème** : Creux en juin/août, pic en automne non anticipé.
>
> **Actions** :
> - **Préparer des campagnes automne** dès août (précommandes,
>   early access) pour surfer sur la saisonnalité Sep-Oct
> - **Offres estivales** en juin/août pour lisser la saisonnalité
>   et réduire le stock dormant simultanément

### PRIORITÉ 4 — Activer la rétention client (Impact : moyen terme)
> **Problème** : 97.4% des clients n'achètent qu'une seule fois.
>
> **Actions** :
> - Programme de **fidélité** avec réductions sur 2ème achat
> - **Email de réengagement** à J+30 après l'achat
> - **Bundle produits** : hoodie + accessoire pour augmenter
>   le panier moyen (actuellement 55.91€)

---

## Stack Technique

```
Langage    : SQL (BigQuery Standard SQL)
Dataset    : bigquery-public-data.thelook_ecommerce
Techniques : CTEs, Window Functions, DATE_DIFF,
             FORMAT_DATE, COUNTIF, NULLIF
Dashboard  : Looker Studio (à venir)
```

---

## Structure du Repository

```
thelook-hoodies-audit/
├── README.md
├── sql/
│   ├── bloc1_base.sql
│   ├── bloc1b_tendance_mensuelle.sql
│   ├── bloc2_performance_ca.sql
│   ├── bloc3_stocks_rotation.sql
│   ├── bloc4_canaux_acquisition.sql
│   ├── bloc5_expedition.sql
│   ├── bloc6_geo.sql
│   └── bloc7_conversion.sql
├── results/
│   └── (exports CSV des résultats BigQuery)
└── dashboard/
    └── (captures Looker Studio)
```

---
## 📊 Dashboard Interactif

> 🔗 **[Voir le Dashboard Live sur Looker Studio →](COLLE_TON_LIEN_ICI)**

---

### Page 1 — Tendance Mensuelle
![Tendance Mensuelle](dashboard/page1_tendance.png)
> 📈 Croissance de +67% du volume entre Jan et Oct 2025

---

### Page 2 — KPIs Globaux
![KPIs Globaux](dashboard/page2_kpis_globaux.png)
> 💰 CA : 258k€ | Marge : 48% | Panier moyen : 55.49€

---

### Page 3 — Canaux & Géographie
![Canaux et Géographie](dashboard/page3_canaux_geo.png)
> 🌍 Chine #1 (33%) | Search domine à 69% du CA

---

### Page 4 — Stocks & Logistique
![Stocks et Logistique](dashboard/page4_stocks_logistique.png)
> ⚠️ Stock critique : 571k€ immobilisés | Rotation 0.40



## Auteurs

Projet réalisé dans le cadre de la formation **AI Applied to Business — Eugenia School**
Promotion 2026 | Atelier BigQuery 

