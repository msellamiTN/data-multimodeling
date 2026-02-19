# TD0 — OLTP : comprendre les limites opérationnelles et la nécessité d’un DWH/OLAP (1h30)

## Objectifs

- Rappeler le modèle OLTP et son usage opérationnel.
- Mettre en évidence les limites d’OLTP pour l’analyse (performance, historique, agrégations).
- Motiver le passage vers un entrepôt de données (DWH) et OLAP.
- Produire un mini-diagnostic et un schéma cible simplifié.

## Prérequis rapides

- SQL de base : SELECT, INSERT, INDEX, agrégations simples.
- Notions de transactions ACID, clés primaires/étrangères.

## Jeu de données OLTP (extrait simplifié)

| client_id | nom | ville | segment |
| --- | --- | --- | --- |
| 1 | Alice Dupont | Paris | VIP |
| 2 | Bob Martin | Lyon | Standard |
| 3 | Charlie Durand | Paris | Standard |

| produit_id | nom | categorie | prix_standard |
| --- | --- | --- | --- |
| 10 | Laptop Pro | Électronique | 1200.0 |
| 11 | Smartphone X | Électronique | 800.0 |
| 12 | Chaise Bureau | Mobilier | 150.0 |

| commande_id | client_id | date_commande | statut |
| --- | --- | --- | --- |
| 1001 | 1 | 2024-01-15 | LIVRE |
| 1002 | 2 | 2024-01-16 | LIVRE |
| 1003 | 1 | 2024-02-01 | EN_COURS |

| commande_id | produit_id | quantite | prix_reel |
| --- | --- | --- | --- |
| 1001 | 10 | 1 | 1200.0 |
| 1001 | 12 | 2 | 140.0 |
| 1002 | 11 | 1 | 800.0 |
| 1003 | 12 | 1 | 150.0 |

## Travail demandé

1. **Modèle OLTP** : dessiner le schéma relationnel actuel (tables commandes, clients, produits) avec PK/FK.
2. **Requêtes opérationnelles (OLTP)** : écrire 3 requêtes typiques (ex. statut d’une commande, stock par produit, total d’une commande).
3. **Requêtes analytiques problématiques** : écrire 3 besoins décisionnels difficiles en OLTP :
   - CA mensuel par produit et par région.
   - Top 5 produits sur 6 mois glissants.
   - Taux d’annulation par canal.
   Expliquer pourquoi ces requêtes dégradent l’OLTP (verrous, scans, index inadaptés, absence d’historisation).
4. **Diagnostic** : lister 4 limites de l’OLTP pour l’analytique (performance, schéma normalisé, absence d’historique, charge transactionnelle).
5. **Cible DWH/OLAP** : proposer en 5 bullets ce que change un DWH (schéma en étoile, historisation, agrégations, séparation des charges, gouvernance) et dessiner un schéma Mermaid simple : sources OLTP → staging → DWH (étoile ventes) → BI/OLAP.

## Exemples SQL OLTP (scénarios concrets)

- **Statut de commande** (opérationnel) :

  ```sql
  SELECT statut
  FROM commandes
  WHERE commande_id = 1001;
  ```

- **Détail client** :

  ```sql
  SELECT nom, ville, segment
  FROM clients
  WHERE client_id = 1;
  ```

- **Total d'une commande** (somme lignes) :

  ```sql
  SELECT c.commande_id,
         SUM(lc.quantite * lc.prix_reel) AS total_ht
  FROM commandes c
  JOIN lignes_commande lc ON lc.commande_id = c.commande_id
  WHERE c.commande_id = 1001
  GROUP BY c.commande_id;
  ```

- **Requête analytique problématique (3 jointures + agrégat)** :

  ```sql
  SELECT strftime('%Y-%m', c.date_commande) AS mois,
         p.categorie,
         cl.ville,
         SUM(lc.quantite * lc.prix_reel) AS ca
  FROM commandes c
  JOIN lignes_commande lc ON lc.commande_id = c.commande_id
  JOIN produits p ON lc.produit_id = p.produit_id
  JOIN clients cl ON c.client_id = cl.client_id
  GROUP BY strftime('%Y-%m', c.date_commande), p.categorie, cl.ville
  ORDER BY mois, ca DESC;
  ```

  > À reproduire puis comparer avec la version matérialisée `fact_ventes` (voir notebook) pour mettre en évidence la différence OLTP vs pré-OLAP.

## Mini-cas à rejouer (aligné avec le notebook)

### 🎯 Objectif de l'exercice

Vous êtes consultant BI chez un e-commerçant qui rencontre des problèmes de performance sur son système opérationnel. Votre mission : démontrer les limites de l'OLTP et proposer une solution OLAP en utilisant le notebook comme support de démonstration.

---

### 📋 Exercice 1 : Diagnostic des performances OLTP

**Contexte** : Le service commercial se plaint que le dashboard "CA mensuel par catégorie et ville" met plus de 30 secondes à se charger.

**Votre mission** :
1. **Analyser** la requête problématique ci-dessous
2. **Identifier** les goulots d'étranglement
3. **Expliquer** pourquoi cette requête dégrade les performances du système transactionnel

**Requête à analyser** :
```sql
-- Requête actuelle (problématique)
SELECT 
    strftime('%Y-%m', c.date_commande) AS mois,
    p.categorie,
    cl.ville,
    SUM(lc.quantite * lc.prix_reel) AS ca_mensuel,
    COUNT(DISTINCT c.commande_id) AS nb_commandes
FROM commandes c
JOIN lignes_commande lc ON lc.commande_id = c.commande_id
JOIN produits p ON lc.produit_id = p.produit_id
JOIN clients cl ON c.client_id = cl.client_id
WHERE c.statut = 'LIVRE'
GROUP BY strftime('%Y-%m', c.date_commande), p.categorie, cl.ville
ORDER BY mois, ca_mensuel DESC;
```

**Questions guides** :
- Quelles sont les 3 jointures obligatoires ?
- Pourquoi l'agrégation est-elle coûteuse ?
- Quel est l'impact sur les transactions concurrentes ?
- Quels index manquent pour ce type de requête ?

---

### 📋 Exercice 2 : Conception de la solution OLAP

**Contexte** : Vous devez proposer une architecture qui résout ces problèmes de performance.

**Votre mission** :
1. **Concevoir** une table de faits `fact_ventes` optimisée
2. **Écrire** le script ETL de transformation
3. **Démontrer** le gain de performance

**Structure cible de la table de faits** :
```sql
-- Table à concevoir
CREATE TABLE fact_ventes (
    mois TEXT,           -- '2024-01'
    categorie TEXT,      -- 'Électronique', 'Mobilier'...
    ville TEXT,          -- 'Paris', 'Lyon'...
    montant REAL,        -- CA mensuel
    nb_commandes INTEGER -- Nombre de commandes
);
```

**Étapes à réaliser** :
- **Étape 2.1** : Écrire le CREATE TABLE complet avec contraintes
- **Étape 2.2** : Écrire l'ETL (INSERT INTO...SELECT) qui peuple la table
- **Étape 2.3** : Écrire la requête OLAP équivalente (simple, sans jointure)
- **Étape 2.4** : Expliquer les avantages de cette approche

---

### 📋 Exercice 3 : Comparaison et justification

**Contexte** : Vous devez convaincre le DSI d'adopter cette nouvelle architecture.

**Votre mission** : Rédiger une argumentation structurée en 3 points :

1. **Performance technique** : Pourquoi la requête est plus rapide ?
2. **Indexation optimisée** : Quels index créer et pourquoi ?
3. **Séparation des charges** : Quels bénéfices pour l'exploitation ?

**Format attendu** : 3 bullets argumentés avec exemples concrets.

---

### 📋 Exercice 4 : Démonstration pratique (optionnel)

**Contexte** : Validation par la preuve.

**Votre mission** :
1. **Exécuter** les deux requêtes dans le notebook TD0
2. **Mesurer** les temps d'exécution
3. **Comparer** les résultats
4. **Capturer** les outputs pour illustrer votre rapport

**Résultats à documenter** :
- Temps d'exécution OLTP vs OLAP
- Nombre de lignes scannées dans chaque cas
- Complexité des plans d'exécution

---

### 📋 Exercice 5 : Plan de migration

**Contexte** : Passage de la théorie à la pratique.

**Votre mission** : Détailler le plan de migration en 5 étapes clés :

1. **Extract** : Comment extraire les données depuis l'OLTP ?
2. **Nettoyer** : Quelles transformations appliquer ?
3. **Conformer dimensions** : Comment structurer les dimensions ?
4. **Charger facts** : Comment peupler la table de faits ?
5. **Publier vues/OLAP** : Comment rendre les données accessibles ?

**Livrable attendu** : Plan d'action avec durée estimée par étape.

---

### 🎯 Critères de réussite

- **Compréhension** : Vous expliquez clairement les problèmes OLTP
- **Solution** : Vous proposez une architecture OLAP cohérente
- **Argumentation** : Vous justifiez vos choix techniques
- **Pratique** : Vous validez par la démonstration dans le notebook
- **Vision** : Vous proposez un plan de migration réaliste

## Déroulé (1h30)

- 10 min : rappel OLTP, ACID, normalisation.
- 20 min : schéma OLTP + 3 requêtes opérationnelles.
- 25 min : formuler les requêtes analytiques et expliquer les freins en OLTP.
- 20 min : définir la cible DWH/OLAP et dessiner le flux Mermaid.
- 15 min : plan minimal de passage + restitution orale brève.

## Livrables

- Markdown : schéma OLTP, requêtes OLTP/analytiques, diagnostic des limites, schéma cible DWH/OLAP (Mermaid), plan de passage.
- (Optionnel) SQL : script des requêtes OLTP.

## Critères de réussite

- Problèmes OLTP clairement identifiés et reliés aux requêtes analytiques.
- Schéma cible DWH/OLAP cohérent (séparation charges, étoile simplifiée, historisation implicite).
- Plan de passage synthétique et réaliste.

## Questions de qualité (scénarios)

1. **Qualité des transactions** : citer 2 raisons pour lesquelles l’OLTP doit privilégier des opérations courtes et atomiques (ACID) et pourquoi les agrégations longues posent problème.
2. **Qualité du schéma** : comment la normalisation aide l’OLTP mais complique l’analytique ? Donner un exemple de jointures supplémentaires.
3. **Qualité des requêtes** : sur la requête CA mensuel, indiquer quelles colonnes pourraient être indexées et pourquoi cela reste insuffisant si l’on garde l’OLTP pour l’analyse.
4. **Qualité des données/historique** : que manque-t-il souvent en OLTP pour faire des analyses temporelles fiables (SCD, historique de prix, statut) ?
5. **Séparation OLTP/OLAP** : donner 3 bénéfices concrets de séparer les workloads (perf, gouvernance, disponibilité) et 1 risque (décalage de fraîcheur).

## Exemple de schéma cible (Mermaid)

```mermaid
graph TD
  A[Sources OLTP] --> B[Staging]
  B --> C[DWH - étoile ventes]
  C --> D[OLAP / Vues agrégées]
  D --> E[BI / Dashboards]
```
