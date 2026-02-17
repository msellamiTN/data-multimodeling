# Chapitre C — Modélisation Multidimensionnelle

> **Semaine 3** | **Volume horaire : 8h** | **Crédits : 0.4**  
> **Références : Kimball & Ross (2003) Chap. 6-9, Cuzzocrea & Moussa (2016) ER 2016**

## Positionnement académique

Ce chapitre représente le cœur méthodologique de la modélisation décisionnelle. Il établit les fondements théoriques et pratiques de la conception multidimensionnelle, qui constitue le langage commun entre les besoins métier et les implémentations techniques des systèmes décisionnels.

## Objectifs pédagogiques

À l'issue de ce chapitre, l'étudiant sera capable de :

1. **Maîtriser** les concepts fondamentaux : faits, dimensions, mesures, granularité
2. **Concevoir** des schémas en étoile et en flocon selon les exigences métier
3. **Analyser** les compromis entre normalisation et performance
4. **Définir** des hiérarchies et des niveaux d'agrégation pertinents
5. **Évaluer** la qualité d'un modèle dimensionnel selon les standards académiques

## Contenu théorique

### 1. Fondements de la modélisation multidimensionnelle

#### 1.1 Concepts fondamentaux

**Table de faits (Fact Table)** : Table centrale contenant les mesures numériques et les clés étrangères vers les dimensions. Représente le grain de l'analyse.

**Dimensions (Dimension Tables)** : Tables descriptives contenant les attributs contextuels d'analyse. Supportent la navigation et le drill-down.

**Mesures (Measures)** : Valeurs numériques analysables (somme, moyenne, comptage). Doivent être additives, semi-additives ou non-additives.

**Granularité (Grain)** : Niveau de détail le plus fin représenté dans la table de faits. Définit l'unité d'analyse fondamentale.

#### 1.2 Formalisation mathématique

Soit :
- **F** = {f₁, f₂, ..., fₙ} l'ensemble des faits
- **D** = {d₁, d₂, ..., dₘ} l'ensemble des dimensions  
- **M** = {m₁, m₂, ..., mₖ} l'ensemble des mesures

Le modèle multidimensionnel est défini comme :
```
Fact Table: F × D → M
```

La granularité G est le plus petit niveau de détail :
```
G = min{g₁, g₂, ..., gₙ} où gᵢ représente le niveau de détail de la dimension dᵢ
```

### 2. Schémas dimensionnels

#### 2.1 Schéma en étoile (Star Schema)

**Définition** : Architecture avec une table de faits centrale connectée directement à des tables de dimensions dénormalisées.

**Avantages** :
- Performance optimale (joint simple)
- Simplicité de compréhension
- Maintenance facilitée

**Inconvénients** :
- Redondance des données
- Espace de stockage accru

```mermaid
erDiagram
    DIM_DATE ||--o{ FACT_VENTES
    DIM_PRODUIT ||--o{ FACT_VENTES
    DIM_MAGASIN ||--o{ FACT_VENTES
    DIM_CLIENT ||--o{ FACT_VENTES
    DIM_PROMOTION ||--o{ FACT_VENTES
    
    FACT_VENTES {
        date_key int PK
        produit_key int PK
        magasin_key int PK
        client_key int PK
        promotion_key int PK
        montant_vente decimal
        quantite_vendue int
        marge_beneficiaire decimal
        cout_vente decimal
    }
    
    DIM_DATE {
        date_key int PK
        date_complete date
        jour_semaine int
        mois int
        trimestre int
        annee int
        est_jour_ferie boolean
        semaine_fiscale varchar
        jour_annee int
    }
    
    DIM_PRODUIT {
        produit_key int PK
        produit_nom varchar
        categorie_produit varchar
        sous_categorie varchar
        marque varchar
        prix_unitaire decimal
        cout_unitaire decimal
        est_label_prive boolean
        poids_kg decimal
    }
    
    DIM_MAGASIN {
        magasin_key int PK
        magasin_nom varchar
        ville varchar
        region varchar
        pays varchar
        surface_m2 int
        date_ouverture date
    }
    
    DIM_CLIENT {
        client_key int PK
        client_nom varchar
        email varchar
        segment_client varchar
        date_inscription date
        est_actif boolean
    }
    
    DIM_PROMOTION {
        promotion_key int PK
        promotion_nom varchar
        type_promotion varchar
        remise_pct decimal
        date_debut date
        date_fin date
    }
```

#### 2.2 Schéma en flocon (Snowflake Schema)

**Définition** : Extension du schéma en étoile avec normalisation des dimensions en sous-dimensions.

**Avantages** :
- Réduction de la redondance
- Maintenance simplifiée des hiérarchies
- Espace de stockage optimisé

**Inconvénients** :
- Complexité des jointures
- Performance dégradée
- Maintenance plus complexe

```mermaid
erDiagram
    DIM_DATE ||--o{ FACT_VENTES
    DIM_PRODUIT ||--o{ FACT_VENTES
    DIM_MAGASIN ||--o{ FACT_VENTES
    DIM_CLIENT ||--o{ FACT_VENTES
    
    DIM_CATEGORIE ||--o{ DIM_PRODUIT
    DIM_SOUS_CATEGORIE ||--o{ DIM_PRODUIT
    DIM_REGION ||--o{ DIM_MAGASIN
    DIM_VILLE ||--o{ DIM_MAGASIN
    DIM_SEGMENT_CLIENT ||--o{ DIM_CLIENT
    
    FACT_VENTES {
        date_key int PK
        produit_key int PK
        magasin_key int PK
        client_key int PK
        montant_vente decimal
        quantite_vendue int
    }
    
    DIM_PRODUIT {
        produit_key int PK
        produit_nom varchar
        categorie_key int FK
        sous_categorie_key int FK
        marque varchar
        prix_unitaire decimal
        est_actif boolean
    }
    
    DIM_CATEGORIE {
        categorie_key int PK
        categorie_nom varchar
        description_categorie varchar
        responsable_achat varchar
    }
```

#### 2.3 Analyse comparative

| Critère | Schéma en étoile | Schéma en flocon |
|---------|------------------|------------------|
| **Performance** | Excellente (1 joint) | Moyenne (2-3 joints) |
| **Stockage** | Élevé (redondance) | Optimisé (normalisé) |
| **Maintenance** | Simple | Complexe |
| **Flexibilité** | Moyenne | Élevée |
| **Compréhension** | Facile | Difficile |

### 3. Hiérarchies et agrégations

#### 3.1 Types de hiérarchies

**Hiérarchies équilibrées** : Niveaux réguliers avec relations 1:N
- Exemple : Jour → Mois → Trimestre → Année

**Hiérarchies non équilibrées** : Profondeurs variables
- Exemple : Produit → Catégorie → Division → Entreprise

**Hiérarchies ragged** : Niveaux manquants
- Exemple : Ville → Région → Pays (certains pays n'ont pas de région)

#### 3.2 Implémentation des hiérarchies

```sql
-- Table de dimension avec hiérarchie de temps
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    date_complete DATE NOT NULL,
    jour_semaine INTEGER,
    nom_jour_semaine VARCHAR(10),
    jour_mois INTEGER,
    mois INTEGER,
    nom_mois VARCHAR(10),
    trimestre INTEGER,
    annee INTEGER,
    semestre INTEGER,
    semaine_iso INTEGER,
    est_jour_ferie BOOLEAN,
    est_weekend BOOLEAN,
    -- Colonnes hiérarchiques
    mois_key INTEGER,
    trimestre_key INTEGER,
    annee_key INTEGER,
    -- Contraintes hiérarchiques
    FOREIGN KEY (mois_key) REFERENCES dim_mois(mois_key),
    FOREIGN KEY (trimestre_key) REFERENCES dim_trimestre(trimestre_key),
    FOREIGN KEY (annee_key) REFERENCES dim_annee(annee_key)
);

-- Tables de hiérarchie normalisées
CREATE TABLE dim_mois (
    mois_key INTEGER PRIMARY KEY,
    mois INTEGER,
    nom_mois VARCHAR(10),
    trimestre_key INTEGER,
    annee_key INTEGER
);

CREATE TABLE dim_trimestre (
    trimestre_key INTEGER PRIMARY KEY,
    trimestre INTEGER,
    annee INTEGER,
    annee_key INTEGER
);
```

#### 3.3 Opérations d'agrégation

```sql
-- Roll-up : Agrégation du niveau jour vers mois
SELECT 
    d.mois_key,
    d.annee,
    SUM(f.montant_vente) as ventes_mensuelles,
    SUM(f.quantite_vendue) as quantite_mensuelle,
    COUNT(DISTINCT f.client_key) as clients_uniques_mensuels
FROM fact_ventes f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.annee = 2024
GROUP BY d.mois_key, d.annee
ORDER BY d.mois_key;

-- Drill-down : Désagrégation du niveau mois vers jour
SELECT 
    d.date_complete,
    d.jour_semaine,
    f.montant_vente,
    f.quantite_vendue,
    p.categorie_produit
FROM fact_ventes f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_produit p ON f.produit_key = p.produit_key
WHERE d.mois_key = 202401
    AND p.categorie_produit = 'Électronique'
ORDER BY d.date_complete;
```

### 4. Granularité et choix du grain

#### 4.1 Principes de détermination du grain

**Règle fondamentale** : Le grain doit être le plus fin possible tout en restant pertinent pour l'analyse.

**Facteurs à considérer** :
- Besoins analytiques des utilisateurs
- Volume de données attendu
- Performance des requêtes
- Complexité de maintenance

#### 4.2 Exemples de granularité

| Contexte | Grain possible | Recommandation |
|-----------|----------------|----------------|
| **Ventes retail** | Transaction individuelle | ✅ Optimal pour analyse détaillée |
| **Banque** | Transaction journalière | ✅ Équilibre performance/détail |
| **Web analytics** | Session utilisateur | ✅ Pertinent pour analyse comportement |
| **Supply chain** | Mouvement de stock | ✅ Nécessaire pour traçabilité |

#### 4.3 Impact sur la modélisation

```sql
-- Exemple : Grain au niveau transactionnel (détaillé)
CREATE TABLE fact_ventes_detail (
    transaction_id BIGINT PRIMARY KEY,
    date_key INTEGER NOT NULL,
    produit_key INTEGER NOT NULL,
    magasin_key INTEGER NOT NULL,
    client_key INTEGER NOT NULL,
    employe_key INTEGER NOT NULL,
    promotion_key INTEGER,
    quantite INTEGER NOT NULL,
    prix_unitaire DECIMAL(10,2) NOT NULL,
    montant_total DECIMAL(12,2) NOT NULL,
    remise_montant DECIMAL(10,2) DEFAULT 0,
    taxe_montant DECIMAL(10,2) DEFAULT 0,
    canal_vente VARCHAR(20),
    mode_paiement VARCHAR(20),
    horaire_vente TIME,
    -- Contraintes
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (produit_key) REFERENCES dim_produit(produit_key),
    FOREIGN KEY (magasin_key) REFERENCES dim_magasin(magasin_key),
    FOREIGN KEY (client_key) REFERENCES dim_client(client_key)
);

-- Exemple : Grain au niveau journalier (agrégé)
CREATE TABLE fact_ventes_journalieres (
    date_key INTEGER NOT NULL,
    produit_key INTEGER NOT NULL,
    magasin_key INTEGER NOT NULL,
    montant_vente_total DECIMAL(15,2) NOT NULL,
    quantite_totale INTEGER NOT NULL,
    nb_transactions INTEGER NOT NULL,
    montant_moyen_transaction DECIMAL(12,2),
    remise_totale DECIMAL(12,2),
    taxe_totale DECIMAL(12,2),
    PRIMARY KEY (date_key, produit_key, magasin_key)
);

#### 4.3.0 Gestion des Dimensions Multi-valuées (Tables de Pont)

Lorsqu'un fait est lié à plusieurs valeurs d'une dimension (relation Many-to-Many), une **Table de Pont (Bridge Table)** est requise.
*Exemple : Un diagnostic patient (Fait) peut impliquer plusieurs médecins (Dimension).*

```mermaid
erDiagram
    FACT_DIAGNOSIS }|--|| BRIDGE_DOCTOR_GROUP : "group_id"
    BRIDGE_DOCTOR_GROUP }|--|| DIM_DOCTOR : "doctor_id"
    FACT_DIAGNOSIS {
        int diagnosis_id
        int group_id FK
    }
    BRIDGE_DOCTOR_GROUP {
        int group_id FK
        int doctor_id FK
        float weight_factor
    }
    DIM_DOCTOR {
        int doctor_id PK
        string name
    }
| **SCD Type 1** | Écrasement des anciennes valeurs | Données de référence courantes | Minimal |
| **SCD Type 2** | Conservation historique complète | Analyse d'évolution | 3-5x augmentation |
| **SCD Type 3** | Valeur actuelle + précédente limitée | Audit léger | 2x augmentation |
| **SCD Type 6** | Hybride (Type 2 + Type 3) | Analyse complète + audit rapide | 4-6x augmentation |

#### 5.2 Implémentation SCD Type 2

```sql
-- Table de dimension client avec gestion SCD Type 2
CREATE TABLE dim_client (
    client_key INTEGER PRIMARY KEY,
    client_id INTEGER NOT NULL,
    client_nom VARCHAR(100) NOT NULL,
    client_prenom VARCHAR(50),
    email VARCHAR(100),
    telephone VARCHAR(20),
    segment_client VARCHAR(20),
    ville VARCHAR(50),
    region VARCHAR(50),
    pays VARCHAR(50),
    code_postal VARCHAR(10),
    date_debut_validite DATE NOT NULL,
    date_fin_validite DATE DEFAULT '9999-12-31',
    est_actif BOOLEAN DEFAULT TRUE,
    version_enregistrement INTEGER DEFAULT 1,
    -- Index pour performance
    UNIQUE (client_id, date_debut_validite),
    INDEX idx_client_id_actif (client_id, est_actif),
    INDEX idx_email (email)
);

-- Procédure de mise à jour SCD Type 2
CREATE OR REPLACE PROCEDURE maj_client_scd2(
    p_client_id INTEGER,
    p_client_nom VARCHAR(100),
    p_email VARCHAR(100),
    p_segment VARCHAR(20),
    p_ville VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_key INTEGER;
    v_has_changes BOOLEAN := FALSE;
BEGIN
    -- Vérifier si le client existe et est actif
    SELECT client_key INTO v_current_key
    FROM dim_client 
    WHERE client_id = p_client_id AND est_actif = TRUE;
    
    -- Si le client n'existe pas, insertion simple
    IF v_current_key IS NULL THEN
        INSERT INTO dim_client (
            client_id, client_nom, email, segment_client, ville,
            date_debut_validite, est_actif, version_enregistrement
        ) VALUES (
            p_client_id, p_client_nom, p_email, p_segment, p_ville,
            CURRENT_DATE, TRUE, 1
        );
    ELSE
        -- Vérifier si des changements significatifs
        SELECT EXISTS(
            SELECT 1 FROM dim_client 
            WHERE client_key = v_current_key
            AND (
                client_nom != p_client_nom OR
                email != p_email OR
                segment_client != p_segment OR
                ville != p_ville
            )
        ) INTO v_has_changes;
        
        -- Si changements, créer nouvelle version
        IF v_has_changes THEN
            -- Désactiver l'ancienne version
            UPDATE dim_client 
            SET est_actif = FALSE, 
                date_fin_validite = CURRENT_DATE - INTERVAL '1 day'
            WHERE client_key = v_current_key;
            
            -- Créer nouvelle version
            INSERT INTO dim_client (
                client_id, client_nom, email, segment_client, ville,
                date_debut_validite, est_actif, 
                version_enregistrement
            ) SELECT 
                p_client_id, p_client_nom, p_email, p_segment, p_ville,
                CURRENT_DATE, TRUE,
                version_enregistrement + 1
            FROM dim_client 
            WHERE client_key = v_current_key;
        END IF;
    END IF;
END;
$$;
```

### 6. Cas d'usage avancé

#### 6.1 Contexte : Plateforme e-commerce B2B

**Problématique métier** :
- 100K produits, 50K clients B2B, 1M commandes/mois
- Analyse des performances par catégorie, segment client, géographie
- Besoin de suivi des évolutions de prix et de segmentation
- Optimisation des stocks et prévision de la demande

**Modèle dimensionnel conçu** :

```sql
-- Table de faits commandes avec grain ligne de commande
CREATE TABLE fact_ligne_commande (
    ligne_commande_id BIGINT PRIMARY KEY,
    commande_id BIGINT NOT NULL,
    date_commande_key INTEGER NOT NULL,
    date_livraison_key INTEGER,
    client_key INTEGER NOT NULL,
    produit_key INTEGER NOT NULL,
    representant_key INTEGER,
    canal_vente_key INTEGER,
    quantite_commandee INTEGER NOT NULL,
    prix_unitaire_ht DECIMAL(12,2) NOT NULL,
    remise_pourcentage DECIMAL(5,2) DEFAULT 0,
    montant_total_ht DECIMAL(15,2) NOT NULL,
    montant_total_ttc DECIMAL(15,2) NOT NULL,
    cout_marchandise DECIMAL(12,2),
    marge_beneficiaire DECIMAL(12,2),
    delai_livraison_jours INTEGER,
    statut_livraison VARCHAR(20),
    -- Contraintes et index
    FOREIGN KEY (date_commande_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (client_key) REFERENCES dim_client(client_key),
    FOREIGN KEY (produit_key) REFERENCES dim_produit(produit_key),
    INDEX idx_commande_id (commande_id),
    INDEX idx_client_date (client_key, date_commande_key),
    INDEX idx_produit_date (produit_key, date_commande_key)
);

-- Dimension produit avec hiérarchie complexe
CREATE TABLE dim_produit (
    produit_key INTEGER PRIMARY KEY,
    produit_id VARCHAR(50) NOT NULL,
    produit_nom VARCHAR(200) NOT NULL,
    produit_description TEXT,
    categorie_key INTEGER,
    sous_categorie_key INTEGER,
    famille_produit_key INTEGER,
    marque VARCHAR(100),
    fournisseur_principal VARCHAR(100),
    poids_kg DECIMAL(8,3),
    volume_cm3 DECIMAL(10,2),
    prix_achat_ht DECIMAL(12,2),
    prix_vente_standard_ht DECIMAL(12,2),
    marge_standard_pourcentage DECIMAL(5,2),
    est_actif BOOLEAN DEFAULT TRUE,
    date_lancement DATE,
    date_discontinuation DATE,
    -- Attributs analytiques
    segment_prix VARCHAR(20),
    niveau_complexite VARCHAR(20),
    frequence_achat_estimee VARCHAR(20),
    -- Gestion SCD Type 2 pour les prix
    date_debut_prix DATE NOT NULL,
    date_fin_prix DATE DEFAULT '9999-12-31',
    version_prix INTEGER DEFAULT 1,
    UNIQUE (produit_id, date_debut_prix)
);

-- Vue analytique pour le dashboard commercial
CREATE MATERIALIZED VIEW mv_analyse_commerciale AS
WITH performance_produits AS (
    SELECT 
        p.produit_key,
        p.produit_nom,
        p.categorie_key,
        c.nom_categorie,
        SUM(f.quantite_commandee) as quantite_totale,
        SUM(f.montant_total_ht) as ca_total_ht,
        SUM(f.marge_beneficiaire) as marge_totale,
        COUNT(DISTINCT f.commande_id) as nb_commandes,
        COUNT(DISTINCT f.client_key) as nb_clients_distincts,
        AVG(f.prix_unitaire_ht) as prix_moyen_vente,
        -- Calcul des tendances
        SUM(CASE WHEN d.mois = EXTRACT(MONTH FROM CURRENT_DATE) 
                AND d.annee = EXTRACT(YEAR FROM CURRENT_DATE) 
                THEN f.montant_total_ht ELSE 0 END) as ca_mois_en_cours,
        SUM(CASE WHEN d.mois = EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL '1 MONTH') 
                AND d.annee = EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1 MONTH') 
                THEN f.montant_total_ht ELSE 0 END) as ca_mois_precedent
    FROM fact_ligne_commande f
    JOIN dim_produit p ON f.produit_key = p.produit_key
    JOIN dim_categorie c ON p.categorie_key = c.categorie_key
    JOIN dim_date d ON f.date_commande_key = d.date_key
    WHERE d.date_complete >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY p.produit_key, p.produit_nom, p.categorie_key, c.nom_categorie
),
analyse_client_segment AS (
    SELECT 
        cl.segment_client,
        cl.type_client,
        SUM(f.montant_total_ht) as ca_segment,
        COUNT(DISTINCT f.client_key) as nb_clients,
        AVG(f.montant_total_ht) as panier_moyen_segment,
        SUM(f.quantite_commandee) as quantite_segment
    FROM fact_ligne_commande f
    JOIN dim_client cl ON f.client_key = cl.client_key
    JOIN dim_date d ON f.date_commande_key = d.date_key
    WHERE d.date_complete >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY cl.segment_client, cl.type_client
)
SELECT 
    pp.produit_key,
    pp.produit_nom,
    pp.categorie_key,
    pp.nom_categorie,
    pp.quantite_totale,
    pp.ca_total_ht,
    pp.marge_totale,
    ROUND(pp.marge_totale * 100.0 / NULLIF(pp.ca_total_ht, 0), 2) as taux_marge_pct,
    pp.nb_commandes,
    pp.nb_clients_distincts,
    pp.prix_moyen_vente,
    -- Tendances
    ROUND((pp.ca_mois_en_cours - pp.ca_mois_precedent) * 100.0 / NULLIF(pp.ca_mois_precedent, 0), 2) as croissance_mensuelle_pct,
    -- Classements
    ROW_NUMBER() OVER (ORDER BY pp.ca_total_ht DESC) as rang_ca_global,
    ROW_NUMBER() OVER (PARTITION BY pp.categorie_key ORDER BY pp.ca_total_ht DESC) as rang_ca_categorie,
    -- Flags analytiques
    CASE 
        WHEN pp.ca_mois_en_cours > pp.ca_mois_precedent * 1.1 THEN 'En croissance'
        WHEN pp.ca_mois_en_cours < pp.ca_mois_precedent * 0.9 THEN 'En déclin'
        ELSE 'Stable'
    END as tendance_produit
FROM performance_produits pp;

-- Rafraîchissement quotidien
CREATE OR REPLACE FUNCTION rafraichir_mv_analyse_commerciale()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_commerciale;
END;
$$ LANGUAGE plpgsql;
```

#### 6.2 Indicateurs de performance

**KPIs de modélisation** :
- Taux de remplissage des dimensions : > 95%
- Qualité des clés étrangères : 100%
- Performance des requêtes : < 2 secondes pour agrégations mensuelles
- Volume de données : 50M lignes de faits, croissance 10%/mois

### 7. Exercices pratiques

#### 7.1 Exercice de conception

**Énoncé** : Une chaîne hôtelière souhaite analyser ses performances. Les données disponibles :
- Réservations (système PMS)
- Informations clients (CRM)
- Caractéristiques hôtels (référentiel)
- Données concurrentielles (fichiers externes)

**Travail demandé** :
1. Définir le grain approprié pour la table de faits
2. Concevoir le schéma dimensionnel (étoile vs flocon)
3. Identifier les mesures et dimensions
4. Proposer des hiérarchies pertinentes

**Solution attendue** :
- Grain : réservation par nuitée
- Schéma en étoile pour performance
- Mesures : revenu, occupation, taux de satisfaction
- Dimensions : temps, hôtel, client, chambre, canal réservation

#### 7.2 Étude de cas optimisation

**Contexte** : Un détaillant rencontre des problèmes de performance avec son modèle actuel.

**Problèmes identifiés** :
- Requêtes d'analyse > 30 secondes
- Table de faits > 500M lignes
- Dimensions avec > 10M lignes chacune
- Jointures complexes sur 5 niveaux de hiérarchie

**Questions d'analyse** :
1. Quelles optimisations de schéma proposer ?
2. Comment partitionner les tables de faits ?
3. Quels indexes créer pour améliorer la performance ?

### 8. Références académiques

#### 8.1 Références principales

**Kimball, R., & Ross, M.** (2003). *Entrepôts de données : guide pratique de modélisation dimensionnelle*.
- Chapitre 6 : The 10 Essential Requirements of Dimensional Modeling
- Chapitre 7 : Introduction to Dimensional Modeling
- Chapitre 8 : Stars, Snowflakes, and Galaxies

**Cuzzocrea, A., & Moussa, R.** (2016). "Multi-Dimensional Database Modeling and Querying: Methods, Experiences and Challenging Problems". ER 2016, Japan.
- Section 3.1 : Dimensional Modeling Fundamentals
- Section 4.2 : Advanced Schema Patterns

#### 8.2 Références complémentaires

**Kimball, R., et al.** *The Data Warehouse Lifecycle Toolkit*.
- Partie 4 : Dimensional Modeling Techniques

**Nagabhushana, S.** (2006). *Data Warehousing, OLAP and Data Mining*. New Age.
- Chapter 3 : Dimensional Modeling Concepts

---

**Contact enseignant** : M. Sellami Mokhtar  
**Volume horaire total** : 8h (4h cours magistral + 4h travaux dirigés)  
**Évaluation** : Contrôle continu (10%) + Participation (10%) + TD (20%) + Exam final (60%)
