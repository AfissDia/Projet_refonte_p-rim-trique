# Index des captures

Les captures ci-dessous proviennent des pièces fournies dans la conversation. Elles documentent un PoC académique. Certaines images sont des **extraits d'une page de captures composites** et ne sont pas des exports natifs depuis l'outil.

| Fichier | Contenu |
|---|---|
| `suricata-extraits-page1.png` | IPS DROP et IDS ICMP sur pfSense/Suricata |
| `waf-extraits-page2.png` | Juice Shop accessible, réponse HTTP 403, essai HTTP 200 |
| `netbird-et-agent-page3.png` | Accès HTTP 200 via NetBird, TCP/22 refusé, agent Wazuh actif |
| `wazuh-agent-actif.png` | Vue détaillée agent 001 Active |
| `wazuh-threat-hunting-100501.png` | Deux événements « injection SQL » level 10, règle 100501 dans Threat Hunting |

## Captures encore souhaitables
1. Fenêtre des règles NetBird `P5-Allow-WAF` et désactivation/réactivation.
2. Détail d'un événement Wazuh ouvrant le champ `full_log` et montrant 942100.
3. Logs JSON ModSecurity montrant 942100, 949110 et score 8/5 (disponibles en terminal dans le chat, mais pas dans la pièce jointe de captures).
4. Export exact de la configuration pfSense / Suricata et schéma VirtualBox.
5. Preuve d'un événement Suricata ou ZTNA dans Wazuh **si cette intégration est réalisée ultérieurement**.

Ne pas présenter la capture Wazuh comme une démonstration de la centralisation de toutes les sources : elle démontre le WAF.
