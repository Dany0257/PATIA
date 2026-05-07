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

#---

## Organisation des données de Benchmark

Lors de l'exécution du script `benchmark_plot.py`, les puzzles générés pour construire le graphique sont automatiquement sauvegardés dans le dossier :
`benchmarks_data/generated/`

### Convention de nommage
Les fichiers sont nommés selon le format : `puzzle_[TAILLE]_idx[INDEX].txt`
*   **TAILLE** : Dimension du puzzle (ex: 3x3, 4x4).
*   **INDEX** : Position du puzzle dans la série de tests.

### Comprendre la difficulté (IDX)
L'index (`idx`) permet de retrouver la difficulté (le nombre de mélanges aléatoires appliqués) :
*   `idx 0-1` : Mélangé 1 fois.
*   `idx 2-3` : Mélangé 2 fois.
*   `idx 4-5` : Mélangé 3 fois.
*   *...et ainsi de suite.*

Ces fichiers permettent de rejouer exactement les mêmes tests sur d'autres outils (comme des planificateurs PDDL pour le TP2).

---

## Résultats

Une fois le script terminé, ouvrez l'image `benchmark_performance.png` pour visualiser les résultats.
- **Axe X** : Difficulté des puzzles (triés par temps BFS).
- **Axe Y** : Temps de résolution (échelle logarithmique).

---

## Choix Techniques et Algorithmes

### Générateur de taquins
Le script **`generate_npuzzle.py`** est fourni pour générer des puzzles personnalisés. Il permet de créer des problèmes de taille $N \times N$ avec un nombre de mélanges contrôlé pour ajuster la difficulté.

### Encodage de l'état
L'état du puzzle est représenté par une **liste unidimensionnelle d'entiers** (ex: `[0, 1, 2, 3...]`). 
*   La valeur `0` représente la case vide.
*   Les coordonnées 2D (ligne, colonne) sont calculées dynamiquement : `row = index // dimension` et `col = index % dimension`.
*   Cet encodage est optimal pour la comparaison d'états et limite la consommation mémoire.

### Comparaison des Algorithmes

| Algorithme | Type | Avantages | Inconvénients |
| :--- | :--- | :--- | :--- |
| **BFS** | Aveugle | Garanti de trouver la solution la plus courte (Optimal). | Explosion mémoire exponentielle. Inutilisable sur 4x4. |
| **DFS** | Aveugle | Très peu de mémoire utilisée. | Ne trouve pas le chemin le plus court. Peut tourner en boucle infinie. |
| **A\*** | Informé | **Le meilleur.** Très rapide et optimal grâce à l'heuristique. | Nécessite une bonne fonction heuristique (Manhattan). |
| **IDDFS** | Hybride | Optimal comme le BFS, économe en mémoire comme le DFS. | Plus lent car il recalcule les niveaux plusieurs fois. |

---

## Interprétation des Résultats (Benchmarks)

Le graphique **`benchmark_performance.png`** met en évidence les comportements suivants :

1.  **BFS (Bleu)** : On observe une courbe qui monte de façon exponentielle. C'est la référence de difficulté. Elle s'arrête brutalement au passage au 4x4 car l'algorithme sature la mémoire.
2.  **A\* (Vert)** : C'est la courbe la plus basse et la plus stable. Grâce à la **distance de Manhattan**, elle reste efficace même sur les puzzles 4x4 où les autres échouent. C'est l'algorithme le plus performant.
3.  **DFS (Orange)** : La courbe est chaotique et présente des trous. Cela montre l'instabilité de l'algorithme qui échoue dès qu'il s'enfonce dans une mauvaise branche ou dépasse la limite de récursion.
4.  **IDDFS (Rouge)** : Elle suit globalement le BFS mais survit au passage au 4x4. Elle est plus lente que A* car elle n'est pas "guidée" par une heuristique, elle doit tout explorer couche par couche.

**Conclusion du benchmark :** Pour le problème du taquin, la recherche informée (**A\***) est indispensable dès que la taille du plateau ou la profondeur du mélange augmente.
