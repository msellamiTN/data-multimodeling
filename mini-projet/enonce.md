# Mini-projet — Modélisation multidimensionnelle et OLAP (L3)

## Objectifs

- Concevoir un petit entrepôt de données et un cube OLAP pour un cas retail multi-canal.
- Produire : schéma en étoile, scripts SQL de base, exemples de requêtes OLAP, jeu de tests minimal.

## Contexte

Retail (magasins + e-commerce) : ventes, catalogue produits, clients, magasins, canaux.

## Livrables attendus

1) **Schéma** :
- Diagramme Mermaid ER (étoile ou étoile + flocon limité).
- Tables : dimensions (date, produit, client, magasin, canal), fact ventes (granularité ligne de transaction).

2) **Scripts SQL** :
- Création des tables dims/fact.
- Exemples d’inserts (jeu d’essai minimal ~20 lignes fact, dims cohérentes).

3) **Requêtes OLAP** :
- CA mensuel par catégorie et par magasin (roll-up jour→mois).
- Top 5 produits par mois (fenêtres ou agrégations + filtre).
- Slice/dice (magasin, période) avec résultats attendus sur le jeu d’essai.

4) **Qualité/Gouvernance** :
- 5 règles de contrôle (doublons, dates invalides, FK manquantes, montants négatifs injustifiés, densité des dimensions).

5) **Courte note** (10 lignes max) :
- Choix d’architecture (ROLAP/MOLAP/HOLAP) et plan d’actualisation.

## Barème (exemple)

| Critère | Points |
| --- | --- |
| Schéma correct (dims/fact, granularité, clés) | 4 |
| SQL (création + inserts) | 3 |
| Requêtes OLAP (exactitude) | 3 |
| Contrôles qualité + note d’architecture | 3 |
| Clarté/structure du livrable | 2 |
| Total | 15 |

## Ressources

- Références principales : Kimball & Ross (modélisation, ETL, OLAP).
- Notes de cours Chapitres A–E.

## Conseils

- Rester sur un périmètre simple mais cohérent (jeu d’essai compact).
- Vérifier la cohérence des clés étrangères avant de peupler la fact.
- Documenter les hypothèses métier (ex : une vente = un produit par ligne, devise unique).
