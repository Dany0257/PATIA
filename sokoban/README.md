# Sokoban Solver - CodinGame

Ce projet propose un agent autonome (Java) capable de résoudre automatiquement les 30 niveaux du jeu Sokoban via le moteur CodinGame. L'ensemble du processus est automatisé : la génération des problèmes PDDL, la résolution (HSP) et l'exécution au sein du jeu tour par tour.

## Architecture du Projet

Tout le code principal se situe dans le package `sokoban` (`src/main/java/sokoban/`) :
- `GenPDDL.java` : Lit les grilles de `config/` et génère les problèmes correspondants dans `generated_pddl/`. Il détecte intelligemment les murs et les angles morts statiques (Deadlocks).
- `GenPlan.java` : Exécute le solveur intégré `PDDL4J` (HSP, Fast-Forward) sur tous les niveaux pour générer les plans dans `plans/`.
- `GenJson.java` : Convertit les plans générés en commandes formatées JSON/String dans `solutions_json/`.
- `Agent.java` : Le "cerveau" exécuté tour à tour. Il identifie en une fraction de seconde la grille de départ grâce à une comparaison d'empreinte visuelle avec et applique la solution hors-ligne.
- `SokobanMain.java` : L'orchestrateur global. Au tout premier lancement, il génère silencieusement le pipeline complet avant de charger l'interface visuelle.

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