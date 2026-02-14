# Chapitre B — Entrepôts de données : concepts et architecture

## Objectifs d’apprentissage

- Définir ED, data mart, ODS, métadonnées.
- Expliquer la chaîne d’alimentation ETL/ELT.

## Contenus

- Propriétés d’un ED (intégration, historisation, disponibilité).
- Typologie : ED central, data marts dépendants/indépendants.
- Métadonnées techniques et métiers.

### Contexte métier (retail multi-magasin)

- Sources : POS, CRM, e-commerce.
- Besoin : historiser les ventes, consolider la vision client, suivre la performance par région.
- Douleurs : données incohérentes entre canaux, latence des rapports, absence d’historique.

## Exemple minimal

- Consolidation ventes + CRM vers un entrepôt unique.

### Exemple SQL (vue staging simplifiée)

```sql
-- Consolidation des ventes web + magasin dans une vue unique
CREATE VIEW stg_ventes_unifiees AS
SELECT date_vente, produit_id, magasin_id, montant, quantite
FROM ventes_magasin
UNION ALL
SELECT date_commande AS date_vente, produit_id, canal AS magasin_id, montant, quantite
FROM ventes_web;
```

## Erreurs fréquentes / pièges

- Mélanger ODS et ED (temps réel vs historisation).
- Négliger la gouvernance des métadonnées.

## Mini-exercice

- Citer 3 propriétés attendues d’un ED et justifier en une phrase chacune.
- Indiquer pourquoi un ODS n’est pas un ED (2 raisons).

## Pour aller plus loin (self-training)

- Dessiner la chaîne ETL d’une journée type (extraction, contrôle qualité, chargement incrémental).
- Écrire un script de contrôle qualité minimal (doublons, valeurs manquantes) sur la table de staging.
- Comparer deux architectures : ED central + marts dépendants vs ensemble de marts indépendants.

## Références rapides

- Kimball & Ross — chapitres architecture ED et ETL.
- Berson & Smith, *Data Warehousing, Data Mining & OLAP* (parties sur ETL et stockage).

## Diagramme ETL (Mermaid)

```mermaid
flowchart LR
  A[Systèmes sources] --> B[Extraction]
  B --> C[Transformation]
  C --> D[Chargement ED]
  D --> E[Data Marts]
  E --> F[Analyses/BI]
```
