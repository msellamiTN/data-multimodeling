# TD3 — Choix d’architecture (ROLAP / MOLAP / HOLAP) — niveau avancé

## Objectifs

- Choisir une architecture OLAP adaptée à un contexte métier et à des contraintes (volume, réactivité, coût).
- Argumenter et proposer un plan d’actualisation.

## Contexte

Entreprise retail avec :
- Historique 5 ans de transactions (fort volume, peu requêté).
- Tableau de bord quotidien sur les 60 derniers jours (fortement consulté).
- Budget limité pour le stockage MOLAP massif.

## Travail demandé

1. Proposer une architecture (ROLAP / MOLAP / HOLAP) et la justifier en 5 bullet points.
2. Proposer un plan d’actualisation (fréquence des agrégés/cubes, latence acceptée).
3. Schématiser le flux (Mermaid) : sources → stockage détaillé → agrégés → BI.
4. Lister 3 risques (coût, cohérence des agrégés, performance) et les parades.

## Attendus (correction synthétique)

- HOLAP souvent pertinent : détails volumineux en ROLAP, agrégés récents en MOLAP.
- Plan d’actualisation : daily pour agrégés récents (60j), hebdo/mensuel pour historique.
- Schéma de flux attendu :

```mermaid
flowchart TD
  A[Systèmes sources] --> B[Staging]
  B --> C[Entrepôt ROLAP (détails)]
  C --> D[Cubes MOLAP (agrégés récents)]
  D --> E[BI/Tableaux de bord]
  C --> F[Requêtes ad hoc ROLAP]
```

- Risques : stockage MOLAP explosif (limiter plage), décalage d’actualisation (planifier/monitorer), incohérence (process ETL + rebuild cube).

## Pour aller plus loin

- Ajouter une stratégie d’archivage froid pour >3 ans.
- Définir des SLA de latence pour les tableaux de bord vs requêtes ad hoc.
