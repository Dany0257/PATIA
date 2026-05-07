import os
import subprocess
import time
import matplotlib.pyplot as plt
import re

DOMAINS = ['taquin']
TIMEOUT = 10 # seconds

def parse_pddl4j_output(output):
    # Total runtime is in the stdout as: "xxx seconds total time"
    # Plan length is the number of steps output or we can count lines matching `^\d+:`
    time_spent = None
    makespan = 0
    for line in output.split('\n'):
        line = line.strip()
        time_match = re.search(r'([\d,]+) seconds total time', line)
        if time_match:
            time_spent = float(time_match.group(1).replace(',', '.'))
        
        if re.match(r'^\d+:', line):
            makespan += 1
            
    return time_spent, makespan

def parse_yasp_output(output):
    # Time is not explicitly printed in "seconds total time" in my script?
    # I'll just rely on python time for SAT planner if not present
    makespan = 0
    for line in output.split('\n'):
        line = line.strip()
        if re.match(r'^\d+:\s*\(', line):
            makespan += 1
    return makespan

def run_planner(planner_class, domain_file, problem_file):
    cmd = [
        "java", "-cp", "classes:lib/pddl4j-4.0.0.jar:lib/org.sat4j.core.jar",
        "-server", "-Xms2048m", "-Xmx2048m", planner_class,
        domain_file, problem_file
    ]
    start_time = time.time()
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=TIMEOUT)
        end_time = time.time()
        output = res.stdout + res.stderr
        return output, end_time - start_time
    except subprocess.TimeoutExpired:
        return None, TIMEOUT

def benchmark():
    results = {
        'HSP': {'time': {}, 'makespan': {}},
        'YASP': {'time': {}, 'makespan': {}}
    }

    base_dir = "benchmarks"
    
    for domain in DOMAINS:
        print(f"Benchmarking domain: {domain}")
        domain_dir = os.path.join(base_dir, domain)
        
        found = False
        for root, dirs, files in sorted(os.walk(domain_dir), key=lambda x: x[0]):
            # Try to prioritize some directories if possible, but first match should work
            if "domain.pddl" in files:
                domain_dir = root
                found = True
                break
                
        if not found:
            print(f"  Cannot find domain.pddl for {domain}")
            continue

        # Look for domain.pddl and pXX.pddl files
        domain_file = os.path.join(domain_dir, "domain.pddl")
        problems = sorted([f for f in os.listdir(domain_dir) if f.startswith('p') and f.endswith('.pddl')])
        
        # We limit to first 3 problems to avoid taking too much time
        problems = problems[:3]

        results['HSP']['time'][domain] = []
        results['HSP']['makespan'][domain] = []
        results['YASP']['time'][domain] = []
        results['YASP']['makespan'][domain] = []
        x_labels = problems

        for problem in problems:
            print(f"  Problem: {problem}")
            prob_file = os.path.join(domain_dir, problem)

            # Benchmark HSP
            print("    Running HSP... ", end='', flush=True)
            out_hsp, t_hsp = run_planner("fr.uga.pddl4j.planners.statespace.HSP", domain_file, prob_file)
            if out_hsp:
                parsed_t_hsp, makespan_hsp = parse_pddl4j_output(out_hsp)
                t_hsp = parsed_t_hsp if parsed_t_hsp is not None else t_hsp
                print(f"Done in {t_hsp:.2f}s (Makespan: {makespan_hsp})")
            else:
                t_hsp = TIMEOUT
                makespan_hsp = 0
                print(f"TIMEOUT (>{TIMEOUT}s)")
                
            results['HSP']['time'][domain].append(t_hsp)
            results['HSP']['makespan'][domain].append(makespan_hsp)

            # Benchmark YASP
            print("    Running YASP... ", end='', flush=True)
            out_yasp, t_yasp = run_planner("fr.uga.pddl4j.yasp.YetAnotherSATPlanner", domain_file, prob_file)
            if out_yasp:
                makespan_yasp = parse_yasp_output(out_yasp)
                print(f"Done in {t_yasp:.2f}s (Makespan: {makespan_yasp})")
            else:
                t_yasp = TIMEOUT
                makespan_yasp = 0
                print(f"TIMEOUT (>{TIMEOUT}s)")

            results['YASP']['time'][domain].append(t_yasp)
            results['YASP']['makespan'][domain].append(makespan_yasp)

        # Ensure results directory exists
        os.makedirs('results', exist_ok=True)
        
        # Sort data by HSP runtime before plotting
        combined = list(zip(
            results['HSP']['time'][domain],
            x_labels,
            results['HSP']['makespan'][domain],
            results['YASP']['time'][domain],
            results['YASP']['makespan'][domain]
        ))
        combined.sort(key=lambda x: x[0]) # sort by HSP time
        
        results['HSP']['time'][domain] = [x[0] for x in combined]
        x_labels = [x[1] for x in combined]
        results['HSP']['makespan'][domain] = [x[2] for x in combined]
        results['YASP']['time'][domain] = [x[3] for x in combined]
        results['YASP']['makespan'][domain] = [x[4] for x in combined]

        # PLOTTING
        fig, ax = plt.subplots(figsize=(10, 5))
        ax.plot(x_labels, results['HSP']['time'][domain], marker='o', label='HSP')
        ax.plot(x_labels, results['YASP']['time'][domain], marker='x', label='YASP')
        ax.set_title(f'Runtime Comparison on {domain.capitalize()}')
        ax.set_xlabel('Problems (increasing difficulty)')
        ax.set_ylabel('Runtime (seconds)')
        ax.legend()
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig(f'results/{domain}_runtime.png')
        plt.close()

        fig, ax = plt.subplots(figsize=(10, 5))
        ax.plot(x_labels, results['HSP']['makespan'][domain], marker='o', label='HSP')
        ax.plot(x_labels, results['YASP']['makespan'][domain], marker='x', label='YASP')
        ax.set_title(f'Makespan Comparison on {domain.capitalize()}')
        ax.set_xlabel('Problems (increasing difficulty)')
        ax.set_ylabel('Makespan (steps)')
        ax.legend()
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig(f'results/{domain}_makespan.png')
        plt.close()

if __name__ == "__main__":
    benchmark()
