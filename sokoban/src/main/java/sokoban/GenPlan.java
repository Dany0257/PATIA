package sokoban;

import java.io.*;
import java.util.*;
import fr.uga.pddl4j.parser.DefaultParsedProblem;
import fr.uga.pddl4j.parser.Parser;
import fr.uga.pddl4j.plan.Plan;
import fr.uga.pddl4j.planners.statespace.HSP;
import fr.uga.pddl4j.problem.Problem;
import fr.uga.pddl4j.problem.operator.Action;

/**
 * Java translation of the bash solve script.
 * Solves all PDDL problems in 'generated_pddl' and saves plans to 'plans/'.
 */
public class GenPlan {

    private static final String DOMAIN_FILE = "src/main/resources/sokoban-domain.pddl";
    private static final String PDDL_DIR = "generated_pddl";
    private static final String PLAN_DIR = "plans";
    private static final int TIMEOUT = 400; // seconds

    public static void main(String[] args) throws Exception {
        // Fix ClassLoader pour PDDL4J (Indispensable pour éviter les erreurs
        // jdk.internal)
        ClassLoader cl = GenPlan.class.getClassLoader();
        if (cl instanceof javassist.Loader) {
            javassist.Loader jcl = (javassist.Loader) cl;
            for (String pkg : new String[] { "java.", "javax.", "sun.", "com.sun.", "org.w3c.", "org.xml.", "jdk." }) {
                jcl.delegateLoadingOf(pkg);
            }
        }
        Thread.currentThread().setContextClassLoader(cl);

        File planDir = new File(PLAN_DIR);
        if (!planDir.exists())
            planDir.mkdirs();

        File domainFile = new File(DOMAIN_FILE);
        if (!domainFile.exists()) {
            System.err.println("Erreur : Fichier domaine manquant : " + DOMAIN_FILE);
            return;
        }

        Parser parser = new Parser();
        HSP hsp = new HSP();
        // Configuration de l'heuristique (FAST_FORWARD correspond à la constante 5 ou
        // au réglage par défaut de HSP)
        hsp.setTimeout(TIMEOUT * 1000);

        for (int i = 1; i <= 30; i++) {
            String levelNum = String.format("%02d", i);
            File problemFile = new File(PDDL_DIR + "/problem_" + levelNum + ".pddl");

            if (!problemFile.exists()) {
                System.out.println(" Résolution niveau " + levelNum + "... Fichier manquant");
                continue;
            }

            System.out.println(" Résolution niveau " + levelNum + "...");
            try {
                DefaultParsedProblem pb = parser.parse(domainFile, problemFile);
                Problem problem = hsp.instantiate(pb);
                Plan plan = hsp.solve(problem);

                if (plan != null && !plan.actions().isEmpty()) {
                    String outputPlanPath = PLAN_DIR + "/plan_" + levelNum + ".txt";
                    try (PrintWriter pw = new PrintWriter(new FileWriter(outputPlanPath))) {
                        for (Action a : plan.actions()) {
                            // On reproduit le format texte attendu (nom de l'action en minuscule)
                            pw.println(a.getName().toLowerCase());
                        }
                    }
                    System.out.println(" -> Plan généré : " + outputPlanPath);
                } else {
                    System.out.println(" -> Aucun plan trouvé.");
                }
            } catch (Exception e) {
                System.err.println(" -> Erreur lors de la résolution : " + e.getMessage());
            }
        }

        System.out.println("\n Tous les niveaux ont été traités.");
    }
}
