# Projets PATIA 2026

**Auteur :** GIRINCUTI Dany Carol

Ce dépôt regroupe les 4 projets que j'ai réalisés pour le cours PATIA (Planification Automatique et Techniques d'Intelligence Artificielle).

## Prérequis globaux

- **Python 3.x** (+ `matplotlib` pour les benchmarks n-puzzle)
- **Java 17+** et **Maven** (pour Sokoban et SATPlanner)
- Testé sur la VM PATIA

## Projets

### 1. [N-Puzzle](n-puzzle/) — Recherche dans un espace d'états
J'ai implémenté un solveur de taquin avec les algorithmes **BFS**, **DFS**, **A\*** (distance de Manhattan) et **IDDFS**.
Mon projet inclut un générateur de puzzles de difficulté croissante et j'ai tracé des courbes de performance comparatives.

```bash
cd n-puzzle && python3 benchmark_plot.py
```

### 2. [PDDL](pddl/) — Modélisation en langage PDDL
J'ai créé les fichiers domaine et problème pour :
- Les **Tours de Hanoï** (3 disques, 3 piquets)
- Le **Taquin** (3×3 et 4×4) avec plusieurs instances de difficulté variable

### 3. [Sokoban](sokoban/) — Application web avec planificateur intégré
J'ai développé un agent Java autonome capable de résoudre les 30 niveaux de Sokoban via un pipeline PDDL4J (HSP).
J'ai également mis en place une interface web accessible sur `localhost:8888`.

```bash
cd sokoban && mvn clean compile
java --add-opens java.base/java.lang=ALL-UNNAMED -server -Xms2048m -Xmx2048m \
     -cp "$(mvn dependency:build-classpath -Dmdep.outputFile=/dev/stdout -q):target/classes" \
     sokoban.SokobanMain
```

### 4. [YetAnotherSATPlanner](YetAnotherSATPlanner/) — Planificateur SAT
J'ai conçu un planificateur formel qui traduit des problèmes PDDL en clauses DIMACS/CNF, résolues par SAT4J.
Mon implémentation inclut des benchmarks comparatifs (SAT vs HSP) sur le domaine du Taquin pour prouver son bon fonctionnement.

```bash
cd YetAnotherSATPlanner && ./yetanothersatplanner.sh
```

## Structure de mon dépôt

```
PATIA/
├── n-puzzle/          # TP1 - Mes algorithmes de recherche
├── pddl/              # TP2 - Mes fichiers PDDL (Hanoï + Taquin)
├── sokoban/           # TP3 - Mon application Sokoban
└── YetAnotherSATPlanner/  # TP4 - Mon planificateur SAT
```
