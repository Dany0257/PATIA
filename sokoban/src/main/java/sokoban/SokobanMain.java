package sokoban;

import com.codingame.gameengine.runner.SoloGameRunner;
import java.io.File;

public class SokobanMain {
    public static void main(String[] args) throws Exception {

        // 1. Vérifie si les solutions doivent être générées
        File solutionsDir = new File("solutions_json");
        if (!solutionsDir.exists() || solutionsDir.list() == null || solutionsDir.list().length < 30) {
            System.out.println("Première exécution : Génération du pipeline PDDL...");
            GenPDDL.main(new String[0]);
            GenPlan.main(new String[0]);
            GenJson.main(new String[0]);
        }

        SoloGameRunner gameRunner = new SoloGameRunner();
        gameRunner.setAgent(Agent.class);
        gameRunner.setTestCase("test30.json");

        gameRunner.start();
    }
}
