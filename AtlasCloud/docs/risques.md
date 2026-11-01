# Analyse de risques — cartographie illustrative AtlasCloud

**Méthode :** grille simple P (probabilité) × I (impact), notes 1–5 attribuées pour la discussion et **non validées auprès du client**. À remplacer par une méthode formelle et une analyse d'actifs avec propriétaires si le dossier devient contractuel.

| ID | Actif / menace | Faiblesse initiale | P | I | Score | Mesure prioritaire | Risque résiduel à réévaluer |
|---|---|---|---:|---:|---:|---|---|
| R1 | Application SaaS / injection | Absence de WAF | 4 | 5 | 20 | WAF + tests applicatifs | Moyen |
| R2 | Comptes distants / compromission | VPN large, authentification legacy | 4 | 5 | 20 | ZTNA + MFA + moindre privilège | Moyen |
| R3 | Réseau / propagation latérale | Segmentation insuffisante | 4 | 5 | 20 | Zoning et filtrage interzones | Moyen |
| R4 | SIEM / incident invisible | Journaux dispersés | 4 | 4 | 16 | Centralisation, alerte et audit trail | Moyen |
| R5 | Disponibilité / panne du périmètre | SonicWall vieillissant | 3 | 5 | 15 | NGFW supporté et redondance | Faible à moyen |
| R6 | Déploiement / interruption | Migration sans retour arrière | 3 | 5 | 15 | Pilotes, canary, tests, rollback | Moyen |
| R7 | Conformité / preuve insuffisante | Rétention et responsabilités non cadrées | 3 | 4 | 12 | Politique logs, contrôles d'accès et revue | Moyen |

## Limites méthodologiques
Ces scores sont des hypothèses de cadrage : pas de recensement exhaustif des actifs SaaS/cloud, pas d'estimation monétaire de pertes, pas d'entretien métiers, pas de plan de traitement signé. Les calculs doivent être validés par RSSI, IT, métiers et DPO.
