# Mini-projet — Modélisation multidimensionnelle et OLAP (L3)

## 🎯 Objectifs

- Concevoir un petit entrepôt de données et un cube OLAP pour un cas retail multi-canal.
- Produire : schéma en étoile, scripts SQL de base, exemples de requêtes OLAP, jeu de tests minimal.
- Développer une approche complète de la modélisation à l'exploitation.

## 🏪 Scénario Détaillé

### Entreprise : "RetailMix"
**Chaine de distribution omnicanal** avec :
- **15 magasins physiques** en France (Paris, Lyon, Marseille, etc.)
- **Site e-commerce** national
- **3 canaux de vente** : Magasin, Web, Mobile
- **5000 produits** répartis en 8 catégories (Électronique, Mode, Maison, etc.)
- **100 000 clients** avec segments (VIP, Standard, Occasionnel)

### Problématique Métier
La direction souhaite analyser les performances commerciales pour :
- **Optimiser l'assortiment** par magasin et canal
- **Identifier les tendances** saisonnières et géographiques  
- **Personnaliser les offres** par segment client
- **Mesurer l'impact** des promotions croisées canaux

### Données Disponibles
- **Transactions** : 2 ans d'historique (2023-2024)
- **Catalogue produits** : Hiérarchie catégorie → sous-catégorie
- **Clients** : Démographie, segment, date d'inscription
- **Magasins** : Localisation, surface, type (centre-ville, zone commerciale)
- **Promotions** : Campagnes multi-produits avec dates et canaux

## 📦 Livrables Attendus

### 1. 📊 Conception du Schéma (4 points)
**Diagramme Mermaid ER complet** avec :
- **Dimensions obligatoires** :
  - `DIM_DATE` : hiérarchie jour→semaine→mois→trimestre→année
  - `DIM_PRODUIT` : catégorie→sous-catégorie→produit, prix, marque
  - `DIM_CLIENT` : segment, démographie, ancienneté
  - `DIM_MAGASIN` : région→ville→magasin, surface, type
  - `DIM_CANAL` : magasin, web, mobile
- **Table de faits** : `FACT_VENTE` avec mesures `montant_ht`, `quantite`, `montant_remise`
- **Options avancées** (bonus) :
  - **SCD Type 2** sur `DIM_CLIENT` (gestion des changements de segment)
  - **Bridge Table** pour promotions multiples par vente

### 2. 💾 Scripts SQL (3 points)
**Création et alimentation** :
- **DDL** : CREATE TABLE avec contraintes PK/FK, types appropriés
- **DML** : Jeu d'essai cohérent :
  - ~50 lignes dans `FACT_VENTE`
  - 365 jours dans `DIM_DATE` (2024)
  - 20 produits dans `DIM_PRODUIT`
  - 10 magasins dans `DIM_MAGASIN`
  - 100 clients dans `DIM_CLIENT`
- **Contraintes** : Clés étrangères valides, pas de doublons

### 3. 🔍 Requêtes OLAP (3 points)
**3 requêtes analytiques avec résultats attendus** :
- **Roll-up** : CA mensuel par catégorie et région
- **Drill-down** : Ventes journalières d'une catégorie par magasin
- **Slice/Dice** : Top 5 produits VIP par canal sur Q4 2024
- **Calcul** : Panier moyen et taux de remise par segment

### 4. ✅ Qualité & Gouvernance (3 points)
**5 contrôles qualité avec scripts SQL** :
1. **Intégrité** : FK manquantes dans `FACT_VENTE`
2. **Exhaustivité** : Jours manquants dans `DIM_DATE`
3. **Cohérence** : Montants négatifs injustifiés
4. **Doublons** : Ventes identiques même jour/produit/client
5. **Densité** : Dimensions vides ou inutilisées

### 5. 📝 Note d'Architecture (2 points)
**Synthèse décisionnelle (10 lignes max)** :
- **Choix ROLAP/MOLAP/HOLAP** avec justification
- **Fréquence de rafraîchissement** (quotidien/hebdomadaire)
- **Volume estimé** et **performances** attendues
- **Évolutions possibles** (nouvelles dimensions, prévisions)

## 🗓️ Étapes du Projet

### Semaine 1 : Analyse et Conception
- **Jour 1-2** : Compréhension du scénario et collecte des besoins
- **Jour 3-4** : Modélisation conceptuelle (dimensions, mesures, granularité)
- **Jour 5** : Validation du schéma et début du DDL

### Semaine 2 : Développement SQL
- **Jour 1-2** : Écriture des CREATE TABLE (dimensions puis faits)
- **Jour 3-4** : Création du jeu d'essai cohérent
- **Jour 5** : Tests d'intégrité et corrections

### Semaine 3 : OLAP et Qualité
- **Jour 1-2** : Écriture des requêtes analytiques
- **Jour 3-4** : Développement des scripts de contrôle qualité
- **Jour 5** : Finalisation de la note d'architecture

### Semaine 4 : Finalisation
- **Jour 1-2** : Tests bout-en-bout et validation des résultats
- **Jour 3-4** : Documentation et mise en forme des livrables
- **Jour 5** : Revue finale et préparation soutenance

## 📊 Barème Détaillé

| Critère | Sous-critères | Points |
|---|---|---|
| **Schéma** | Dimensions complètes, granularité correcte, clés PK/FK | 4 |
| **SQL** | DDL propre, jeu d'essai cohérent, contraintes respectées | 3 |
| **Requêtes** | Exactitude, complexité OLAP, résultats exploitables | 3 |
| **Qualité** | 5 contrôles pertinents, scripts fonctionnels | 3 |
| **Architecture** | Choix justifiés, vision réaliste, synthèse claire | 2 |
| **Total** | | **15** |

## 🎯 Bonus Potentiels

### +1 Point : SCD Type 2
- Gestion de l'historique des changements de segment client
- Colonnes `valid_from`, `valid_to`, `is_current`

### +1 Point : Bridge Table
- Gestion des promotions multiples par vente
- Table `PROMOTION_VENTE` avec FK vers `FACT_VENTE`

### +1 Point : Performance
- Index optimisés pour les requêtes OLAP
- Vues matérialisées pour les agrégats fréquents

## 📚 Ressources

### Références principales
- **Kimball & Ross** : "The Data Warehouse Toolkit" (modélisation, ETL, OLAP)
- **Notes de cours** : Chapitres A–E (concepts, schéma, requêtes)

### Outils recommandés
- **Modélisation** : Mermaid, draw.io, Lucidchart
- **SQL** : SQLite (test), PostgreSQL (production)
- **Documentation** : Markdown, Git

## 💡 Conseils Pratiques

### 🎯 Périmètre maîtrisé
- **Jeu d'essai compact** mais représentatif
- **Complexité raisonnable** pour le temps imparti
- **Focus sur la cohérence** plutôt que le volume

### 🔧 Qualité avant quantité
- **Valider les FK** avant de peupler les faits
- **Documenter les hypothèses** (ex: une vente = un produit par ligne)
- **Tester chaque requête** sur le jeu d'essai

### 📋 Organisation
- **Versionner** les scripts SQL avec commentaires
- **Structurer** les livrables par dossier (schema/, sql/, requetes/, tests/)
- **Préparer** une démonstration courte (5 min)

---

**🚀 Ce mini-projet est une excellente porte d'entrée dans le monde de la Business Intelligence !**
