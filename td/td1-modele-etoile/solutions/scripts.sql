-- TD1 Modèle en étoile — DDL
CREATE TABLE dim_date (
  date_id INT AUTO_INCREMENT PRIMARY KEY,
  date_cal DATE NOT NULL,
  annee INT,
  mois INT,
  jour INT,
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

-- TD1 Inserts d'exemple
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

INSERT INTO fact_ventes (date_id, produit_sk, magasin_sk, montant, quantite) VALUES
 (1, 1, 1, 120.0, 2),
 (1, 2, 1, 75.0, 1),
 (2, 1, 2, 60.0, 1),
 (3, 3, 1, 90.0, 1);

-- TD1 Requêtes de validation
-- Volume total
SELECT COUNT(*) AS nb_lignes FROM fact_ventes;

-- Top 3 produits par CA
SELECT p.produit_nom, SUM(f.montant) AS ca
FROM fact_ventes f
JOIN dim_produit p ON f.produit_sk = p.produit_sk
GROUP BY p.produit_nom
ORDER BY ca DESC
LIMIT 3;

-- CA par ville et par mois
SELECT d.annee, d.mois, m.ville, SUM(f.montant) AS ca
FROM fact_ventes f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_magasin m ON f.magasin_sk = m.magasin_sk
GROUP BY d.annee, d.mois, m.ville
ORDER BY d.annee, d.mois, m.ville;
