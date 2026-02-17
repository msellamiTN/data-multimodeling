# Travaux Dirigés — Modélisation Multidimensionnelle et Entrepôts de Données

> **Volume horaire total : 16h** | **Crédits : 0.8** | **Coefficient : 0.6**  
> **Références : Kimball & Ross (2003), Syllabus MMD S4, Cuzzocrea & Moussa (2016)**

## Positionnement pédagogique

Les travaux dirigés constituent le complément pratique indispensable au cours magistral. Ils permettent l'assimilation progressive des concepts théoriques à travers des études de cas réelles et des exercices concrets. La progression par niveaux (débutant → intermédiaire → avancé) assure une montée en compétence structurée.

## Objectifs pédagogiques généraux

À l'issue des travaux dirigés, l'étudiant sera capable de :

1. **Appliquer** les principes de modélisation dimensionnelle sur des cas concrets
2. **Concevoir** des schémas en étoile et en flocon selon les exigences métier
3. **Naviguer** efficacement dans des cubes OLAP avec les opérations roll-up, drill-down, slice, dice
4. **Justifier** le choix d'une architecture ROLAP/MOLAP/HOLAP selon le contexte
5. **Évaluer** la qualité d'une solution décisionnelle selon des critères objectifs

## Organisation des TD

### TD1 — Modèle en étoile (Semaine 2)

**Niveau** : Débutant  
**Volume** : 4h (2h encadré + 2h travail personnel)  

**Objectifs spécifiques** :

- Comprendre la structure d'un schéma en étoile
- Identifier les tables de faits et de dimensions
- Concevoir un modèle dimensionnel simple
- Justifier les choix de modélisation

**Compétences visées** :

- Application des concepts de base
- Analyse de données opérationnelles
- Conception de schéma décisionnel

### TD2 — OLAP : Opérations (Semaine 3)

**Niveau** : Intermédiaire  
**Volume** : 4h (2h encadré + 2h travail personnel)  

**Objectifs spécifiques** :

- Maîtriser les opérations OLAP fondamentales
- Comprendre la navigation multidimensionnelle
- Interpréter les résultats d'analyses OLAP
- Rédiger des requêtes analytiques complexes

**Compétences visées** :

- Navigation dans les cubes OLAP
- Analyse multidimensionnelle
- Interprétation de résultats

### TD3 — Choix d'architecture (Semaine 4)

**Niveau** : Avancé  
**Volume** : 8h (4h encadré + 4h travail personnel)  

**Objectifs spécifiques** :

- Analyser les critères de choix d'architecture
- Comparer ROLAP, MOLAP et HOLAP
- Évaluer les performances et coûts
- Proposer une architecture optimisée

**Compétences visées** :

- Analyse comparative
- Prise de décision technique
- Justification argumentée

## Méthodologie de travail

### Déroulement type d'une séance

1. **Mise en contexte** (15 min) : Rappel des concepts théoriques pertinents
2. **Présentation du cas** (20 min) : Description du problème métier et des données
3. **Phase de recherche** (45 min) : Travail individuel ou en binôme
4. **Synthèse collective** (30 min) : Partage des solutions et débats
5. **Correction détaillée** (10 min) : Présentation de la solution attendue

### Livrables attendus

**Pour chaque TD** :

- Modélisation dimensionnelle (schéma Mermaid)
- Justifications des choix de conception
- Réponses aux questions théoriques
- Code SQL ou requêtes OLAP si applicable

**Format de soumission** :

- Document Markdown avec schémas intégrés
- Code commenté et justifié
- Analyse critique personnelle

## Évaluation des TD

### Barème de notation

| Critère | Pondération | Évaluation |
| --- | --- | --- |
| Compréhension du problème | 20% | Analyse correcte du besoin |
| Qualité de la modélisation | 30% | Pertinence du schéma dimensionnel |
| Justification des choix | 25% | Argumentation cohérente |
| Originalité de la solution | 15% | Innovation et optimisation |
| Présentation et clarté | 10% | Structuration et lisibilité |

### Niveaux de maîtrise

- **A (16-20)** : Excellente maîtrise, solution complète et innovante
- **B (14-15)** : Bonne maîtrise, solution correcte bien justifiée
- **C (12-13)** : Maîtrise satisfaisante, solution fonctionnelle
- **D (10-11)** : Maîtrise partielle, solution incomplète
- **E (<10)** : Insuffisant, concepts non maîtrisés

## Ressources pédagogiques

### Documentation de référence

**Kimball, R., & Ross, M.** (2003). *Entrepôts de données : guide pratique de modélisation dimensionnelle*.

- Chapitre 3 : Modélisation dimensionnelle de base
- Chapitre 4 : Techniques avancées de modélisation
- Chapitre 8 : Architecture OLAP

### Curriculum Avancé (Modern Data Stack)

Pour aller plus loin (niveau M1/Ingénieur), les TD intègrent désormais des notions de :
- **Modern Data Stack** : ELT vs ETL, Cloud Data Warehousing (Snowflake, BigQuery).
- **Modélisation Complexe** : Bridge Tables (Many-to-Many), SCD Type 2/3.
- **Qualité des Données** : Frameworks de validation automatisée.

**Cuzzocrea, A., & Moussa, R.** (2016). *Multi-Dimensional Database Modeling and Querying*.

- Section 4.1 : Patterns de modélisation
- Section 5.3 : Techniques d'optimisation OLAP

### Outils et plateformes

**Environnement de développement** :

- MySQL Workbench pour la modélisation
- DBeaver pour l'exécution de requêtes SQL
- Draw.io pour les schémas complémentaires

**Plateformes OLAP (démonstration)** :

- Apache Kylin pour ROLAP
- Apache Druid pour OLAP temps réel
- Microsoft SSAS pour MOLAP

### Cas d'étude complémentaires

1. **Retail Analytics** : Analyse des ventes d'une chaîne de magasins
2. **Banking Dashboard** : Tableau de bord de risques bancaires
3. **Healthcare Metrics** : Indicateurs de performance hospitalière
4. **Supply Chain** : Optimisation de la chaîne logistique

## Auto-évaluation et preparation

### Questions de vérification

**Avant TD1** :

- Qu'est-ce qu'une table de faits ? Une table de dimensions ?
- Quelle est la différence entre grain et granularité ?
- Pourquoi utilise-t-on des clés substituées ?

**Avant TD2** :

- Définir roll-up, drill-down, slice, dice
- Comment représente-t-on un cube OLAP ?
- Quelle est la sémantique d'une hiérarchie ?

**Avant TD3** :

- Quels sont les critères de performance d'une architecture OLAP ?
- Comment choisir entre ROLAP et MOLAP ?
- Qu'est-ce que l'architecture HOLAP ?

### Exercices de préparation

**Exercice 1** : Analyser un schéma existant et identifier les faits/dimensions

**Exercice 2** : Proposer une hiérarchie pour une dimension temps

**Exercice 3** : Comparer deux architectures OLAP sur un cas simple

### Banque de questions-types (réutilisables dans les TD)

- **Schéma en étoile (eShopPlus)** : Identifier la table de faits ventes (mesures : montant, quantité) et détailler 4 dimensions (produit, client, temps, région). Dessiner le schéma en étoile.
- **Schéma en flocon (logistique)** : Normaliser les dimensions localisation (entrepôt → ville → région → pays) et montrer la table de faits livraisons (mesures : coût, poids). Expliquer l’intérêt (réduction de redondance, plus de jointures).
- **Schéma en galaxie (ventes + retours)** : Deux faits (ventes, retours) partageant produit, client, temps ; dimensions spécifiques (canal de vente, motif de retour). Représenter la constellation.
- **Étude de cas université** : Proposer faits (inscriptions, résultats) et dimensions (étudiant, cours, enseignant, temps), choisir étoile/flocon/galaxie et argumenter. Dessiner le schéma retenu.

---

## Calendrier et planning

| Semaine | TD | Thème principal | Évaluation |
| --- | --- | --- | --- |
| 2 | TD1 | Modèle en étoile | Notation individuelle |
| 3 | TD2 | Opérations OLAP | Notation individuelle |
| 4 | TD3 | Architecture OLAP | Notation individuelle + synthèse |

**Total TD** : 16h encadrées + 8h travail personnel = 24h

---

**Coordination** : M. Sellami Mokhtar  
**Support technique** : Assistants d'informatique de gestion  
**Disponibilité** : Permanence jeudi 14h-16h (bureau H203)
