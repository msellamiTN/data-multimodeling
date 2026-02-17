# Correction TD0 — Limites OLTP et transition DWH/OLAP

## Diagnostic OLTP

- **Requêtes opérationnelles typiques** : SELECT/FROM/WHERE simples pour transactions (ex. : stock produit P01 à M01).
- **Limites** : Pas d'analyses multi-dimensionnelles (ex. : évolution CA par catégorie/mois).
- **Performance** : Normalisée ⇒ jointures coûteuses pour agrégations.

## Schéma OLTP (exemple simple)

```mermaid
erDiagram
  PRODUIT ||--o{ VENTE : "produit_id"
  MAGASIN ||--o{ VENTE : "magasin_id"
  VENTE {
    vente_id PK
    produit_id FK
    magasin_id FK
    quantite
    montant
  }
```

## Cibles DWH/OLAP

- **DWH** : Stockage historique, intégré, orienté analyse.
- **OLAP** : Cube multi-dimensions pour slice/dice/roll-up.
- **Transition** : ETL pour charger depuis OLTP vers DWH.

## Plan de passage (3 étapes)

1. **Audit OLTP** : Identifier sources, grain, volumétrie.
2. **Modélisation DWH** : Étoile/flocon, dimensions/faits.
3. **ETL initial** : Charger données historiques.

## Livrables attendus

- Diagnostic écrit : 3 limites OLTP avec exemples.
- Schéma cible : DWH étoile simple (Mermaid).
- Plan transition : 3 étapes avec responsabilités.

## Pour aller plus loin

- Comparer OLTP vs DWH sur ROI (coûts stockage vs gains analyse).
- Discuter governance (qualité, sécurité données).
