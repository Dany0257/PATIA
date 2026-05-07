import npuzzle
from node import Node
import solve_npuzzle
import time
import matplotlib.pyplot as plt
import copy
import math
import sys

# Increase recursion depth for deep DFS
sys.setrecursionlimit(5000)

def generate_puzzles(size, max_length, num_per_length):
    puzzles = []
    goal = npuzzle.create_goal(size)
    print(f"Generating puzzles of size {size}x{size}...")
    
    for length in range(1, max_length + 1):
        for _ in range(num_per_length):
            state = npuzzle.shuffle(goal)
            # Shuffle further to approximate difficulty
            for _ in range(length - 1):
                state = npuzzle.shuffle(state)
            puzzles.append(state)
    return puzzles

def run_benchmark():
    # Configuration
    SIZES = [3, 4]
    MAX_LENGTHS = {3: 15, 4: 5} # 4x4 is much harder, so we limit the shuffle length
    NUM_PER_LENGTH = 2 
    
    all_results = []
    
    import os
    puzzle_dir = "benchmarks_data/generated"
    sol_dir = "benchmarks_data/solutions"
    os.makedirs(puzzle_dir, exist_ok=True)
    os.makedirs(sol_dir, exist_ok=True)
    
    for size in SIZES:
        max_len = MAX_LENGTHS.get(size, 5)
        puzzles = generate_puzzles(size, max_len, NUM_PER_LENGTH)
        print(f"Benchmarking {len(puzzles)} puzzles of size {size}x{size}...")
        
        for i, puzzle in enumerate(puzzles):
            # Save the puzzle to a file
            puzzle_filename = f"{puzzle_dir}/puzzle_{size}x{size}_idx{i}.txt"
            npuzzle.save_puzzle(puzzle, puzzle_filename)
            
            # Base name for solution files
            sol_basename = f"{sol_dir}/puzzle_{size}x{size}_idx{i}"
            
            if i % 5 == 0:
                print(f"Processing {size}x{size} puzzle {i+1}/{len(puzzles)}...")
                
            res = {'id': f"{size}x{size}_{i}", 'size': size, 'filename': puzzle_filename}
            
            dimension = size
            goal = npuzzle.create_goal(dimension)
            
            # --- BFS ---
            root = Node(state=puzzle, move=None)
            start = time.time()
            if size == 3:
                try:
                    sol_bfs = solve_npuzzle.solve_bfs([root])
                    duration = time.time() - start
                    res['bfs'] = duration
                    # Save BFS solution and time
                    with open(f"{sol_basename}_sol_bfs.txt", 'w') as f:
                        f.write(f"Algorithm: BFS\nTime: {duration} seconds\nSolution: {' '.join(sol_bfs) if sol_bfs else 'No solution'}")
                except Exception:
                    res['bfs'] = float('inf')
            else:
                res['bfs'] = float('inf') # Skip BFS for 4x4
                
            # --- DFS ---
            root = Node(state=puzzle, move=None)
            start = time.time()
            if size == 3:
                try:
                    sol_dfs = solve_npuzzle.solve_dfs([root])
                    duration = time.time() - start
                    res['dfs'] = duration
                    # Save DFS solution and time
                    with open(f"{sol_basename}_sol_dfs.txt", 'w') as f:
                        f.write(f"Algorithm: DFS\nTime: {duration} seconds\nSolution: {' '.join(sol_dfs) if sol_dfs else 'No solution'}")
                except Exception:
                     res['dfs'] = float('inf')
            else:
                res['dfs'] = float('inf') # Skip DFS for 4x4
                
            # --- A* ---
            root = Node(state=puzzle, move=None)
            start = time.time()
            try:
                sol_astar = solve_npuzzle.solve_astar([root])
                duration = time.time() - start
                res['astar'] = duration
                # Save A* solution and time
                with open(f"{sol_basename}_sol_astar.txt", 'w') as f:
                    f.write(f"Algorithm: A*\nTime: {duration} seconds\nSolution: {' '.join(sol_astar) if sol_astar else 'No solution'}")
            except Exception:
                res['astar'] = float('inf')
                
            # --- IDDFS ---
            root = Node(state=puzzle, move=None)
            start = time.time()
            try:
                # Limit depth further for 4x4 to avoid long waits
                max_d = 10 if size == 4 else 50
                sol_iddfs = solve_npuzzle.solve_iddfs(root, max_depth=max_d)
                duration = time.time() - start
                res['iddfs'] = duration
                # Save IDDFS solution and time
                with open(f"{sol_basename}_sol_iddfs.txt", 'w') as f:
                    f.write(f"Algorithm: IDDFS\nTime: {duration} seconds\nSolution: {' '.join(sol_iddfs) if sol_iddfs else 'No solution'}")
            except Exception:
                res['iddfs'] = float('inf')

            all_results.append(res)

    # Sort ALL results by BFS time (Difficulty according to instructions)
    # If BFS is inf, we push them to the end and sort them by size then A*
    all_results.sort(key=lambda x: (
        x['bfs'] if x['bfs'] != float('inf') else 9999, 
        x['size'], 
        x['astar'] if x['astar'] != float('inf') else 9999
    ))
    
    valid_results = all_results # We want to plot all, even if BFS is inf
    
    # Plotting
    x = range(len(valid_results))
    bfs_times = [r['bfs'] for r in valid_results]
    dfs_times = [r['dfs'] for r in valid_results]
    astar_times = [r['astar'] for r in valid_results]
    iddfs_times = [r['iddfs'] for r in valid_results]
    
    plt.figure(figsize=(12, 8))
    plt.plot(x, bfs_times, label='BFS (Reference)', marker='o', markersize=3)
    plt.plot(x, dfs_times, label='DFS', alpha=0.7)
    plt.plot(x, astar_times, label='A*', alpha=0.7)
    plt.plot(x, iddfs_times, label='IDDFS', alpha=0.7)
    
    # --- Visual improvements for readability ---
    # Find the transition point between sizes
    for i in range(len(valid_results) - 1):
        if valid_results[i]['size'] != valid_results[i+1]['size']:
            split_x = i + 0.5
            plt.axvline(x=split_x, color='black', linestyle='--', alpha=0.5)
            # Add text labels
            plt.text(split_x / 2, plt.ylim()[1] * 0.5, 'Section 3x3', 
                     horizontalalignment='center', fontweight='bold', fontsize=12)
            plt.text(split_x + (len(valid_results) - split_x) / 2, plt.ylim()[1] * 0.5, 'Section 4x4', 
                     horizontalalignment='center', fontweight='bold', fontsize=12)
            break

    plt.xlabel('Puzzles (Sorted by BFS Difficulty)')
    plt.ylabel('Time (seconds)')
    plt.title('Performance Comparison: 3x3 vs 4x4 N-Puzzle')
    plt.legend(loc='upper left')
    plt.grid(True, which="both", ls="-", alpha=0.2)
    plt.yscale('log')
    
    output_file = 'benchmark_performance.png'
    plt.savefig(output_file)
    print(f"Plot saved to {output_file}")

if __name__ == "__main__":
    run_benchmark()
