# Feuille de route de migration et budget de planification

## Migration progressive en six phases — aucune coupure programmée

| Mois | Phase | Livrables / seuil de sortie | Retour arrière |
|---|---|---|---|
| M1 | Audit / inventaire / cartographie | Actifs, flux, matrice de risques, exigences, métriques de référence | Aucune modification de production |
| M2 | Réseau pilote / NGFW | NGFW parallèle, règles testées, 1 segment pilote | Rebasculer les routes sur ancien FW |
| M3 | DMZ / WAF en observation | WAF en shadow, faux positifs recensés, tests de régression | Bypass WAF contrôlé |
| M4 | ZTNA / identité | SSO/MFA, groupes et pilotage d'un service, revue d'accès | Maintenir VPN restreint temporaire |
| M5 | Supervision / IDS/IPS / centralisation | Journalisation NGFW/WAF/ZTNA, triage SOC, tests de rejets | Repasser IPS en IDS et règles stables |
| M6 | Généralisation / décommissionnement | Plan de support, bascule progressive, dossiers d'exploitation, PV recette | Procédure de rollback par lot |

**GO/NO-GO :** aucun passage en blocage si faux positifs non maîtrisés ; sauvegarde avant changements, astreinte et validation métier avant chaque bascule.

## Budget de travail sur 18 mois — euros HT, à valider par devis

| Poste | Montant | Nature / hypothèse |
|---|---:|---|
| NGFW / HA / support / matériel | 48 000 € | CAPEX + support |
| WAF, infrastructure / support | 20 000 € | Principalement intégration/support, stack OSS |
| ZTNA / IAM / MFA / intégration | 30 000 € | Intégration + hébergement local |
| SOC / Wazuh stockage et exploitation | 34 000 € | Infrastructure + indexation / sauvegarde |
| Intégration / migration / prestataires | 40 000 € | Projets et accompagnement |
| Formation / documentation / conduite changement | 14 000 € | Montée en compétence |
| Tests techniques / pentest / audit conformité | 18 000 € | Validation indépendante |
| Continuité / sauvegardes / observabilité | 15 000 € | CAPEX/OPEX |
| **Total planifié** | **219 000 €** | **Sous plafond 250 000 €** |
| **Réserve non allouée** | **31 000 €** | **Écart jusqu'au plafond, pas une dépense** |

**Précisions :** chiffrage illustratif pour l'exercice, non calcul fondé sur devis fournisseur ni sur les coûts salariaux internes exhaustifs. Le budget doit être reventilé en CAPEX/OPEX avec capacité de stockage, haute disponibilité, support 24/7, fréquence des audits, coût d'identité et charge de run. Le recours à des composants OSS ne signifie pas un coût nul.

## KPIs de pilotage
- Couverture inventaire et flux approuvés : objectif >95 % avant bascule.
- Taux de règles WAF en blocage après période de tuning : 100 % des règles approuvées, exceptions documentées.
- Délai de traitement d'alerte haute priorité : cible initiale <1 h ouvrée, à contractualiser.
- Couverture de collecte des briques périmétriques : 100 % visés en cible (non atteints dans le PoC).
- Faux positifs WAF / IPS : mesure hebdomadaire et tendance à la baisse.
- Tests de restauration et de retour arrière : un test par phase.
