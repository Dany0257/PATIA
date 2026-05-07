# TP YetAnotherSATPlanner

**AUTHOR :** `GIRINCUTI DANY CAROL`  
---

## 1. Description du projet
Dans ce projet, j'ai implémenté un planificateur formel s'appuyant sur l'approche **SAT (Satisfiability logic)**, en traduisant au format DIMACS des fichiers "Domain" et "Problem" décrits en PDDL.  
Mon encodage complet inclut l'état initial, les préconditions et effets des actions, l'exclusion mutuelle (une seule action par étape) et les fameux axiomes de maintien de l'état (frame axioms). Ma résolution itérative (Step = 1, 2, ... k) trouve ainsi formellement le premier graphe solution, garantissant que mon plan est optimal avec la longueur la plus courte possible (makespan).

**Structure de mon projet :**
- `src/` : Mon code source Java (Implémentations de l'encodage dans `SATEncoding.java` et de l'algorithme d'exploration dans `YetAnotherSATPlanner.java`).
- `lib/` : Librairies obligatoires (PDDL4J et SAT4J).
- `benchmarks/` : Dossier contenant le domaine et les problèmes Taquin (pour la preuve).
- `results/` : Dossier contenant les graphiques de performance sur le Taquin.
- `benchmark.py` : Mon script Python pour les évaluations automatisées.
- `yetanothersatplanner.sh` : Mon script Bash utilitaire.

---

## 2. Utilisation & Compilation

**Pour compiler mon projet manuellement :**
```bash
chmod +x yetanothersatplanner.sh
./yetanothersatplanner.sh
# Choisir Option 1 (Compile) puis Option 2 (Solve) pour lancer un test.
# Utiliser "taquin-domain.pddl" et "taquin-p01.pddl" (à la racine) pour un test rapide.
```

---


## 3. Preuve de Fonctionnement et Résultats (Taquin)

Conformément aux consignes, j'ai utilisé le domaine du **Taquin** comme preuve de bon fonctionnement de mon solveur SAT. J'ai développé le fichier `benchmark.py` pour automatiser les tests et générer les courbes de performance situées dans le dossier `results/`.

### Preuve sur le Taquin (3x3)

Mon planificateur a été testé sur **3 problèmes Taquin de difficulté croissante** (inclus dans le dossier `benchmarks/taquin/`) afin de démontrer sa robustesse et de générer des courbes de performance significatives.

- **Fichiers de preuve immédiate :** `taquin-domain.pddl` et `taquin-p01.pddl` sont situés à la racine pour un test rapide.
- **Résultats :** Les graphiques `results/taquin_runtime.png` et `results/taquin_makespan.png` compilent les résultats de ces tests et montrent l'évolution du temps de calcul par rapport à la complexité du problème.

### Interprétation des résultats

1. **taquin_runtime (Temps d'exécution)** :
   - **Analyse :** On remarque que la courbe de YASP (SAT) croît beaucoup plus vite que celle de HSP. Pour chaque étape (step), l'encodage génère des millions de clauses DIMACS, rendant la résolution plus coûteuse en temps à mesure que la profondeur du plan augmente.
   - **Conclusion :** L'approche SAT est puissante mais "coûteuse" en ressources de calcul par rapport à une recherche heuristique guidée comme HSP.

2. **taquin_makespan (Longueur du plan)** :
   - **Analyse :** YASP trouve systématiquement le plan le plus court (makespan optimal). En testant itérativement chaque profondeur $k=1, 2, ...$, il garantit de trouver la solution la plus proche de l'état initial. HSP, bien que plus rapide, peut fournir un plan sous-optimal (plus long).
   - **Conclusion :** Mon implémentation SAT est un **planificateur optimal**.

### Conclusion sur l'approche SAT
- **Makespan (Optimalité) :** Mon SATPlanner (YASP) est optimal par définition mathématique : il trouve toujours le plan le plus court possible.
- **Runtime (Efficacité) :** En raison du coût d'encodage (millions de clauses pour les problèmes complexes comme le Taquin), l'approche SAT est plus lente que les approches heuristiques (comme HSP), mais elle offre une garantie d'optimalité stricte sur la longueur du plan.

---

## 4. Lien avec les transparents de cours (patia_5)

Mon implémentation suit directement les concepts enseignés dans les **transparents patia_5** du cours de 
Planification Automatique :
**Pipeline :** Encodage PDDL → Formule SAT → Solveur → Décodage du plan.

Comment j'ai procédé :
J'ai divisé le travail en deux classes. SATEncoding construit la formule en format DIMACS à partir du problème PDDL instancié par PDDL4J. YetAnotherSATPlanner orchestre la recherche : il démarre au nombre de steps donné par l'heuristique FF (borne inférieure), soumet la formule au solveur SAT4J (MiniSat), et incrémente le nombre de steps tant qu'aucune solution n'est trouvée.

| Concept (patia_5)                              | Mon implémentation dans le code                                                                      |
|------------------------------------------------|--------------------------------------------------------------------------------------------------|
| **Pipeline d'encodage SAT** (diapo 3)          | Ma méthode `solve()` dans `YetAnotherSATPlanner.java` : parse PDDL → encode → SAT solver → plan     |
| **Format DIMACS** (diapos 4–5)                 | `SATEncoding.currentDimacs` : ma liste de clauses int[] en format DIMACS, envoyée à SAT4J           |
| **État initial** - clauses unitaires           | `SATEncoding.encode()` : chaque fluent vrai à t=0 → clause `+var`, chaque fluent faux → `-var`   |
| **Préconditions** - `¬a_i ∨ pre(a)_i`          | `SATEncoding.encode()` : boucle sur les actions, clause `[-actionVar, +preVar]` par précondition  |
| **Effets positifs** - `¬a_i ∨ eff⁺(a)_{i+1}`  | `SATEncoding.encode()` : clause `[-actionVar, +effVar_next]` par effet positif                   |
| **Effets négatifs** - `¬a_i ∨ ¬eff⁻(a)_{i+1}` | `SATEncoding.encode()` : clause `[-actionVar, -effVar_next]` par effet négatif                   |
| **Axiomes de frame** (diapos 8–9)              | `SATEncoding.encode()` : `f_i ∧ ¬f_{i+1} → ∨ del_actions` et `¬f_i ∧ f_{i+1} → ∨ add_actions` |
| **Exclusion mutuelle** (mutex)                 | `SATEncoding.encode()` : pour chaque paire d'actions (a1, a2) : clause `[-a1_i, -a2_i]`         |
| **Davis-Putnam / Propagation unitaire** (diapo 6–7) | Délégué entièrement à **SAT4J (MiniSat)** via `ISolver` de org.sat4j.minisat                |
| **Itération sur les étapes (step=1,2,...k)**   | `YetAnotherSATPlanner.java` : ma boucle `while(!solved)` avec `satEncoding.next()` à chaque tour    |
| **Fonction de Cantor** (variable unique/étape) | `SATEncoding.pair(num, step)` : `0.5*(num+step)*(num+step+1)+step` → entier unique par (fluent, t)|
| **Borne inférieure via heuristique FF**        | `YetAnotherSATPlanner.java` : `FastForward.solve()` me donne le `steps` initial avant la boucle SAT |

---

## 5. Réflexion : SAT vs PDDL (Exercice 2)

**Question de base :** *"L'encodage SAT d'algorithmes aléatoires 3SAT via traducteur PDDL modifie-t-il la difficulté du problème de départ autour de la zone r=4.27 ?"*

**Ma réponse formelle :** 
Contrairement aux instances 3SAT indépendantes classiques (r=4.27) qui sont à la lisière absolue de la NP-Complétude, **le nouveau problème encodé sera affreusement plus complexe et long à résoudre**.

Les raisons fondamentales :
1. **L'inflation des clauses (Axiomes de "Frame") :** Afin de mimer le fait que je suis dans un "monde" (au lieu d'un simple tableau de variables abstraites), mon encodeur PDDL a l'obligation de matraquer le solveur de clauses ultra-verbeuses pour signifier "Si je n'ai pas touché à cette variable, maintiens-la à son état entre le temps $i$ et $i+1$".
2. **Le ratio Clause/Variables $r$ perverti :** Je multiplie mathématiquement le nombre de variables et de contraintes de manière linéaire par un grand entier (les $steps$ du Makespan), tout en forçant l'algorithme sous forme d'entonnoir (Disjonction d'action). Le Ratio $r$ devient artificiel car ces formules SAT regorgent de clauses de symétrie et de propagation au lieu d'informations critiques qui cassent un état de vérité. 
En modélisant ce qu'on appelle "le Temps", la base perd son aspect compact pour se dissoudre dans des implications chronophages, allongeant dramatiquement la recherche des solveurs universels (comme MiniSat).
