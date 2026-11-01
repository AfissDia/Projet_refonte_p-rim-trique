# Configurations de laboratoire

Les fichiers de ce répertoire sont des **exemples reproductibles** reconstitués à partir du déroulement du PoC ; ils ne sont pas tous des exports bruts. Ne pas écraser une configuration fonctionnelle sans sauvegarde et comparaison (`diff`).

- `docker/compose.yaml` : WAF + Juice Shop, publication locale seulement ; `compose.netbird.override.example.yaml` illustre la publication NetBird pendant la phase connectée.
- `suricata/icmp-test.rules` : signature ICMP reconstituée ; valider syntaxe/ID avant import pfSense.
- `wazuh/05-soc-net.network` : IP statique Wazuh `eth0`.
- `wazuh/manager-timeout-override.conf` : délai Manager à 180 s.
- `wazuh/agent-localfile-example.xml` : exemple à fusionner dans `ossec.conf` sur Ubuntu. Ne pas remplacer l'intégralité du fichier de configuration.
- `wazuh/local_rules-snippet.xml` : extrait à fusionner dans `local_rules.xml` du Manager. Une fois fusionné, tester le décodage et redémarrer le Manager.

**Attention :** le chemin de journal Docker est propre au conteneur. `scripts/show-waf-log-path.sh` récupère le chemin actuel. Si le conteneur est recréé, adapter le `localfile` ou mettre en place un mécanisme de logs persistants.
