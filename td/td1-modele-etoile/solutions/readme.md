# Correction TD1 — Modèle en étoile

## 1. Grain et tables

- Grain de `fact_ventes` : **transaction par produit, par magasin, par date**.
- Dimensions minimales : `dim_date`, `dim_produit`, `dim_magasin`.

## 2. DDL proposé (exemple SQL)

```sql
CREATE TABLE dim_date (
  date_id INT AUTO_INCREMENT PRIMARY KEY,
  date_cal DATE NOT NULL,
  annee INT, mois INT, jour INT,
  trimestre INT
);

CREATE TABLE dim_produit (
  produit_sk INT AUTO_INCREMENT PRIMARY KEY,
  produit_id VARCHAR(10) UNIQUE,
  produit_nom VARCHAR(100),
  categorie VARCHAR(50)
);

CREATE TABLE dim_magasin (
  magasin_sk INT AUTO_INCREMENT PRIMARY KEY,
  magasin_id VARCHAR(10) UNIQUE,
  ville VARCHAR(50),
  region VARCHAR(50)
);

CREATE TABLE fact_ventes (
  fact_sk BIGINT AUTO_INCREMENT PRIMARY KEY,
  date_id INT NOT NULL,
  produit_sk INT NOT NULL,
  magasin_sk INT NOT NULL,
  montant DECIMAL(12,2),
  quantite INT,
  FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
  FOREIGN KEY (produit_sk) REFERENCES dim_produit(produit_sk),
  FOREIGN KEY (magasin_sk) REFERENCES dim_magasin(magasin_sk)
);
```

## 3. Inserts d’exemple

```sql
-- Dimensions
INSERT INTO dim_date (date_cal, annee, mois, jour, trimestre) VALUES
 ('2024-01-02', 2024, 1, 2, 1),
 ('2024-01-03', 2024, 1, 3, 1),
 ('2024-01-04', 2024, 1, 4, 1);

INSERT INTO dim_produit (produit_id, produit_nom, categorie) VALUES
 ('P01', 'Chemise Oxford', 'Textile'),
 ('P02', 'Sneakers Run', 'Chaussure'),
 ('P03', 'Jeans Slim', 'Textile');

INSERT INTO dim_magasin (magasin_id, ville, region) VALUES
 ('M01', 'Paris', 'IDF'),
 ('M02', 'Lyon', 'ARA');

-- Faits (référence via SK, à adapter selon SK générés)
INSERT INTO fact_ventes (date_id, produit_sk, magasin_sk, montant, quantite) VALUES
 (1, 1, 1, 120.0, 2),
 (1, 2, 1, 75.0, 1),
 (2, 1, 2, 60.0, 1),
 (3, 3, 1, 90.0, 1);
```

## 4. Schéma étoile (Mermaid)

```mermaid
erDiagram
  DIM_DATE ||--o{ FACT_VENTE : date_id
  DIM_PRODUIT ||--o{ FACT_VENTE : produit_sk
  DIM_MAGASIN ||--o{ FACT_VENTE : magasin_sk

  DIM_DATE {
    date_id INT PK
    date_cal DATE
    annee INT
    mois INT
    jour INT
    trimestre INT
  }
  DIM_PRODUIT {
    produit_sk INT PK
    produit_id STRING UNIQUE
    produit_nom STRING
    categorie STRING
  }
  DIM_MAGASIN {
    magasin_sk INT PK
    magasin_id STRING UNIQUE
    ville STRING
    region STRING
  }
  FACT_VENTE {
    fact_sk INT PK
    date_id INT FK
    produit_sk INT FK
    magasin_sk INT FK
    montant DECIMAL
    quantite INT
  }
```

## 5. Requêtes de validation

- Volume lignes :

```sql
SELECT COUNT(*) AS nb_lignes FROM fact_ventes;
```

- Top 3 produits par CA :

```sql
SELECT p.produit_nom, SUM(f.montant) AS ca
FROM fact_ventes f
JOIN dim_produit p ON f.produit_sk = p.produit_sk
GROUP BY p.produit_nom
ORDER BY ca DESC
LIMIT 3;
```

- CA par ville et par mois :

```sql
SELECT d.annee, d.mois, m.ville, SUM(f.montant) AS ca
FROM fact_ventes f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_magasin m ON f.magasin_sk = m.magasin_sk
GROUP BY d.annee, d.mois, m.ville
ORDER BY d.annee, d.mois, m.ville;
```

## 6. Erreurs fréquentes

- Grain incohérent (ex : mélange ligne de ticket vs ligne de produit).
- Mesures non additives dans la même table de faits (prudence avec taux, ratios).
- Dimensions dupliquées ou non conformes (clés naturelles réutilisées sans SK, pas de référentiel clair).

## 7. Livrables attendus

- Markdown avec schéma Mermaid et justification du grain.
- SQL : DDL + inserts + 3 requêtes de validation commentées.
- Bref paragraphe sur les choix d’attributs et la granularité.
