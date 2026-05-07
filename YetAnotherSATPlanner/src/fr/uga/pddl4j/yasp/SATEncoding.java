package fr.uga.pddl4j.yasp;

import fr.uga.pddl4j.plan.Plan;
import fr.uga.pddl4j.plan.SequentialPlan;
import fr.uga.pddl4j.problem.Fluent;
import fr.uga.pddl4j.problem.Problem;
import fr.uga.pddl4j.problem.operator.Action;
import fr.uga.pddl4j.util.BitVector;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * This class implements a planning problem/domain encoding into DIMACS
 *
 * @author H. Fiorino
 * @version 0.1 - 30.03.2024
 */
public final class SATEncoding {
    /*
     * A SAT problem in dimacs format is a list of int list a.k.a clauses
     */
    private List<List<Integer>> initList = new ArrayList<List<Integer>>();

    /*
     * Goal
     */
    private List<Integer> goalList = new ArrayList<Integer>();

    /*
     * Actions
     */
    private List<List<Integer>> actionPreconditionList = new ArrayList<List<Integer>>();
    private List<List<Integer>> actionEffectList = new ArrayList<List<Integer>>();

    /*
     * State transistions
     */
    private HashMap<Integer, List<Integer>> addList = new HashMap<Integer, List<Integer>>();
    private HashMap<Integer, List<Integer>> delList = new HashMap<Integer, List<Integer>>();
    private List<List<Integer>> stateTransitionList = new ArrayList<List<Integer>>();

    /*
     * Action disjunctions
     */
    private List<List<Integer>> actionDisjunctionList = new ArrayList<List<Integer>>();

    /*
     * Current DIMACS encoding of the planning domain and problem for #steps steps
     * Contains the initial state, actions and action disjunction
     * Goal is no there!
     */
    public List<List<Integer>> currentDimacs = new ArrayList<List<Integer>>();

    /*
     * Current goal encoding
     */
    public List<Integer> currentGoal = new ArrayList<Integer>();

    /*
     * Current number of steps of the SAT encoding
     */
    private int steps;

    private Problem problem;

    public SATEncoding(Problem problem, int steps) {
        this.problem = problem;

        this.steps = steps;

        // Encoding of init
        // Each fact is a unit clause
        // Init state step is 1
        // We get the initial state from the planning problem
        // State is a bit vector where the ith bit at 1 corresponds to the ith fluent
        // being true
        final int nb_fluents = problem.getFluents().size();
        // System.out.println(" fluents = " + nb_fluents );
        final BitVector init = problem.getInitialState().getPositiveFluents();

        // Makes DIMACS encoding from 1 to steps
        encode(1, steps);
    }

    /*
     * SAT encoding for next step
     */
    public void next() {
        this.steps++;
        encode(this.steps, this.steps);
    }

    public String toString(final List<Integer> clause, final Problem problem) {
        final int nb_fluents = problem.getFluents().size();
        List<Integer> dejavu = new ArrayList<Integer>();
        String t = "[";
        String u = "";
        int tmp = 1;
        int[] couple;
        int bitnum;
        int step;
        for (Integer x : clause) {
            if (x > 0) {
                couple = unpair(x);
                bitnum = couple[0];
                step = couple[1];
            } else {
                couple = unpair(-x);
                bitnum = -couple[0];
                step = couple[1];
            }
            t = t + "(" + bitnum + ", " + step + ")";
            t = (tmp == clause.size()) ? t + "]\n" : t + " + ";
            tmp++;
            final int b = Math.abs(bitnum);
            if (!dejavu.contains(b)) {
                dejavu.add(b);
                u = u + b + " >> ";
                if (nb_fluents >= b) {
                    Fluent fluent = problem.getFluents().get(b - 1);
                    u = u + problem.toString(fluent) + "\n";
                } else {
                    u = u + problem.toShortString(problem.getActions().get(b - nb_fluents - 1)) + "\n";
                }
            }
        }
        return t + u;
    }

    public Plan extractPlan(final List<Integer> solution, final Problem problem) {
        Plan plan = new SequentialPlan();
        HashMap<Integer, Action> sequence = new HashMap<Integer, Action>();
        final int nb_fluents = problem.getFluents().size();
        int[] couple;
        int bitnum;
        int step;
        for (Integer x : solution) {
            if (x > 0) {
                couple = unpair(x);
                bitnum = couple[0];
            } else {
                couple = unpair(-x);
                bitnum = -couple[0];
            }
            step = couple[1];
            // This is a positive (asserted) action
            if (bitnum > nb_fluents) {
                final Action action = problem.getActions().get(bitnum - nb_fluents - 1);
                sequence.put(step, action);
            }
        }
        for (int s = sequence.keySet().size(); s > 0; s--) {
            plan.add(0, sequence.get(s));
        }
        return plan;
    }

    // Cantor paring function generates unique numbers
    private static int pair(int num, int step) {
        return (int) (0.5 * (num + step) * (num + step + 1) + step);
    }

    private static int[] unpair(int z) {
        /*
         * Cantor unpair function is the reverse of the pairing function. It takes a
         * single input
         * and returns the two corespoding values.
         */
        int t = (int) (Math.floor((Math.sqrt(8 * z + 1) - 1) / 2));
        int bitnum = t * (t + 3) / 2 - z;
        int step = z - t * (t + 1) / 2;
        return new int[] { bitnum, step }; // Returning an array containing the two numbers
    }

    private void encode(int from, int to) {
        this.currentDimacs.clear();
        this.currentGoal.clear();

        if (problem == null)
            return;

        final int nb_fluents = problem.getFluents().size();
        final int nb_actions = problem.getActions().size();

        // 1. Initial State
        if (from == 1) {
            BitVector init = problem.getInitialState().getPositiveFluents();
            for (int f = 0; f < nb_fluents; f++) {
                List<Integer> clause = new ArrayList<>();
                int bitnum = f + 1;
                clause.add(init.get(f) ? pair(bitnum, 1) : -pair(bitnum, 1));
                this.currentDimacs.add(clause);
            }
        }

        for (int i = from; i <= to; i++) {

            // a) Action preconditions and effects
            for (int a = 0; a < nb_actions; a++) {
                int actionBitnum = a + nb_fluents + 1;
                Action action = problem.getActions().get(a);
                BitVector pre = action.getPrecondition().getPositiveFluents();
                BitVector effPlus = action.getUnconditionalEffect().getPositiveFluents();
                BitVector effMinus = action.getUnconditionalEffect().getNegativeFluents();

                // Preconditions: -a_i V pre_i
                for (int p = pre.nextSetBit(0); p >= 0; p = pre.nextSetBit(p + 1)) {
                    List<Integer> c = new ArrayList<>();
                    c.add(-pair(actionBitnum, i));
                    c.add(pair(p + 1, i));
                    this.currentDimacs.add(c);
                }

                // Positive effects: -a_i V eff+_i+1
                for (int p = effPlus.nextSetBit(0); p >= 0; p = effPlus.nextSetBit(p + 1)) {
                    List<Integer> c = new ArrayList<>();
                    c.add(-pair(actionBitnum, i));
                    c.add(pair(p + 1, i + 1));
                    this.currentDimacs.add(c);
                }

                // Negative effects: -a_i V -eff-_i+1
                for (int p = effMinus.nextSetBit(0); p >= 0; p = effMinus.nextSetBit(p + 1)) {
                    List<Integer> c = new ArrayList<>();
                    c.add(-pair(actionBitnum, i));
                    c.add(-pair(p + 1, i + 1));
                    this.currentDimacs.add(c);
                }
            }

            // b) Frame axioms (State transitions)
            for (int f = 0; f < nb_fluents; f++) {
                int fluentBitnum = f + 1;

                List<Integer> addActions = new ArrayList<>();
                List<Integer> delActions = new ArrayList<>();

                for (int a = 0; a < nb_actions; a++) {
                    Action action = problem.getActions().get(a);
                    if (action.getUnconditionalEffect().getPositiveFluents().get(f)) {
                        addActions.add(a + nb_fluents + 1);
                    }
                    if (action.getUnconditionalEffect().getNegativeFluents().get(f)) {
                        delActions.add(a + nb_fluents + 1);
                    }
                }

                // f_i V -f_i+1 V a1_i V a2_i V ...
                List<Integer> c1 = new ArrayList<>();
                c1.add(pair(fluentBitnum, i));
                c1.add(-pair(fluentBitnum, i + 1));
                for (int a : addActions) {
                    c1.add(pair(a, i));
                }
                this.currentDimacs.add(c1);

                // -f_i V f_i+1 V a1_i V a2_i V ...
                List<Integer> c2 = new ArrayList<>();
                c2.add(-pair(fluentBitnum, i));
                c2.add(pair(fluentBitnum, i + 1));
                for (int a : delActions) {
                    c2.add(pair(a, i));
                }
                this.currentDimacs.add(c2);
            }

            // c) Action disjunction (at most one action per step)
            for (int a1 = 0; a1 < nb_actions; a1++) {
                int b1 = a1 + nb_fluents + 1;
                for (int a2 = a1 + 1; a2 < nb_actions; a2++) {
                    int b2 = a2 + nb_fluents + 1;
                    List<Integer> c = new ArrayList<>();
                    c.add(-pair(b1, i));
                    c.add(-pair(b2, i));
                    this.currentDimacs.add(c);
                }
            }

            // d) Wait, do we also need at least one action?
            // Usually not required but might speed up SAT solver. Let's omit it for now
            // since we want exactly what the assignment describes.
        }

        // 3. Goal
        BitVector goal = problem.getGoal().getPositiveFluents();
        for (int p = goal.nextSetBit(0); p >= 0; p = goal.nextSetBit(p + 1)) {
            this.currentGoal.add(pair(p + 1, to + 1));
        }

        System.out.println("Encoding : successfully done (" + (this.currentDimacs.size()
                + this.currentGoal.size()) + " clauses, " + to + " steps)");
    }

}
