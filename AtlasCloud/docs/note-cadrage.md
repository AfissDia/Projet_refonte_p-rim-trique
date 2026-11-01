# Note de cadrage — AtlasCloud (synthèse)

## Situation et besoin
Scale-up SaaS B2B fictive de 250 salariés (+60 % de croissance annuelle). SonicWall vieillissant, VPN SSL historique, absence de WAF, segmentation cloud lacunaire et accès télétravail trop larges. La refonte doit garantir un changement progressif sans interruption programmée des services.

## Mandat
Auditer et cartographier les risques, comparer les variantes, proposer NGFW+IDS/IPS+WAF+ZTNA/SASE éventuel+SOC, exécuter un PoC fonctionnel, construire une migration en six phases, chiffrer CAPEX/OPEX sur 18 mois sous 250 k€, fournir dépôt Git + soutenance et preuve d'audit.

## Périmètre / hors périmètre
- Inclus au PoC : pfSense, Suricata ET Open, Juice Shop, WAF Nginx+ModSecurity+CRS, NetBird, Wazuh, agent Ubuntu.
- Hors PoC : cloud de production, redondance multisite, politique IAM/MFA complète, Headscale/Authelia, migration réelle, certification NIS2.

## Ressources et jalons
Sujet pédagogique : 5 jours / 35 h en équipe de 3 ; le dépôt ne présume pas de la répartition réelle des membres. Poste 16 Go avec VirtualBox et contraintes d'espace. Semaine PoC : réseau/IDS, WAF, ZTNA, SOC, tests et soutenance. Programme entreprise : six mois, voir `roadmap-budget.md`.

## Qualité et décision
Tests binaires documentés, captures horodatées, changements réversibles, aucune action sur cibles non autorisées. Un GO de déploiement entreprise exige inventaire de flux, IAM, sauvegarde, observabilité, test pilote, plan de retour arrière et validation juridique/RSSI.
