# Trame orale — version courte pour la démonstration

1. « Le besoin d'AtlasCloud est de sécuriser à la fois les flux réseau, les applications Web et l'accès distant, tout en centralisant les alertes. »
2. « Notre architecture repose sur pfSense/Suricata, un WAF Nginx/ModSecurity avec OWASP CRS, un contrôle d'accès NetBird, et Wazuh pour la supervision. »
3. « En phase réseau, nous avons déclenché des alertes Suricata ICMP puis vérifié le blocage IPS. »
4. « Devant Juice Shop, une requête normale passe en HTTP 200. La requête SQLi est détectée par la règle CRS 942100 et bloquée avec HTTP 403. »
5. « Avec NetBird, le port applicatif 8080 est autorisé à un groupe défini alors que l'accès SSH via le peer est refusé. La désactivation de la politique retire l'accès. »
6. « L'agent Wazuh de notre Ubuntu lit les journaux JSON Docker du WAF. Notre règle 100501 détecte le motif CRS 942100 et produit une alerte de niveau 10. »
7. « Dans Threat Hunting, les alertes sont associées à l'agent p5-client-01 : la prévention WAF et la visibilité SOC sont donc reliées. »
8. « Notre PoC valide ces scénarios, pas une architecture de production complète. Les trois briques ne sont pas toutes centralisées dans Wazuh, et le plan de gestion ZTNA devrait être internalisé pour respecter strictement le sujet. »

**Plan B démonstration :** afficher les captures enregistrées plutôt que redémarrer les VM ; ne pas essayer de faire tourner simultanément pfSense 4 Gio + Wazuh 6 Gio + Ubuntu 2 Gio sur le poste 16 Gio.
