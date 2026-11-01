# Diagrammes éditables

Les fichiers `.mmd` s'affichent dans de nombreuses interfaces Markdown et peuvent être modifiés avec un éditeur Mermaid. Ils documentent des **schémas C4-like** et non des exports officiels de C4-PlantUML.

- `01-contexte.mmd` : acteurs et SI cible.
- `02-conteneurs.mmd` : PoC et flux réseau, dont les phases alternées.
- `03-composants-soc.mmd` : chaîne de détection ModSecurity → Wazuh.

Pour produire des SVG/PNG localement avec Mermaid CLI (optionnel) : `npx @mermaid-js/mermaid-cli -i diagrams/03-composants-soc.mmd -o soc.svg`. Éviter de le lancer sur le PC de lab avec 9 Go de disque disponibles si les dépendances ne sont pas déjà installées.
