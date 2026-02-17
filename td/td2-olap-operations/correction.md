# Correction TD2 — Opérations OLAP

## 1. Requêtes SQL attendues (exemples)

- **CA mensuel par produit et magasin (ROLLUP jour→mois)**

```sql
SELECT
  DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1) AS mois,
  p.produit_nom,
  m.magasin_id,
  SUM(f.montant) AS ca_mensuel
FROM fact_ventes f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_produit p ON f.produit_sk = p.produit_sk
JOIN dim_magasin m ON f.magasin_sk = m.magasin_sk
GROUP BY ROLLUP (DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1), p.produit_nom, m.magasin_id)
ORDER BY mois, ca_mensuel DESC;
```

- **Top 5 produits par région et par mois (DENSE_RANK)**

```sql
WITH base AS (
  SELECT
    DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1) AS mois,
    m.region,
    p.produit_nom,
    SUM(f.montant) AS ca
  FROM fact_ventes f
  JOIN dim_date d ON f.date_id = d.date_id
  JOIN dim_produit p ON f.produit_sk = p.produit_sk
  JOIN dim_magasin m ON f.magasin_sk = m.magasin_sk
  GROUP BY DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1), m.region, p.produit_nom
)
SELECT *
FROM (
  SELECT *, DENSE_RANK() OVER (PARTITION BY mois, region ORDER BY ca DESC) AS rk
  FROM base
) t
WHERE rk <= 5
ORDER BY mois, region, ca DESC;
```

- **Variations MoM et YoY par catégorie (LAG)**

```sql
WITH cat AS (
  SELECT
    DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1) AS mois,
    p.categorie,
    SUM(f.montant) AS ca
  FROM fact_ventes f
  JOIN dim_date d ON f.date_id = d.date_id
  JOIN dim_produit p ON f.produit_sk = p.produit_sk
  GROUP BY DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1), p.categorie
)
SELECT
  mois,
  categorie,
  ca,
  (ca - LAG(ca, 1) OVER (PARTITION BY categorie ORDER BY mois)) / NULLIF(LAG(ca, 1) OVER (PARTITION BY categorie ORDER BY mois),0) AS croissance_mom,
  (ca - LAG(ca, 12) OVER (PARTITION BY categorie ORDER BY mois)) / NULLIF(LAG(ca, 12) OVER (PARTITION BY categorie ORDER BY mois),0) AS croissance_yoy
FROM cat
ORDER BY mois, categorie;
```

- **Pivot Produits x Magasins (CA)**

```sql
SELECT produit_nom,
  SUM(CASE WHEN magasin_id = 'M01' THEN montant ELSE 0 END) AS ca_M01,
  SUM(CASE WHEN magasin_id = 'M02' THEN montant ELSE 0 END) AS ca_M02,
  SUM(CASE WHEN magasin_id = 'M03' THEN montant ELSE 0 END) AS ca_M03
FROM fact_ventes f
JOIN dim_produit p ON f.produit_sk = p.produit_sk
JOIN dim_magasin m ON f.magasin_sk = m.magasin_sk
GROUP BY produit_nom;
```

## 2. Slice / Dice (concept)

- Slice : filtrer une dimension (ex. Magasin = M01) ⇒ sous-cube 2D.
- Dice : filtrer plusieurs dimensions (Catégorie ∈ {C1,C2} ET Mois ∈ {01,02}).
- Roll-up = agrégation vers le haut (jour→mois→année) ; Drill-down = inverse.

## 3. Contrôles de cohérence

```sql
-- Total annuel = somme des mois
SELECT annee, SUM(ca_mensuel) AS ca_annuel
FROM (
  SELECT YEAR(d.date_cal) AS annee,
         DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1) AS mois,
         SUM(f.montant) AS ca_mensuel
  FROM fact_ventes f
  JOIN dim_date d ON f.date_id = d.date_id
  GROUP BY YEAR(d.date_cal), DATEFROMPARTS(YEAR(d.date_cal), MONTH(d.date_cal), 1)
) x
GROUP BY annee;

-- CA magasin = somme CA produits (même niveau)
SELECT m.magasin_id,
       SUM(f.montant) AS ca_magasin,
       SUM(SUM(f.montant)) OVER() AS ca_total
FROM fact_ventes f
JOIN dim_magasin m ON f.magasin_sk = m.magasin_sk
GROUP BY m.magasin_id;
```

## 4. Livrables attendus

- Fichier SQL avec les requêtes ci-dessus adaptées au dataset fourni.
- Tableau des résultats ou captures (ou fichiers CSV d’export) pour chaque requête.
- Brève interprétation : top produits, tendances MoM/YoY, cohérence des agrégations.
