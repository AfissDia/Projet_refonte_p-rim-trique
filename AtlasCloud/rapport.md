# Rapport technique — Projet 5 : refonte de la sécurité périmétrique d’AtlasCloud

**La Plateforme_ — Master Cybersécurité · 2 novembre 2026**  
**Type :** preuve de concept académique, documentation de réalisation et propositions d'architecture.

## 1. Contexte, objectifs et méthode
AtlasCloud est une scale-up SaaS B2B de 250 salariés, en croissance de 60 % par an. La situation initiale du sujet comprend un pare-feu SonicWall vieillissant, un VPN SSL historique, des télétravailleurs ayant un accès VPN direct, l'absence de WAF et une segmentation cloud insuffisante. Dans ce contexte, un périmètre purement réseau n'offre plus une défense adaptée : les accès distants, les applications Web et la détection doivent être contrôlés ensemble.

**Objectifs du projet :** (1) analyser les risques, (2) proposer une architecture cible NGFW/IDS/IPS/WAF/ZTNA et supervision, (3) organiser six phases de migration sans indisponibilité planifiée, (4) établir un budget sur 18 mois inférieur à 250 k€, (5) prouver au moins trois briques techniques sur un poste sans licences payantes quand c'est possible.

**Méthode de validation :** pour chaque brique, définir un comportement attendu, effectuer un test dans le lab, observer les événements (code HTTP, alerte IDS, résultat TCP ou entrée Wazuh), conserver une capture. Les simulations n'ont ciblé que des systèmes de laboratoire contrôlés.

**Distinction importante :** résultats confirmés ci-dessous vs recommandations de production (non testées). La réalisation utilise **pfSense CE**, autorisé comme alternative à OPNsense. **NetBird** a été utilisé pour prouver des politiques ZTNA, mais son plan de gestion externe **ne satisfait pas strictement l'exigence zéro cloud du PoC**. Headscale et Authelia sont recommandés comme adaptation entièrement locale, non déployée.

## 2. Périmètre, équipements et adressage

| Élément | Rôle | Réseau et ressources | Phase |
|---|---|---|---|
| pfSense CE 2.9.0 | NAT/filtrage + Suricata ET Open | WAN NAT ; LAN `192.168.100.1/24` ; 4 Gio | IDS/IPS |
| Ubuntu `p5-client-01` | Hôte Docker + agent Wazuh | `192.168.100.10/24`, NAT sur autre NIC ; 3 puis 2 Gio | toutes |
| `p5-waf` | Nginx, ModSecurity, CRS | Docker bridge ; HTTP hôte local `127.0.0.1:8080` | WAF/SOC |
| `p5-juice-shop` | Application d'essai | Port 3000 accessible uniquement via bridge Docker | WAF/SOC |
| NetBird | Contrôle d'accès ZTNA | Ubuntu peer `100.76.144.250` ; Windows peer `100.76.116.207` | ZTNA |
| Wazuh OVA 4.14.9 | Manager, Indexer, Dashboard | `eth0=192.168.100.20/24`, `eth1=10.0.2.15/24` NAT ; 8 puis 6 Gio | SOC |

**Schéma de flux validés :** voir [diagrams/02-conteneurs.mmd](diagrams/02-conteneurs.mmd). Les périodes de test sont distinguées : le WAF et Wazuh ont fonctionné ensemble avec pfSense arrêté ; pfSense/Suricata ont été validés avant la phase SOC.

## 3. Déploiement réseau — pfSense CE

### 3.1 Objectif
Séparer un WAN VirtualBox simulé du LAN interne, faire passer les flux du client Linux par un pare-feu, définir un chemin vérifiable vers les services.

### 3.2 Réalisation
Une VM pfSense CE a été configurée avec deux interfaces : WAN en NAT VirtualBox et LAN sur `SOC-NET`, `192.168.100.1/24`. Le serveur Ubuntu disposait d'une interface interne `192.168.100.10/24`, avec la passerelle pfSense sur ce segment, ainsi que d'une interface NAT de maintenance. Les règles et accès Web de gestion pfSense ont été vérifiés dans le laboratoire.

### 3.3 Commandes de validation — Ubuntu

```bash
ip -br addr
ip route
ping -c 3 192.168.100.1
curl -I --max-time 8 https://example.com
```

### 3.4 Résultat et limites
Le LAN était joignable et les flux sortants fonctionnaient lorsque pfSense était actif. La simulation ne représente pas une segmentation VLAN multi-zones de production ; les règles de production doivent être conçues à partir d'une matrice de flux.

## 4. IDS / IPS — Suricata ET Open

### 4.1 Objectif
Détecter des événements réseau, puis vérifier une action de blocage contrôlée.

### 4.2 Réalisation
Suricata a été activé sur le LAN pfSense avec les signatures Emerging Threats Open. Une signature ICMP locale (SID `1000001`) a permis de générer une alerte reproductible. Le mode IDS enregistrait l'activité sans rejet ; le test IPS a temporairement bloqué les requêtes ICMP correspondantes, avant retour au mode IDS.

**Règle d'essai illustrative** ([source](config/suricata/icmp-test.rules)) :

```suricata
alert icmp 192.168.100.10 any -> 192.168.100.1 any (msg:"P5 LAB - ICMP Ubuntu vers pfSense"; sid:1000001; rev:1;)
```

La variante `drop` a été utilisée dans un scénario dédié. La ligne ci-dessus est une **reconstruction documentée**, à confirmer avec l'export exact de pfSense avant reprise stricte.

### 4.3 Test et résultats

```bash
ping -c 4 192.168.100.1
nmap -sS -Pn -p 21,22,53,80,443 192.168.100.1
```

Dans `Services → Suricata → Alerts`, les alertes ICMP puis les événements **DROP** sont visibles pour `192.168.100.10 → 192.168.100.1`. Le ping a échoué pendant le test de blocage. Un scan réseau a également été réalisé ; aucune prétention de blocage exhaustif des signatures ET Open n'est faite.

**Preuves :** `evidence/suricata-extraits-*.png` (issues du document de captures). **Non démontré :** arrivée d'un événement Suricata dans Wazuh.

## 5. Protection Web — Nginx, ModSecurity et OWASP CRS

### 5.1 Objectif et architecture
Protéger OWASP Juice Shop, volontairement vulnérable, au travers d'un WAF qui filtre et journalise le trafic. Les conteneurs partagent le bridge Docker `waf-net`. Seul `p5-waf` publie le port HTTP 8080 ; Juice Shop est accessible en interne sur 3000.

### 5.2 Configuration
Le fichier [config/docker/compose.yaml](config/docker/compose.yaml) est **reconstruit** à partir des réglages observés. Variables essentielles :

```yaml
BACKEND: http://juice-shop:3000
MODSEC_RULE_ENGINE: 'On'
BLOCKING_PARANOIA: '1'
ANOMALY_INBOUND: '5'
```

### 5.3 Tests HTTP 200 et 403

```bash
cd ~/projet5-waf
sudo docker compose up -d
sudo docker compose ps
curl -I --max-time 8 http://127.0.0.1:8080/
curl -s -o /dev/null -w 'HTTP %{http_code}\n' \
  --get --data-urlencode "id=1' OR '1'='1" \
  http://127.0.0.1:8080/
```

**Résultats :** HTTP **200** sur une requête normale, HTTP **403** sur la requête SQLi. Le journal d'audit ModSecurity (JSON) expose :

| Règle | Sens | Valeur observée |
|---|---|---|
| 920350 | Host numérique | En-tête `127.0.0.1:8080` |
| 942100 | Détection SQLi libinjection | Argument `id` reconnu comme SQLi |
| 949110 | Évaluation de blocage | Score d'anomalie **8**, seuil **5** |

ModSecurity **3.0.17** et OWASP CRS **4.30.0** figuraient dans le journal. Le code HTTP 403 est cohérent avec la décision de blocage. La requête est un test contrôlé, pas la preuve de protection contre toutes les injections SQL.

### 5.4 Journal d'audit

```bash
sudo docker inspect p5-waf --format 'Driver={{.HostConfig.LogConfig.Type}} LogPath={{.LogPath}}'
sudo docker logs --since=2m p5-waf 2>&1 | tail -c 3000
```

Docker utilisait le pilote **json-file**. Les événements ModSecurity étaient contenus dans un champ `log` de l'enveloppe JSON Docker.

### 5.5 Incident de redémarrage et résolution
Le WAF entrait dans la boucle `Restarting (1)` : `host not found in upstream "juice-shop"`, donc Nginx ne résolvait plus le service Docker. Par ailleurs, l'adresse IP NetBird était indisponible avec pfSense arrêté. Le port attaché à `100.76.144.250:8080` a été retiré temporairement, laissant `127.0.0.1:8080:8080` ; après sauvegarde du Compose, `docker compose down` puis `docker compose up -d` ont recréé les conteneurs et le réseau. Les réponses HTTP 200/403 ont été vérifiées de nouveau.

**Limite :** cette publication locale ne prouve pas l'accès ZTNA au même instant ; les tests NetBird ont été réalisés précédemment quand le peer était connecté.

## 6. ZTNA — NetBird

### 6.1 Objectif
Remplacer une logique « VPN = accès global » par une politique d'accès par identité/groupe et service.

### 6.2 Réalisation
Un peer Windows (`100.76.116.207`) et un peer Ubuntu (`100.76.144.250`) ont été associés aux groupes `P5-Employees` et `P5-Servers`. Après désactivation de la politique générale `Default`, la politique `P5-Allow-WAF` n'autorisait que **TCP/8080** vers le service WAF.

### 6.3 Validation

```powershell
curl.exe -I --max-time 8 http://100.76.144.250:8080
Test-NetConnection 100.76.144.250 -Port 22
```

Avec la politique active, HTTP **200** était reçu sur 8080 et TCP **22** échouait. La désactivation temporaire de `P5-Allow-WAF` faisait expirer la requête HTTP ; sa réactivation restaurait l'accès.

### 6.4 Limites
Le déploiement a utilisé la gestion NetBird externe. Lorsque pfSense a été arrêté, Ubuntu ne pouvait plus joindre la gestion distante et NetBird indiquait `Management: Disconnected` avec `NetBird IP: N/A`. La **cible conforme au cahier des charges** devrait utiliser un plan de contrôle entièrement local de type **Headscale + client Tailscale**, un fournisseur d'identité local **Authelia**, ainsi qu'un relais local si nécessaire. Ces composants n'ont pas été validés dans le PoC.

## 7. Supervision SOC — Wazuh

### 7.1 Objectif
Créer une chaîne d'audit traçable depuis l'événement ModSecurity vers un tableau de bord central.

### 7.2 Appliance et ressources
L'appliance Wazuh **4.14.9** a été importée dans VirtualBox : Manager, Indexer, Dashboard. Avec 8 Gio dédiés, le service Manager dépassait son timeout de **45 s** ; une surcharge `systemd` l'a porté à **180 s**. Pour faire tourner simultanément Ubuntu, Wazuh a été ramené à **6 Gio** (Ubuntu à **2 Gio**, pfSense arrêté). Les trois services ont été observés `active`.

```bash
sudo mkdir -p /etc/systemd/system/wazuh-manager.service.d
printf '[Service]\nTimeoutStartSec=180s\n' | sudo tee /etc/systemd/system/wazuh-manager.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl is-active wazuh-manager wazuh-indexer wazuh-dashboard
```

### 7.3 Réseau
Wazuh `eth0` rejoint `SOC-NET` en `192.168.100.20/24` sans passerelle supplémentaire ; `eth1` conserve le NAT `10.0.2.15/24`. L'accès SSH Windows passe par `127.0.0.1:2223`, et le Dashboard HTTPS par `127.0.0.1:8443` (redirections VirtualBox).

```ini
[Match]
Name=eth0
[Network]
DHCP=no
Address=192.168.100.20/24
LinkLocalAddressing=no
```

### 7.4 Agent Ubuntu
L'agent Wazuh **4.14.9-1 amd64** a été téléchargé depuis Windows puis copié en SCP vers Ubuntu car la passerelle pfSense était arrêtée.

```powershell
scp -P 2222 "$env:USERPROFILE\Downloads\wazuh-agent_4.14.9-1_amd64.deb" p5_client-01@127.0.0.1:~/
```
```bash
sudo WAZUH_MANAGER='192.168.100.20' WAZUH_AGENT_NAME='p5-client-01' dpkg -i ./wazuh-agent_4.14.9-1_amd64.deb
sudo systemctl enable --now wazuh-agent
```

**Résultat :** l'agent `001 / p5-client-01 / 192.168.100.10` était visible `Active`.

### 7.5 Collecte JSON Docker

```bash
sudo docker inspect p5-waf --format '{{.LogPath}}'
```

Le fichier Docker `...-json.log` a été référencé dans `/var/ossec/etc/ossec.conf` (agent) :

```xml
<localfile>
  <log_format>json</log_format>
  <location>/var/lib/docker/containers/ID_CONTENEUR/ID_CONTENEUR-json.log</location>
</localfile>
```

La ligne `wazuh-logcollector: INFO: (1950): Analyzing file: '...-json.log'` confirmait sa surveillance. Le chemin dépend de l'identifiant du conteneur ; le dépôt fournit un outil de mise à jour contrôlée et recommande une collecte durable sur chemins stables en production.

### 7.6 Règle SOC spécifique
Sur le serveur Wazuh, fichier `/var/ossec/etc/rules/local_rules.xml` :

```xml
<group name="projet5,modsecurity,sqli,">
  <rule id="100501" level="10">
    <decoded_as>json</decoded_as>
    <field name="log" type="pcre2">942100</field>
    <description>Projet 5 - Injection SQL detectee par ModSecurity CRS 942100</description>
  </rule>
</group>
```

Après rechargement du Manager et nouvelle requête SQLi, `alerts.json` contenait notamment :

```json
{"rule":{"level":10,"id":"100501","description":"Projet 5 - Injection SQL detectee par ModSecurity CRS 942100"},"agent":{"id":"001","name":"p5-client-01","ip":"192.168.100.10"}}
```

La capture finale montre **deux** alertes de cette règle, dont le 1er novembre 2026 à **11:37:15** et **12:36:48** (horaires affichés par le Dashboard), avec le niveau **10**. La preuve finale se trouve dans [evidence/wazuh-threat-hunting-100501.png](evidence/wazuh-threat-hunting-100501.png).

**Limite de la règle :** elle cherche le motif `942100` dans un champ texte, sans validation sémantique du JSON ModSecurity imbriqué ; acceptable pour un PoC ciblé, trop permissive pour une exploitation de production. Ajouter un décodeur adapté, l'identifiant de la source et une corrélation temporelle avant tout usage opérationnel.

## 8. Analyse synthétique des risques

Le modèle de priorisation utilise `probabilité × impact`, chacun sur une échelle 1–5 **illustrative**, à recalibrer avec les parties prenantes. Voir [docs/risques.md](docs/risques.md).

| Risque | Cause dans l'existant | Réponse proposée |
|---|---|---|
| Accès distant trop large | VPN SSL historique et accès direct | ZTNA, politiques par groupes, MFA/OIDC |
| Attaques Web | Absence de WAF | WAF CRS, règles contrôlées et tests applicatifs |
| Propagation latérale | Segmentation insuffisante | Filtrage interzones et défaut de refus |
| Faible visibilité | Journaux dispersés | Wazuh/SIEM et conservation maîtrisée |
| Dette technique périmétrique | Pare-feu vieillissant | NGFW, support, durcissement et redondance |

## 9. Architecture cible, migration et coût

La cible doit distinguer le réseau physique, le cloud, les applications et les utilisateurs distants ; imposer une identité forte ; centraliser les alertes ; définir des règles par zone ; et prévoir des chemins de bascule sans interruption planifiée. Voir [docs/architecture-cible.md](docs/architecture-cible.md) et [docs/roadmap-budget.md](docs/roadmap-budget.md).

**Budget indicatif de planification** sur 18 mois : **219 000 €**, sous le plafond de 250 k€ avec **31 000 €** de réserve non affectée. Ce budget est un scénario de travail, **pas un devis fournisseur**. Les hypothèses et postes sont détaillés dans le fichier dédié. La migration est organisée en six phases mensuelles avec points GO/NO-GO et retour arrière.

**NIS2 :** la journalisation et la gouvernance des incidents doivent être traitées de façon proportionnée à l'assujettissement effectif de l'entité et au droit national applicable. Le PoC démontre l'audit WAF → Wazuh, mais pas encore la centralisation des trois briques ni une politique de conservation / intégrité probante complète.

## 10. Démonstration et exploitation soutenance

Démonstration proposée (moins de 10 minutes) : schéma → HTTP 200 → SQLi HTTP 403 → règles 942100/949110 → agent `001` → Threat Hunting `100501` → comparaison NetBird et Suricata en captures → limites.

Pour éviter un échec en direct dû aux 16 Gio RAM et au stockage contraint, préparer des captures de secours, désactiver les applications Windows lourdes et **ne pas** démarrer les trois VM ensemble. Les captures sont indexées dans [evidence/README.md](evidence/README.md).

## 11. Limites et suite de travaux

- **Écart au sujet :** aucun plan de contrôle Headscale/Authelia local déployé ; NetBird dépendait d'une gestion distante.
- **Audit trail partiel :** seule la source WAF a été démontrée de bout en bout vers Wazuh. Les alertes pfSense/Suricata et les événements ZTNA ne sont pas encore corrélés dans le Manager.
- **Cible vs PoC :** pas de haute disponibilité ni de migration en production ; simulations de tests contrôlées.
- **Ressources :** disque Windows voisin de 9 Gio libres, RAM disponible faible en phase Wazuh ; pas de tests de charge.
- **Reproductibilité :** `compose.yaml` et les exports pfSense sont à confirmer avec l'environnement exécuté ; seules les configurations explicitement documentées et les scripts d'essai sont fournis.
- **Livrables officiels non entièrement couverts :** dossier 50–80 pages, présentation COMEX 20 slides/30 min, vidéo 10 min et démonstration audit trail trois sources. Le présent Markdown est un **rapport technique structuré**, pas une preuve d'achèvement de chacun de ces éléments.

## 12. Références et annexes

- [Documentation et références](docs/references.md)
- [Tests et résultats](docs/tests.md)
- [Schémas Mermaid](diagrams/)
- [Règles locales](config/)
- [Captures](evidence/)

**Conclusion :** le PoC valide une prévention/détection complémentaire via NGFW/IDS/IPS, WAF, ZTNA et SOC, avec une preuve mesurable d'une SQLi bloquée et centralisée dans Wazuh. Pour une architecture AtlasCloud exploitable sur 18 mois, les processus de migration, la gouvernance, l'audit multi-source et la gestion des identités restent à industrialiser.
