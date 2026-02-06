
from npuzzle import (Solution,
                     State,
                     Move,
                     UP, 
                     DOWN, 
                     LEFT, 
                     RIGHT,
                     create_goal,
                     get_children,
                     is_goal,
                     is_solution,
                     load_puzzle,
                     to_string)
from node import Node
from typing import Literal, List
import argparse
import math
import time

BFS = 'bfs'
DFS = 'dfs'
ASTAR = 'astar'
IDDFS = 'iddfs'

def solve_bfs(open : List[Node]) -> Solution:
    #Préparer les outils
    visited = set()
    dimension = int(math.sqrt(len(open[0].state)))
    goal_state = create_goal(dimension)
    moves_list = [UP, DOWN, LEFT, RIGHT]

    visited.add(tuple(open[0].get_state()))

    while open:
        current_node = open.pop(0)
        current_state = current_node.get_state()

        
        if is_goal(current_state, goal_state):
            return current_node.get_path()

        # Explorer les voisins
        for child_state, move in get_children(current_state, moves_list, dimension):
            # On vérifie si on a déjà vu ce puzzle
            if tuple(child_state) not in visited:
                visited.add(tuple(child_state))
                
                # On crée un nouveau Nœud qui pointe vers le parent actuel
                new_node = Node(state=child_state, move=move, parent=current_node)
                open.append(new_node)

    return None


def solve_dfs(open : List[Node]) -> Solution:
    '''Solve the puzzle using the DFS algorithm'''

    # Todo: implement DFS algorithm
    pass

def solve_astar(open : List[Node]) -> Solution:
    '''Solve the puzzle using the A* algorithm'''
    
    # Todo: implement A* algorithm
    pass

def heuristic(current_state : State, goal_state : State) -> int:
    '''Calculate the Manhattan distance of the puzzle'''
    
    # Todo: implement the heuristic function
    pass

def depth_limited_search(node: Node, limit: int, goal_state: State, moves: List[Move], dimension: int) -> Solution | None:
    '''Perform a depth-limited search'''
    
    # Todo: implement depth-limited search
    pass

def solve_iddfs(root: Node, max_depth: int) -> Solution:
    '''Solve the puzzle using the Iterative Deepening Depth-First Search algorithm'''
    
    # Todo: implement IDDFS algorithm
    pass

def main():
    parser = argparse.ArgumentParser(description='Load an n-puzzle and solve it.')
    parser.add_argument('filename', type=str, help='File name of the puzzle')
    parser.add_argument('-a', '--algo', type=str, choices=['bfs', 'dfs', 'astar', 'iddfs'], required=True, help='Algorithm to solve the puzzle')
    parser.add_argument('-v', '--verbose', action='store_true', help='Increase output verbosity')
    parser.add_argument('-d', '--max_depth', type=int, default=100, help='Maximum depth for IDDFS')
    
    args = parser.parse_args()
    
    puzzle = load_puzzle(args.filename)
    
    if args.verbose:
        print('Puzzle:\n')
        print(to_string(puzzle))
    
    if not is_goal(puzzle, create_goal(int(math.sqrt(len(puzzle))))):   
         
        root = Node(state = puzzle, move = None)
        open = [root]
        
        if args.algo == BFS:
            print('BFS\n')
            start_time = time.time()
            solution = solve_bfs(open)
            duration = time.time() - start_time
            if solution:
                print('Solution:', solution)
                print('Valid solution:', is_solution(puzzle, solution))
                print('Duration:', duration)
            else:
                print('No solution')
        elif args.algo == DFS:
            print('DFS\n')
            start_time = time.time()
            solution = solve_dfs(open)
            duration = time.time() - start_time
            if solution:
                print('Solution:', solution)
                print('Valid solution:', is_solution(puzzle, solution))
                print('Duration:', duration)
            else:
                print('No solution')
        elif args.algo == ASTAR:
            print('A*')
            start_time = time.time()
            solution = solve_astar(open)
            duration = time.time() - start_time
            if solution:
                print('Solution:', solution)
                print('Valid solution:', is_solution(puzzle, solution))
                print('Duration:', duration)
        elif args.algo == IDDFS:
            print('IDDFS')
            start_time = time.time()
            solution = solve_iddfs(root, args.max_depth)
            duration = time.time() - start_time
            if solution:
                print('Solution:', solution)
                print('Valid solution:', is_solution(puzzle, solution))
                print('Duration:', duration)        
            else:
                print('No solution')
    else:
        print('Puzzle is already solved')
    
if __name__ == '__main__':
    main()