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
    SIZE = 3
    MAX_LENGTH = 15 # Generate puzzles with up to 15 random moves from goal
    NUM_PER_LENGTH = 2 
    TIMEOUT = 5.0 # Seconds per solve attempt (soft limit check not implemented in solvers, capturing start/end)

    puzzles = generate_puzzles(SIZE, MAX_LENGTH, NUM_PER_LENGTH)
    results = [] # List of dicts: {'puzzle': index, 'bfs': time, 'dfs': time, 'astar': time, 'iddfs': time}
    
    print(f"Benchmarking {len(puzzles)} puzzles...")
    
    for i, puzzle in enumerate(puzzles):
        if i % 5 == 0:
            print(f"Processing puzzle {i+1}/{len(puzzles)}...")
            
        res = {'id': i}
        
        # Prepare solvers inputs
        dimension = int(math.sqrt(len(puzzle)))
        goal = npuzzle.create_goal(dimension)
        
        # --- BFS ---
        root = Node(state=puzzle, move=None)
        start = time.time()
        try:
            solve_npuzzle.solve_bfs([root])
            res['bfs'] = time.time() - start
        except Exception as e:
            res['bfs'] = float('inf')
            
        # --- DFS ---
        # Re-create root/open because simpler than deepcopying sometimes if modified
        root = Node(state=puzzle, move=None)
        start = time.time()
        try:
            solve_npuzzle.solve_dfs([root])
            res['dfs'] = time.time() - start
        except RecursionError:
             res['dfs'] = float('inf') # Treat as timeout/fail
        except Exception:
             res['dfs'] = float('inf')
            
        # --- A* ---
        root = Node(state=puzzle, move=None)
        start = time.time()
        try:
            solve_npuzzle.solve_astar([root])
            res['astar'] = time.time() - start
        except Exception:
            res['astar'] = float('inf')
            
        # --- IDDFS ---
        root = Node(state=puzzle, move=None)
        start = time.time()
        try:
            solve_npuzzle.solve_iddfs(root, max_depth=50) # Limit max depth to avoid infinite waits
            res['iddfs'] = time.time() - start
        except Exception:
            res['iddfs'] = float('inf')

        results.append(res)

    # Sort puzzles by BFS time (difficulty)
    results.sort(key=lambda x: x['bfs'])
    
    # Plotting
    x = range(len(results))
    bfs_times = [r['bfs'] for r in results]
    dfs_times = [r['dfs'] for r in results]
    astar_times = [r['astar'] for r in results]
    iddfs_times = [r['iddfs'] for r in results]
    
    plt.figure(figsize=(12, 8))
    plt.plot(x, bfs_times, label='BFS (Reference)', marker='o', markersize=3)
    plt.plot(x, dfs_times, label='DFS', alpha=0.7)
    plt.plot(x, astar_times, label='A*', alpha=0.7)
    plt.plot(x, iddfs_times, label='IDDFS', alpha=0.7)
    
    plt.xlabel('Puzzles (Sorted by BFS Difficulty)')
    plt.ylabel('Time (seconds)')
    plt.title('Performance Comparison of N-Puzzle Search Algorithms')
    plt.legend()
    plt.grid(True)
    plt.yscale('log') # Log scale because DFS/IDDFS can blow up
    
    output_file = 'benchmark_performance.png'
    plt.savefig(output_file)
    print(f"Plot saved to {output_file}")

if __name__ == "__main__":
    run_benchmark()
