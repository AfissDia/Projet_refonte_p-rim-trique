# Dimensionnement et contraintes du PoC

| Ressource | Allocation initiale | Test de coexistence |
|---|---:|---:|
| pfSense / Suricata | 4 Gio | Arrêtée pour le SOC |
| Ubuntu + Docker + agent | 3 Gio | 2 Gio |
| Wazuh OVA (indexer, manager, dashboard) | 8 Gio | 6 Gio |
| Windows hôte | Reste sur 16 Gio | Libre observé ~1,64 Gio avec Wazuh+Ubuntu |

La somme de toutes les allocations initiales (15 Gio) aurait laissé une marge hôte irréaliste. Le PoC a donc été décomposé en phases. L'appliance Wazuh est plus lourde que la variante conteneur optimisée du sujet ; elle a été retenue pour la facilité de déploiement au prix d'un disque VDI d'environ 24 Gio. Après nettoyage, Windows ne conservait qu'environ 9 Gio d'espace libre. Ne pas recommander l'exploitation simultanée permanente de ces trois VM. La limite de 16 Go de RAM est celle du poste, pas celle d'une infrastructure réelle AtlasCloud.
