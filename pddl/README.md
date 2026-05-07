# TP Modélisation PDDL

Ce dossier contient les modélisations en langage **PDDL** (Planning Domain Definition Language) que j'ai réalisées dans le cadre du cours PATIA 2026.

## 📁 Contenu de mon TP (Conforme aux consignes)

Conformément aux instructions du rendu, j'ai fourni les éléments suivants :

### 1. Les Tours de Hanoï (`hanoi/`)
- **Mon domaine** (`hanoi-domain.pddl`) : J'ai défini les types (disques, piquets), les prédicats (`on`, `clear`, `smaller`) et l'action unique `move`.
- **Mon problème** (`hanoi-problem.pddl`) : Il s'agit de la configuration classique avec **3 disques** et **3 piquets**. Mon objectif est de déplacer la tour du piquet initial vers le piquet cible en respectant les règles de taille.

### 2. Le Taquin / N-Puzzle (`taquin/`)
- **Mon domaine** (`taquin-domain.pddl`) : J'ai modélisé le taquin (3x3 ou 4x4) en utilisant des prédicats de voisinage (`at`, `neighbor`, `empty`) afin d'optimiser la recherche des planificateurs.
- **Mes problèmes** (`p003.pddl` à `p007.pddl`, `taquin-problem.pddl`) : J'ai inclus une série d'instances de difficulté croissante qui correspondent directement aux problèmes que j'ai résolus lors du TP1 (espace d'états).

---

## 🚀 Utilisation avec PDDL4J

J'ai mis à disposition un script utilitaire `pddl4j.sh` pour lancer facilement les planificateurs **HSP** (Heuristic Search Planner) ou **FF** (Fast Forward) inclus dans la bibliothèque `pddl4j-4.0.0.jar`.

### Lancer le script
```bash
chmod +x pddl4j.sh
./pddl4j.sh
```

### Étapes à suivre dans le menu :
1. Choisissez le planificateur (ex: `1` pour HSP).
2. Entrez le chemin de mon fichier domaine (ex: `hanoi/hanoi-domain.pddl`).
3. Entrez le chemin de mon fichier problème (ex: `hanoi/hanoi-problem.pddl`).
4. (Pour HSP) Choisissez une heuristique (ex: `5` pour FAST_FORWARD ou `7` pour SUM).

---

## 📚 Mes Exercices Complémentaires

En plus des rendus obligatoires, j'ai intégré à ce dépôt d'autres modélisations PDDL que j'ai explorées durant le semestre :
- `blocks/` : Le monde des blocs (blocksworld).
- `logistics/` : Problèmes de transport et logistique.
- `sat/` : Mon encodage de problèmes SAT en PDDL.
- `coloring/`, `hamiltonian/`, `rover/`, `turing/` : Divers problèmes classiques d'IA et de théorie des graphes que j'ai modélisés.

---
**Auteur :** GIRINCUTI Dany Carol  
**Date :** Mai 2026
