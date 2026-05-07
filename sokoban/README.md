# Sokoban Solver - CodinGame

Ce projet propose un agent autonome (Java) capable de résoudre automatiquement les 30 niveaux du jeu Sokoban via le moteur CodinGame. L'ensemble du processus est automatisé : la génération des problèmes PDDL, la résolution (HSP) et l'exécution au sein du jeu tour par tour.

## Architecture du Projet

Tout le code principal se situe dans le package `sokoban` (`src/main/java/sokoban/`) :
- `GenPDDL.java` : Lit les grilles de `config/` et génère les problèmes correspondants dans `generated_pddl/`. Il détecte intelligemment les murs et les angles morts statiques (Deadlocks).
- `GenPlan.java` : Exécute le solveur intégré `PDDL4J` (HSP, Fast-Forward) sur tous les niveaux pour générer les plans dans `plans/`.
- `GenJson.java` : Convertit les plans générés en commandes formatées JSON/String dans `solutions_json/`.
- `Agent.java` : Le "cerveau" exécuté tour à tour. Il identifie en une fraction de seconde la grille de départ grâce à une comparaison d'empreinte visuelle avec et applique la solution hors-ligne.
- `SokobanMain.java` : L'orchestrateur global. Au tout premier lancement, il génère silencieusement le pipeline complet avant de charger l'interface visuelle.

## Explication de l'implémentation

### 1. Parser des fichiers problèmes JSON (`GenPDDL.java`)

Les 30 niveaux du jeu sont stockés dans des fichiers JSON (`config/testXX.json`). Chaque fichier contient un champ `testIn` représentant la grille Sokoban en ASCII :
- `#` = mur, `@` = joueur, `$` = caisse, `.` = cible, `+` = joueur sur cible, `*` = caisse sur cible, ` ` = case vide.

La classe `GenPDDL` parse chaque fichier JSON avec la bibliothèque **Gson**, puis parcourt la grille caractère par caractère pour extraire :
- Les **objets PDDL** (chaque case libre est un objet de type `place`, nommé `pX_Y`)
- L'**état initial** : position du joueur (`playerIsAt`), des caisses (`boxIsAt`), cases vides (`isEmpty`)
- Les **buts** : les caisses doivent être sur les cibles (`boxIsAt` sur chaque position cible)
- Les **relations d'adjacence** : pour chaque paire de cases voisines, les prédicats `isLeft`, `isRight`, `isUp`, `isDown`
- La **détection des deadlocks statiques** : une case dans un coin (deux murs adjacents) qui n'est pas une cible est marquée `(deadlock pX_Y)` pour empêcher d'y pousser une caisse

Le résultat est un fichier PDDL problème (`generated_pddl/problem_XX.pddl`) conforme au domaine.

### 2. Fichier domaine PDDL (`sokoban-domain.pddl`)

Le domaine PDDL (`src/main/resources/sokoban-domain.pddl`) définit :

- **Types** : `player`, `box`, `place`
- **Prédicats** : `playerIsAt`, `boxIsAt`, `isEmpty`, `isRight/Left/Up/Down` (adjacence), `deadlock`
- **8 actions** :
  - **4 actions de déplacement** (`move-right/left/up/down`) : le joueur se déplace vers une case vide adjacente
  - **4 actions de poussée** (`push-right/left/up/down`) : le joueur pousse une caisse vers une case vide adjacente, avec la **précondition `(not (deadlock ?bTo))`** pour éviter les angles morts

L'utilisation du prédicat `deadlock` dans les préconditions des actions `push-*` est une optimisation qui permet de réduire considérablement l'espace de recherche en éliminant les états dont on sait qu'ils ne mèneront jamais à une solution.

### 3. Planificateur intégré en Java (`GenPlan.java`)

Le planificateur est intégré directement dans le code Java via la bibliothèque **PDDL4J** (version 4.0.0). La classe `GenPlan` :

1. Instancie un **parser PDDL4J** qui charge le fichier domaine et chaque fichier problème
2. Utilise le planificateur **HSP** (Heuristic Search Planner) avec l'heuristique **Fast-Forward** pour trouver un plan optimal
3. Le timeout est fixé à **400 secondes** par niveau
4. Pour chaque plan trouvé, les actions sont écrites séquentiellement dans `plans/plan_XX.txt`

> **Note** : Aucun script bash externe n'est nécessaire. Le planificateur PDDL4J est appelé programmatiquement via son API Java, ce qui rend l'ensemble du pipeline autonome et portable.

### 4. Conversion plan → solution exécutable (`GenJson.java`)

Les plans PDDL bruts (ex: `push-right`, `move-down`) sont convertis en commandes directionnelles (`R`, `D`, `U`, `L`) compréhensibles par le moteur de jeu. La classe `GenJson` :
- Parse chaque fichier plan avec une **regex** `(?:push|move)-(down|up|left|right)`
- Extrait la direction de chaque action et la convertit en lettre
- Sauvegarde le résultat dans `solutions_json/solution_XX.json` avec le format `{"level": X, "solution": "RRDLUU..."}`

### 5. Agent d'exécution (`Agent.java`)

L'`Agent.java` est le programme exécuté tour par tour par le moteur CodinGame. Il :
1. **Lit l'état initial** envoyé par le moteur (dimensions, grille, positions)
2. **Identifie le niveau** en comparant l'empreinte de la grille reçue avec celles des 30 fichiers JSON de `config/`
3. **Charge la solution pré-calculée** depuis `solutions_json/solution_XX.json`
4. **Envoie les mouvements** un par un au moteur de jeu

### 6. Pipeline complet (`SokobanMain.java`)

L'orchestrateur `SokobanMain` automatise tout le processus au premier lancement :

```
JSON (config/) → GenPDDL → PDDL (generated_pddl/) → GenPlan (HSP/PDDL4J) → plans/ → GenJson → solutions_json/ → Agent
```

Si le dossier `solutions_json/` n'existe pas ou est incomplet, le pipeline complet est relancé automatiquement (~2-3 min). Les exécutions suivantes sont instantanées.

## Comment lancer une partie

### 0. Prérequis : Installation de PDDL4J
Avant de pouvoir compiler le projet pour la toute première fois, il est nécessaire d'installer la bibliothèque PDDL4J fournie (fichier `pddl4j-4.0.0.jar` à la racine) dans votre cache Maven local. Exécutez cette commande une seule fois :
```bash
mvn install:install-file \
   -Dfile=pddl4j-4.0.0.jar \
   -DgroupId=fr.uga \
   -DartifactId=pddl4j \
   -Dversion=4.0.0 \
   -Dpackaging=jar \
   -DgeneratePom=true
```

### 1. Compilation
Il est nécessaire de compiler si vous effectuez la moindre modification Java :
```bash
mvn clean compile
```

### 2. Démarrer le moteur de jeu (SoloGameRunner)
La méthode standard via `mvn exec:java` comporte un bug d'affichage connu pour ce projet (les textures de l'interface `assets/` ne chargent pas). Exécutez donc la commande officielle avec les droits étendus depuis le terminal à la racine du projet :

```bash
java --add-opens java.base/java.lang=ALL-UNNAMED \
     -server -Xms2048m -Xmx2048m \
     -cp "$(mvn dependency:build-classpath -Dmdep.outputFile=/dev/stdout -q):target/classes" \
     sokoban.SokobanMain
```

**Alternative (via package JAR) :**
Si vous préférez créer un exécutable autonome, vous pouvez packager l'application puis la lancer directement :
```bash
mvn package
java --add-opens java.base/java.lang=ALL-UNNAMED \
     -server -Xms2048m -Xmx2048m \
     -cp target/sokoban-1.0-SNAPSHOT-jar-with-dependencies.jar \
     sokoban.SokobanMain
```

> *Note :* Le tout premier lancement calculera la solution pour les 30 niveaux. Cela peut prendre environ 2 à 3 minutes. Les lancements ultérieurs détecteront le dossier `solutions_json` et seront instantanés.


### 3. Visualiser dans le navigateur
Tant que la commande tourne dans le terminal, le serveur visuel est ouvert. Copiez et collez l'adresse suivante dans votre navigateur :
`http://localhost:8888/test.html`

## Changer de Niveau de Jeu

Pour affronter le solver sur un autre niveau, il vous suffit de modifier cette simple ligne dans le fichier `src/main/java/sokoban/SokobanMain.java` :

```java
gameRunner.setTestCase("testXX.json"); // Remplacer testXX par test05 par exemple.
```
Sauvegardez le fichier `SokobanMain.java`, **re-compilez** (`mvn compile`) et relancez la commande Java pour observer la nouvelle résolution !