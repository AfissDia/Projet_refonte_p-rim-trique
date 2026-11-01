# Matrice de tests du PoC (observés, non inventés)

| ID | Brique | Préparation / action | Attendu | Observé | Preuve |
|---|---|---|---|---|---|
| T01 | pfSense | Ping `192.168.100.1` depuis Ubuntu | Connectivité LAN | OK en phase pfSense actif | Capture/terminal |
| T02 | Suricata IDS | ICMP Ubuntu → pfSense, SID 1000001 | Alerte sans perte de paquet | Alerte dans Suricata | Capture |
| T03 | Suricata IPS | Activer variante DROP et envoyer ICMP | Alerte DROP + ping échoué | Conforme | Capture Suricata |
| T04 | WAF | `curl -I http://127.0.0.1:8080/` | HTTP 200 | 200 | Capture |
| T05 | WAF | SQLi sur paramètre id du labo | HTTP 403 ; 942100 + 949110 | 403 ; JSON audité ; score 8/5 | Journal / capture |
| T06 | NetBird | Groupe autorisé → `100.76.144.250:8080` | HTTP 200 | 200 | Capture |
| T07 | NetBird | Test TCP/22 vers peer | Refus | `TcpTestSucceeded=False` | Capture |
| T08 | NetBird | Désactiver P5-Allow-WAF | Timeout HTTP | Timeout | Journal de test, capture à joindre |
| T09 | Wazuh agent | Inscription Ubuntu `p5-client-01` | Agent Active | ID 001 Active | Capture |
| T10 | Wazuh SOC | SQLi + fichier JSON collecté + règle 100501 | Alerte level 10 | 2 alertes visibles | Capture Threat Hunting |
| T11 | Audit 3 sources | Suricata + WAF + ZTNA dans Wazuh | 3 origines | **Non réalisé** | Aucune |
| T12 | OIDC local | Headscale + Authelia | Plan local authentifié | **Non réalisé** | Aucune |

## Commandes minimales de démonstration

```bash
curl -I --max-time 8 http://127.0.0.1:8080/
curl -s -o /dev/null -w 'HTTP %{http_code}\n' --get --data-urlencode "id=1' OR '1'='1" http://127.0.0.1:8080/
sudo docker logs --since=2m p5-waf 2>&1 | grep -E '942100|949110' | tail -n 3
```

Sur Wazuh Server :

```bash
sudo systemctl is-active wazuh-manager wazuh-indexer wazuh-dashboard
sudo grep '"id":"100501"' /var/ossec/logs/alerts/alerts.json | tail -n 1 | cut -c 1-600
```

## Pièges
- Un `HTTP 403` seul ne prouve pas le déclenchement de `942100` : consulter le journal d'audit.
- Une sortie `active` de l'agent ne prouve pas son enrôlement : vérifier le Dashboard.
- Les journaux Docker sont encapsulés et le chemin dépend du conteneur.
- NetBird déconnecté sans passerelle pfSense active : le test ZTNA ne peut pas être rejoué hors ligne dans la configuration actuelle.
