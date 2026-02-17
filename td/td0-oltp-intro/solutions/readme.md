# Correction TD0 — Limites OLTP et transition DWH/OLAP

## Diagnostic OLTP

- **Requêtes opérationnelles typiques** : SELECT/FROM/WHERE simples pour transactions (ex. : stock produit P01 à M01).
- **Limites** : Pas d'analyses multi-dimensionnelles (ex. : évolution CA par catégorie/mois).
- **Performance** : Normalisée ⇒ jointures coûteuses pour agrégations.

## Schéma OLTP (exemple simple, coloré)

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor': '#e3f2fd', 'primaryBorderColor': '#1565c0', 'secondaryColor': '#fff3e0', 'secondaryBorderColor': '#ef6c00'}}}%%
erDiagram
  classDef dim fill:#E3F2FD,stroke:#1565C0,stroke-width:1.5px;
  classDef fact fill:#FFF3E0,stroke:#EF6C00,stroke-width:1.5px;

  PRODUIT ||--o{ VENTE : "produit_id"
  MAGASIN ||--o{ VENTE : "magasin_id"
  CLIENT ||--o{ VENTE : "client_id"

  PRODUIT:::dim {
    produit_id PK
    produit_nom
    categorie
  }
  MAGASIN:::dim {
    magasin_id PK
    ville
    region
  }
  CLIENT:::dim {
    client_id PK
    nom
    segment
  }
  VENTE:::fact {
    vente_id PK
    produit_id FK
    magasin_id FK
    client_id FK
    quantite
    montant
    date_vente
  }
```

## Cibles DWH/OLAP

- **DWH** : Stockage historique, intégré, orienté analyse.
- **OLAP** : Cube multi-dimensions pour slice/dice/roll-up.
- **Transition** : ETL pour charger depuis OLTP vers DWH.

### Exemples SQL OLTP (référence)

- Statut de commande : `SELECT statut FROM commandes WHERE commande_id = 101;`
- Stock par produit : `SELECT p.produit_id, p.nom, s.quantite_dispo FROM stock s JOIN produits p ON p.produit_id = s.produit_id WHERE p.produit_id = 'P10';`
- Total d’une commande : `SELECT c.commande_id, SUM(lc.quantite * lc.prix_unitaire) AS total_ht FROM commandes c JOIN lignes_commande lc ON lc.commande_id = c.commande_id WHERE c.commande_id = 101 GROUP BY c.commande_id;`
- Analytique coûteuse en OLTP (3 jointures + agrégat) : CA mensuel par catégorie/ville sur `commandes`, `lignes_commande`, `produits`, `clients`.

> Voir le notebook TD0 : il reproduit cette requête puis la compare à une version matérialisée `fact_ventes` (pré-OLAP) pour montrer la réduction des jointures et l’intérêt de séparer OLTP/OLAP.

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
