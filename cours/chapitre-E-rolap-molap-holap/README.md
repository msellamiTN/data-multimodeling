# Chapitre E — Approches d'Implantation : ROLAP/MOLAP/HOLAP

> **Semaine 5** | **Volume horaire : 8h** | **Crédits : 0.4**  
> **Références : Kimball & Ross (2003) Chap. 13-15, Syllabus MMD S4, Codd et al. (1993)**

## Positionnement académique

Ce chapitre final constitue le sommet technique du cours en établissant les fondements architecturaux des systèmes OLAP. Il permet de comprendre les compromis entre les différentes approches d'implantation et de développer la capacité à sélectionner l'architecture optimale selon les contraintes métier et techniques.

## Objectifs pédagogiques

À l'issue de ce chapitre, l'étudiant sera capable de :

1. **Distinguer** les architectures ROLAP, MOLAP et HOLAP avec leurs avantages/limites
2. **Analyser** les critères de sélection d'architecture selon le contexte
3. **Évaluer** les performances et coûts de chaque approche
4. **Concevoir** une architecture hybride adaptée aux besoins complexes
5. **Justifier** les choix techniques avec des arguments quantifiés

## Contenu théorique

### 1. Fondements architecturaux OLAP

#### 1.1 Classification des architectures OLAP

**ROLAP (Relational OLAP)** : Architecture basée sur des bases de données relationnelles traditionnelles avec des vues matérialisées et des requêtes SQL complexes.

**MOLAP (Multidimensional OLAP)** : Architecture optimisée avec stockage multidimensionnel natif et pré-agrégation des données.

**HOLAP (Hybrid OLAP)** : Architecture combinant les avantages de ROLAP et MOLAP pour optimiser les performances et la flexibilité.

#### 1.2 Matrice de décision architecturale

| Critère | ROLAP | MOLAP | HOLAP |
| :--- | :--- | :--- | :--- |
| **Performance** | Variable | Excellente | Très bonne |
| **Scalabilité** | Excellente | Limitée | Bonne |
| **Flexibilité** | Maximale | Moyenne | Bonne |
| **Coût** | Faible | Élevé | Moyen |
| **Complexité** | Moyenne | Élevée | Très élevée |
| **Maintenance** | Simple | Complexe | Très complexe |

### 2. Architecture ROLAP

#### 2.0 Modern Data Stack & Cloud Data Warehousing

Le paradigme ETL traditionnel évolue vers l'**ELT (Extract-Load-Transform)** à l'ère du cloud computing.

| Caractéristique | Entrepôt Traditionnel (On-Premise) | Modern Data Stack (Cloud) |
|-----------------|-----------------------------------|---------------------------|
| **Architecture** | SMP (Symmetric Multi-Processing) | MPP (Massively Parallel Processing) |
| **Mise à l'échelle** | Verticale (Scale-up) | Horizontale (Scale-out) |
| **Stockage/Calcul** | Couplés | Découplés (Optimisation des coûts) |
| **Paradigme** | ETL (Transform before Load) | ELT (Load raw, Transform in DB) |
| **Exemples** | Oracle Exadata, Teradata | Snowflake, Google BigQuery, Databricks |

#### 2.1 Principes fondamentaux

**Stockage** : Données dans SGBD relationnel (Oracle, PostgreSQL, SQL Server)

**Accès** : Requêtes SQL dynamiques avec jointures et agrégations

**Optimisation** : Index bitmap, vues matérialisées, partitionnement

**Avantages** :
- Utilisation de l'infrastructure existante
- Scalabilité quasi illimitée
- Flexibilité maximale pour les requêtes ad-hoc
- Coût de licence réduit

**Limites** :
- Performance variable selon complexité
- Maintenance des vues matérialisées
- Consommation importante de ressources

#### 2.2 Implémentation ROLAP avancée

```sql
-- Architecture ROLAP avec vues matérialisées stratégiques
-- Vue matérialisée pour agrégations mensuelles (hot data)
CREATE MATERIALIZED VIEW mv_ventes_mensuelles AS
SELECT 
    d.annee,
    d.mois,
    p.categorie_produit,
    g.region,
    g.pays,
    SUM(f.montant_vente) as ventes_mensuelles,
    SUM(f.quantite_vendue) as quantite_mensuelle,
    COUNT(DISTINCT f.client_key) as clients_uniques_mensuels,
    COUNT(*) as nb_transactions_mensuelles,
    AVG(f.montant_vente) as panier_moyen_mensuel,
    -- Calculs avancés
    STDDEV(f.montant_vente) as ecart_type_ventes,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.montant_vente) as mediane_ventes
FROM fact_ventes f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_produit p ON f.produit_key = p.produit_key
JOIN dim_magasin g ON f.magasin_key = g.magasin_key
WHERE d.date_complete >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY d.annee, d.mois, p.categorie_produit, g.region, g.pays
WITH DATA;

-- Index bitmap pour optimisation ROLAP
CREATE BITMAP INDEX idx_bitmap_region_mv ON mv_ventes_mensuelles(region);
CREATE BITMAP INDEX idx_bitmap_categorie_mv ON mv_ventes_mensuelles(categorie_produit);
CREATE BITMAP INDEX idx_bitmap_annee_mv ON mv_ventes_mensuelles(annee);

-- Procédure de rafraîchissement intelligent
CREATE OR REPLACE PROCEDURE rafraichir_mv_ventes_mensuelles()
LANGUAGE plpgsql
AS $$
DECLARE
    v_last_update DATE;
BEGIN
    -- Récupérer la dernière date de mise à jour
    SELECT MAX(date_complete) INTO v_last_update
    FROM dim_date 
    WHERE date_key IN (SELECT DISTINCT date_key FROM fact_ventes);
    
    -- Rafraîchir uniquement les données récentes
    DELETE FROM mv_ventes_mensuelles 
    WHERE annee = EXTRACT(YEAR FROM v_last_update)
       AND mois = EXTRACT(MONTH FROM v_last_update);
    
    INSERT INTO mv_ventes_mensuelles
    SELECT 
        d.annee, d.mois, p.categorie_produit, g.region, g.pays,
        SUM(f.montant_vente), SUM(f.quantite_vendue), 
        COUNT(DISTINCT f.client_key), COUNT(*), AVG(f.montant_vente),
        STDDEV(f.montant_vente), 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.montant_vente)
    FROM fact_ventes f
    JOIN dim_date d ON f.date_key = d.date_key
    JOIN dim_produit p ON f.produit_key = p.produit_key
    JOIN dim_magasin g ON f.magasin_key = g.magasin_key
    WHERE d.annee = EXTRACT(YEAR FROM v_last_update)
       AND d.mois = EXTRACT(MONTH FROM v_last_update)
    GROUP BY d.annee, d.mois, p.categorie_produit, g.region, g.pays;
    
    -- Statistiques pour optimisation
    ANALYZE mv_ventes_mensuelles;
END;
$$;

-- Planification du rafraîchissement
CREATE OR REPLACE FUNCTION schedule_refresh_mv()
RETURNS void AS $$
BEGIN
    PERFORM rafraichir_mv_ventes_mensuelles();
END;
$$ LANGUAGE plpgsql;

-- Trigger pour rafraîchissement automatique
CREATE OR REPLACE FUNCTION trigger_refresh_mv()
RETURNS trigger AS $$
BEGIN
    -- Rafraîchir toutes les 4 heures pour les données récentes
    PERFORM pg_sleep(1); -- Éviter les boucles infinies
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 3. Architecture MOLAP

#### 3.1 Principes fondamentaux

**Stockage** : Tableaux multidimensionnels optimisés (cubes)

**Accès** : MDX (Multidimensional Expressions) ou API propriétaires

**Optimisation** : Pré-agrégation complète, compression, calculs pré-calculés

**Avantages** :
- Performance exceptionnelle pour requêtes prédéfinies
- Interface utilisateur intuitive
- Calculs complexes intégrés
- Compression efficace des données

**Limites** :
- Scalabilité limitée par la mémoire
- Coût de licence élevé
- Complexité de maintenance
- Moins flexible pour requêtes ad-hoc

#### 3.2 Implémentation MOLAP

```sql
-- Création d'un cube MOLAP avec pré-agrégations
CREATE CUBE cube_ventes_retail AS
DIMENSION temps (
    niveau_annee,
    niveau_trimestre,
    niveau_mois,
    niveau_jour
),
DIMENSION produit (
    niveau_famille,
    niveau_categorie,
    niveau_sous_categorie,
    niveau_produit
),
DIMENSION geographie (
    niveau_continent,
    niveau_pays,
    niveau_region,
    niveau_ville,
    niveau_magasin
),
DIMENSION client (
    niveau_segment,
    niveau_type_client,
    niveau_client
)
MEASURES (
    montant_vente SUM,
    quantite_vendue SUM,
    nb_transactions COUNT,
    panier_moyen AVG,
    marge_beneficiaire SUM
);

-- Définition des hiérarchies
DEFINE HIERARCHY h_temps AS 
    (niveau_annee, niveau_trimestre, niveau_mois, niveau_jour);

DEFINE HIERARCHY h_produit AS 
    (niveau_famille, niveau_categorie, niveau_sous_categorie, niveau_produit);

DEFINE HIERARCHY h_geographie AS 
    (niveau_continent, niveau_pays, niveau_region, niveau_ville, niveau_magasin);

-- Pré-agrégations stratégiques
AGGREGATE cube_ventes_retail
BY (h_temps.niveau_annee, h_produit.niveau_categorie, h_geographie.niveau_region)
PRECOMPUTE;

AGGREGATE cube_ventes_retail
BY (h_temps.niveau_mois, h_produit.niveau_sous_categorie, h_geographie.niveau_ville)
PRECOMPUTE;

-- Calculs membres calculés
CALCULATED MEMBER [Measures].[Taux de Croissance] AS 
    ([Measures].[montant_vente] - 
     ([Measures].[montant_vente], [Temps].PrevMember)) / 
     ([Measures].[montant_vente], [Temps].PrevMember);

CALCULATED MEMBER [Measures].[Part de Marché] AS 
    ([Measures].[montant_vente]) / 
    ([Measures].[montant_vente], [Geographie].[All]);
```

#### 3.3 Optimisation MOLAP

```sql
-- Stratégie de compression et d'optimisation
-- Configuration du stockage compressé
ALTER CUBE cube_ventes_retail
SET COMPRESSION = 'ZLIB'
SET BLOCK_SIZE = '64KB'
SET CACHE_SIZE = '2GB';

-- Partitionnement du cube par temps
PARTITION CUBE cube_ventes_retail
BY temps.niveau_annee
INTO (
    partition_2020,
    partition_2021,
    partition_2022,
    partition_2023,
    partition_2024
);

-- Optimisation des requêtes fréquentes
CREATE CACHE CACHE_PERFORMANCE_DASHBOARD
FOR QUERIES (
    "SELECT {[Temps].[2024], [Temps].[2023]} ON COLUMNS,
            {[Produit].[Électronique], [Produit].[Habillement]} ON ROWS
            FROM cube_ventes_retail
            WHERE [Measures].[montant_vente]"
);

-- Monitoring des performances
CREATE VIEW v_performance_molap AS
SELECT 
    cube_name,
    query_execution_time_ms,
    cache_hit_ratio,
    memory_usage_mb,
    cpu_usage_percent,
    disk_io_mb
FROM system_molap_metrics
WHERE timestamp >= CURRENT_TIMESTAMP - INTERVAL '1 hour';
```

### 4. Architecture HOLAP

#### 4.1 Principes fondamentaux

**Hybridation** : Données récentes en MOLAP, données historiques en ROLAP

**Stratégie** : Hot data (3-6 mois) en MOLAP, Cold data en ROLAP

**Optimisation** : Routage intelligent des requêtes selon la temporalité

**Avantages** :
- Meilleur compromis performance/flexibilité
- Scalabilité préservée
- Coût maîtrisé
- Adaptation aux besoins évolutifs

**Limites** :
- Complexité architecturale élevée
- Maintenance double infrastructure
- Risques d'incohérence
- Expertise technique requise

#### 4.2 Implémentation HOLAP

```sql
-- Architecture HOLAP avec routage intelligent
CREATE OR REPLACE FUNCTION route_query_holap(
    p_date_debut DATE,
    p_date_fin DATE,
    p_dimensions TEXT[]
)
RETURNS TEXT AS $$
DECLARE
    v_date_limite DATE := CURRENT_DATE - INTERVAL '6 months';
    v_query_route TEXT;
BEGIN
    -- Détermination du routage
    IF p_date_debut >= v_date_limite AND p_date_fin >= v_date_limite THEN
        -- Requête entièrement sur MOLAP (données récentes)
        v_query_route := 'MOLAP';
    ELSIF p_date_fin < v_date_limite THEN
        -- Requête entièrement sur ROLAP (données historiques)
        v_query_route := 'ROLAP';
    ELSE
        -- Requête hybride (période transversale)
        v_query_route := 'HOLAP';
    END IF;
    
    RETURN v_query_route;
END;
$$ LANGUAGE plpgsql;

-- Vue unifiée HOLAP
CREATE OR REPLACE VIEW v_ventes_holap AS
WITH molap_data AS (
    -- Données récentes depuis cube MOLAP
    SELECT 
        annee, mois, categorie_produit, region, pays,
        ventes_mensuelles, quantite_mensuelle, clients_uniques
    FROM cube_ventes_retail
    WHERE date_complete >= CURRENT_DATE - INTERVAL '6 months'
),
rolap_data AS (
    -- Données historiques depuis ROLAP
    SELECT 
        annee, mois, categorie_produit, region, pays,
        ventes_mensuelles, quantite_mensuelle, clients_uniques
    FROM mv_ventes_mensuelles
    WHERE date_complete < CURRENT_DATE - INTERVAL '6 months'
)
SELECT * FROM molap_data
UNION ALL
SELECT * FROM rolap_data;

-- Trigger de synchronisation HOLAP
CREATE OR REPLACE FUNCTION sync_holap_data()
RETURNS void AS $$
DECLARE
    v_sync_date DATE := CURRENT_DATE - INTERVAL '6 months';
BEGIN
    -- Transfert des données de ROLAP vers MOLAP
    INSERT INTO cube_ventes_retail
    SELECT 
        annee, mois, categorie_produit, region, pays,
        ventes_mensuelles, quantite_mensuelle, clients_uniques
    FROM mv_ventes_mensuelles
    WHERE date_complete >= v_sync_date
      AND date_complete < v_sync_date + INTERVAL '1 month';
    
    -- Nettoyage des données anciennes dans MOLAP
    DELETE FROM cube_ventes_retail
    WHERE date_complete < v_sync_date;
    
    -- Validation de la cohérence
    PERFORM validate_holap_consistency();
END;
$$ LANGUAGE plpgsql;
```

### 5. Cas d'usage avancé

#### 5.1 Contexte : Groupe de distribution omnicanal

**Problématique métier** :
- 1M transactions/jour, 500K produits, 10M clients
- Analyse temps réel des ventes en ligne et en magasin
- Besoin de prévision sur 3 ans d'historique
- Contraintes : budget limité, équipe technique réduite

**Architecture HOLAP conçue** :

```sql
-- Table de faits omnicanal avec grain transaction
CREATE TABLE fact_transaction_omnicanal (
    transaction_id BIGINT PRIMARY KEY,
    date_transaction TIMESTAMP NOT NULL,
    canal_vente VARCHAR(20) NOT NULL, -- 'EN_LIGNE', 'MAGASIN', 'MOBILE'
    client_id BIGINT NOT NULL,
    produit_id BIGINT NOT NULL,
    magasin_id BIGINT, -- NULL pour en ligne
    session_id VARCHAR(50), -- NULL pour magasin
    montant_total DECIMAL(12,2) NOT NULL,
    quantite INTEGER NOT NULL,
    devise_paiement VARCHAR(3) DEFAULT 'EUR',
    moyen_paiement VARCHAR(20),
    statut_livraison VARCHAR(20),
    -- Clés étrangères
    date_key INTEGER NOT NULL,
    canal_key INTEGER NOT NULL,
    client_key INTEGER NOT NULL,
    produit_key INTEGER NOT NULL,
    magasin_key INTEGER,
    session_key INTEGER,
    -- Partitionnement HOLAP
    CONSTRAINT chk_holap_partition CHECK (
        (date_key >= 20240101 AND date_key < 20240701) OR -- MOLAP (6 mois récents)
        (date_key < 20240101) -- ROLAP (historique)
    )
) PARTITION BY RANGE (date_key);

-- Partition MOLAP (données récentes)
CREATE TABLE fact_transaction_omnicanal_molap 
PARTITION OF fact_transaction_omnicanal
FOR VALUES FROM (20240101) TO (20240701);

-- Partitions ROLAP (données historiques)
CREATE TABLE fact_transaction_omnicanal_2023 
PARTITION OF fact_transaction_omnicanal
FOR VALUES FROM (20230101) TO (20240101);

CREATE TABLE fact_transaction_omnicanal_2022 
PARTITION OF fact_transaction_omnicanal
FOR VALUES FROM (20220101) TO (20230101);

-- Vue analytique HOLAP avec optimisation
CREATE MATERIALIZED VIEW mv_analyse_omnicanal AS
WITH recent_data_molap AS (
    -- Données récentes : accès direct MOLAP optimisé
    SELECT 
        DATE_TRUNC('day', date_transaction) as jour,
        canal_vente,
        p.categorie_produit,
        c.segment_client,
        SUM(montant_total) as ca_jour,
        SUM(quantite) as quantite_jour,
        COUNT(DISTINCT client_id) as clients_jour,
        COUNT(*) as transactions_jour,
        -- Métriques spécifiques canal
        CASE WHEN canal_vente = 'EN_LIGNE' THEN 
            AVG(EXTRACT(EPOCH FROM (date_livraison - date_transaction))/3600)
        ELSE NULL END as delai_livraison_heures,
        -- Taux de conversion
        COUNT(DISTINCT CASE WHEN statut_livraison = 'LIVRÉ' THEN client_id END) * 100.0 / 
        COUNT(DISTINCT client_id) as taux_conversion_pct
    FROM fact_transaction_omnicanal_molap f
    JOIN dim_produit p ON f.produit_key = p.produit_key
    JOIN dim_client c ON f.client_key = c.client_key
    WHERE date_transaction >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY DATE_TRUNC('day', date_transaction), canal_vente, p.categorie_produit, c.segment_client
),
historical_data_rolap AS (
    -- Données historiques : agrégations ROLAP optimisées
    SELECT 
        DATE_TRUNC('month', date_transaction) as mois,
        canal_vente,
        p.categorie_produit,
        c.segment_client,
        SUM(montant_total) as ca_mois,
        SUM(quantite) as quantite_mois,
        COUNT(DISTINCT client_id) as clients_mois,
        COUNT(*) as transactions_mois,
        -- Tendances historiques
        LAG(SUM(montant_total), 12) OVER (
            PARTITION BY canal_vente, p.categorie_produit 
            ORDER BY DATE_TRUNC('month', date_transaction)
        ) as ca_meme_mois_an_precedent
    FROM fact_transaction_omnicanal f
    JOIN dim_produit p ON f.produit_key = p.produit_key
    JOIN dim_client c ON f.client_key = c.client_key
    WHERE date_transaction < CURRENT_DATE - INTERVAL '6 months'
    GROUP BY DATE_TRUNC('month', date_transaction), canal_vente, p.categorie_produit, c.segment_client
)
SELECT * FROM recent_data_molap
UNION ALL
SELECT 
    mois as jour, -- Uniformisation des colonnes
    canal_vente,
    categorie_produit,
    segment_client,
    ca_mois as ca_jour,
    quantite_mois as quantite_jour,
    clients_mois as clients_jour,
    transactions_mois as transactions_jour,
    NULL as delai_livraison_heures,
    NULL as taux_conversion_pct
FROM historical_data_rolap;

-- Procédure de maintenance HOLAP
CREATE OR REPLACE PROCEDURE maintenance_holap()
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff_date DATE := CURRENT_DATE - INTERVAL '6 months';
    v_molap_count INTEGER;
    v_rolap_count INTEGER;
BEGIN
    -- Transfert des données de ROLAP vers MOLAP
    INSERT INTO fact_transaction_omnicanal_molap
    SELECT * FROM fact_transaction_omnicanol_2023
    WHERE date_key >= EXTRACT(YEAR FROM v_cutoff_date) * 10000 + 
              EXTRACT(MONTH FROM v_cutoff_date) * 100 + 01;
    
    -- Nettoyage des anciennes données MOLAP
    DELETE FROM fact_transaction_omnicanol_molap
    WHERE date_key < EXTRACT(YEAR FROM v_cutoff_date) * 10000 + 
              EXTRACT(MONTH FROM v_cutoff_date) * 100 + 01;
    
    -- Rafraîchissement des vues matérialisées
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_omnicanal;
    
    -- Validation de la cohérence
    SELECT COUNT(*) INTO v_molap_count FROM fact_transaction_omnicanol_molap;
    SELECT COUNT(*) INTO v_rolap_count FROM fact_transaction_omnicanol_2023;
    
    -- Logging pour monitoring
    INSERT INTO log_holap_maintenance(timestamp, action, molap_records, rolap_records)
    VALUES (CURRENT_TIMESTAMP, 'MAINTENANCE', v_molap_count, v_rolap_count);
    
    -- Optimisation des performances
    ANALYZE fact_transaction_omnicanol_molap;
    ANALYZE mv_analyse_omnicanal;
END;
$$;
```

#### 5.2 Monitoring et optimisation

```sql
-- Tableau de bord de performance HOLAP
CREATE VIEW v_performance_holap AS
WITH query_performance AS (
    SELECT 
        'MOLAP' as architecture,
        AVG(execution_time_ms) as avg_execution_time,
        MAX(execution_time_ms) as max_execution_time,
        COUNT(*) as nb_queries,
        SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) as cache_hits,
        ROUND(SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as cache_hit_ratio
    FROM system_query_log
    WHERE architecture = 'MOLAP'
        AND timestamp >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
    
    UNION ALL
    
    SELECT 
        'ROLAP' as architecture,
        AVG(execution_time_ms) as avg_execution_time,
        MAX(execution_time_ms) as max_execution_time,
        COUNT(*) as nb_queries,
        SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) as cache_hits,
        ROUND(SUM(CASE WHEN cache_hit THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as cache_hit_ratio
    FROM system_query_log
    WHERE architecture = 'ROLAP'
        AND timestamp >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
),
storage_metrics AS (
    SELECT 
        'MOLAP' as architecture,
        table_size_mb,
        index_size_mb,
        cache_size_mb,
        memory_usage_mb
    FROM system_storage_metrics
    WHERE architecture = 'MOLAP'
    
    UNION ALL
    
    SELECT 
        'ROLAP' as architecture,
        table_size_mb,
        index_size_mb,
        cache_size_mb,
        memory_usage_mb
    FROM system_storage_metrics
    WHERE architecture = 'ROLAP'
)
SELECT 
    qp.architecture,
    qp.avg_execution_time,
    qp.max_execution_time,
    qp.nb_queries,
    qp.cache_hit_ratio,
    sm.table_size_mb,
    sm.memory_usage_mb,
    -- Indicateurs de performance
    CASE 
        WHEN qp.avg_execution_time < 1000 THEN 'Excellent'
        WHEN qp.avg_execution_time < 3000 THEN 'Bon'
        WHEN qp.avg_execution_time < 5000 THEN 'Moyen'
        ELSE 'Insuffisant'
    END as performance_level,
    -- Recommandations automatiques
    CASE 
        WHEN qp.cache_hit_ratio < 50 THEN 'Augmenter la taille du cache'
        WHEN sm.memory_usage_mb > 0.8 * (SELECT total_memory_mb FROM system_config) THEN 'Optimiser les requêtes'
        WHEN qp.avg_execution_time > 3000 THEN 'Considérer pré-agrégations'
        ELSE 'Performance optimale'
    END as recommendation
FROM query_performance qp
JOIN storage_metrics sm ON qp.architecture = sm.architecture;
```

### 6. Exercices pratiques

#### 6.1 Exercice de sélection architecturale

**Énoncé** : Une entreprise de télécommunications avec 50M abonnés souhaite analyser l'utilisation de ses services. Les besoins :
- Analyse temps réel des appels (derniers 3 mois)
- Analyse historique des tendances (5 ans)
- Budget limité, équipe technique de 3 personnes
- Contrainte réglementaire de conservation 7 ans

**Travail demandé** :
1. Analyser les critères de sélection d'architecture
2. Proposer une solution HOLAP avec justification
3. Définir la stratégie de partitionnement
4. Évaluer les coûts et bénéfices

**Solution attendue** :
- Architecture HOLAP avec MOLAP pour 3 mois récents
- ROLAP pour données historiques
- Partitionnement temporel et par service
- Analyse coût-bénéfice détaillée

#### 6.2 Étude de cas migration

**Contexte** : Une banque souhaite migrer de ROLAP pur vers HOLAP pour améliorer les performances.

**Problèmes actuels** :
- Requêtes > 30 secondes sur données récentes
- Coût de stockage élevé
- Maintenance complexe des vues

**Questions d'analyse** :
1. Comment planifier la migration progressive ?
2. Quels indicateurs de performance mettre en place ?
3. Comment garantir la cohérence pendant la transition ?

### 7. Références académiques

#### 7.1 Références principales

**Kimball, R., & Ross, M.** (2003). *Entrepôts de données : guide pratique de modélisation dimensionnelle*.
- Chapitre 13 : Architecture OLAP
- Chapitre 14 : ROLAP vs MOLAP
- Chapitre 15 : Hybrid Solutions

**Codd, E.F., et al.** (1993). "Providing OLAP to User-Analysts: An IT Mandate". IBM Technical Report.
- Section 4 : OLAP Architectures
- Section 5 : Performance Considerations

#### 7.2 Références complémentaires

**Berson, A., & Smith, S.J.** (2004). *Data Warehousing, Data Mining, & OLAP*. TATA McGraw-Hill.
- Chapter 8 : OLAP Architectures
- Chapter 9 : Performance Optimization

**Cuzzocrea, A., & Moussa, R.** (2016). "Multi-Dimensional Database Modeling and Querying". ER 2016.
- Section 6 : Hybrid Architectures
- Section 7 : Performance Analysis

---

**Contact enseignant** : M. Sellami Mokhtar  
**Volume horaire total** : 8h (4h cours magistral + 4h travaux dirigés)  
**Évaluation** : Contrôle continu (10%) + Participation (10%) + TD (20%) + Exam final (60%)