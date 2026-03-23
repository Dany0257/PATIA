# N-Puzzle Solver

Ce projet implémente un solveur de N-Puzzle (taquin) utilisant plusieurs algorithmes de recherche : BFS, DFS, A* et IDDFS. Il inclut également des outils pour générer des benchmarks et visualiser les performances.

## Prérequis

- Python 3.x
- **Matplotlib** (pour générer les graphiques de performance) :
  ```bash
  pip install matplotlib
  ```

## Utilisation du Solveur

Pour résoudre un puzzle, utilisez le script `solve_npuzzle.py`.

### Commande de base

```bash
python3 solve_npuzzle.py <fichier_puzzle> -a <algorithme>
```

- `<fichier_puzzle>` : Le chemin vers le fichier texte contenant le puzzle.
- `<algorithme>` : L'algorithme à utiliser. Choix possibles : `bfs`, `dfs`, `astar`, `iddfs`.

### Exemples

Résoudre un puzzle avec l'algorithme **A*** (recommandé) :
```bash
python3 solve_npuzzle.py benchmarks_data/benchmarks/npuzzle_5x5_len1_0.txt -a astar -v
```

Résoudre avec **DFS** :
```bash
python3 solve_npuzzle.py my_puzzle.txt -a dfs
```

### Options supplémentaires

- `-v`, `--verbose` : Affiche plus de détails sur la sortie.
- `-d`, `--max_depth` : Définit la profondeur maximale pour **IDDFS** (par défaut 100).

---

## Benchmarks et Comparaison

Pour comparer les performances des différents algorithmes (BFS, DFS, A*, IDDFS) et générer un graphique.

### Lancer le Benchmark

Exécutez le script suivant :

```bash
python3 benchmark_plot.py
```

Ce script va :
1.  Générer une série de puzzles de difficulté croissante.
2.  Tenter de les résoudre avec chaque algorithme.
3.  Mesurer le temps d'exécution.
4.  Générer une image **`benchmark_performance.png`** avec les courbes de performance.

### Résultats

Une fois le script terminé, ouvrez l'image `benchmark_performance.png` pour visualiser les résultats.
- **Axe X** : Difficulté des puzzles (triés par temps BFS).
- **Axe Y** : Temps de résolution (échelle logarithmique).
