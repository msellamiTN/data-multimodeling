# Correction TD3 — Choix architecture OLAP

## Choix recommandé : HOLAP

- **Justification** :
  - Détails volumineux (5 ans) en ROLAP pour flexibilité ad hoc/historique.
  - Agrégés récents (60j) en MOLAP pour rapidité tableaux de bord quotidiens.
  - Budget limité : mix évite stockage MOLAP massif sur tout l'historique.
  - Volumétrie : 50M/an ⇒ détails ROLAP, agrégés MOLAP sur 60j (volume raisonnable).
  - SLA : <5s sur récents ⇒ MOLAP ; <20s ad hoc ⇒ ROLAP.

## Plan d’actualisation

- **Agrégés récents (60j)** : daily (fin nuit, <2h) pour cubes MOLAP.
- **Historique (>60j)** : hebdo/mensuel pour ROLAP (rebuild agrégés).
- **Latence** : requêtes récentes <5s ; ad hoc <20s ; rafraîchissement <2h.

## Schéma de flux

```mermaid
flowchart TD
  A[Systèmes sources] --> B[Staging]
  B --> C[Entrepôt ROLAP (détails)]
  C --> D[Cubes MOLAP (agrégés récents)]
  D --> E[BI/Tableaux de bord]
  C --> F[Requêtes ad hoc ROLAP]
```

## Risques et parades

1. **Coût stockage MOLAP** : Limiter plage agrégés (60j), archiver froid >3 ans.
2. **Cohérence agrégés** : Process ETL unique, rebuild cube après load.
3. **Performance requêtes** : Monitor SLA, ajuster index ROLAP/cubes MOLAP.

## Mini-SLA

- **Tableaux de bord (récents)** : <5s réponse.
- **Requêtes ad hoc (historique)** : <20s.
- **Rafraîchissement** : daily <2h ; hebdo/mensuel <4h.

## Tableau comparatif (ROLAP vs MOLAP vs HOLAP)

| Critère          | ROLAP                          | MOLAP                          | HOLAP                          |
|------------------|--------------------------------|--------------------------------|--------------------------------|
| Latence          | Moyenne (<20s ad hoc)          | Excellente (<5s agrégés)       | Excellente récent, moyenne hist|
| Coût stockage    | Faible                         | Élevé                          | Moyen                          |
| Gouvernance      | Flexible, requêtes libres      | Pré-agrégés, moins flexible   | Mix, équilibré                 |

## Livrables attendus

- Note 1 page avec choix HOLAP, justification, SLA.
- Schéma Mermaid.
- Tableau comparatif.
