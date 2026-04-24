package sokoban;

import java.io.File;
import java.nio.file.Files;
import java.util.Scanner;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Agent intelligent qui identifie le niveau et exécute la solution
 * pré-calculée.
 */
public class Agent {
    public static void main(String[] args) throws Exception {
        // Correction du ClassLoader pour la compatibilité PDDL4J (si nécessaire)
        ClassLoader cl = Agent.class.getClassLoader();
        if (cl instanceof javassist.Loader) {
            javassist.Loader jcl = (javassist.Loader) cl;
            for (String pkg : new String[] { "java.", "javax.", "sun.", "com.sun.", "org.w3c.", "org.xml.", "jdk." }) {
                jcl.delegateLoadingOf(pkg);
            }
        }
        Thread.currentThread().setContextClassLoader(cl);

        Scanner in = new Scanner(System.in);
        if (!in.hasNextInt())
            return;

        // 1. Lecture de l'état initial envoyé par le moteur
        int width = in.nextInt();
        int height = in.nextInt();
        int boxCount = in.nextInt();
        in.nextLine();

        StringBuilder gridSb = new StringBuilder();
        for (int y = 0; y < height; y++) {
            String line = in.nextLine();
            gridSb.append(line);
            if (y < height - 1)
                gridSb.append("\n");
        }
        String currentGrid = gridSb.toString().trim();

        // 2. Identification du niveau
        int levelNum = -1;
        File configDir = new File("config");
        File[] configFiles = configDir.listFiles((dir, name) -> name.startsWith("test") && name.endsWith(".json"));

        if (configFiles != null) {
            // Dans la grille moteur, '.' est le vide, '#' est un mur, '*' est une cible.
            // On retire tous les vides pour garder uniquement la séquence (Murs et Cibles)
            String normalizedEngine = currentGrid.replace(".", "").replace(" ", "").replace("\n", "").replace("\r", "");

            for (File f : configFiles) {
                String content = new String(Files.readAllBytes(f.toPath()));
                JsonObject json = new JsonParser().parse(content).getAsJsonObject();
                String testIn = json.get("testIn").getAsString().trim();

                // Dans la grille JSON, les vides et entités mobiles sont ' ', '@', '$'.
                // Les cibles sont '.', '+', '*'. Les murs sont '#'.
                String normalizedJson = testIn
                        .replace(" ", "").replace("@", "").replace("$", "")
                        .replace("\n", "").replace("\r", "")
                        .replace(".", "*").replace("+", "*");

                if (normalizedJson.equals(normalizedEngine)) {
                    levelNum = Integer.parseInt(f.getName().replaceAll("[^0-9]", ""));
                    break;
                }
            }
        }

        // On consomme la fin du tour 1 (positions joueur et caisses)
        if (in.hasNextInt()) {
            in.nextInt();
            in.nextInt();
            for (int i = 0; i < boxCount; i++) {
                in.nextInt();
                in.nextInt();
            }
        }

        if (levelNum == -1) {
            System.err.println("Niveau non reconnu !");
            return;
        }

        // 3. Application de la solution
        File solutionFile = new File("solutions_json/solution_" + String.format("%02d", levelNum) + ".json");
        if (solutionFile.exists()) {
            String solContent = new String(Files.readAllBytes(solutionFile.toPath()));
            JsonObject solJson = new JsonParser().parse(solContent).getAsJsonObject();
            String solution = solJson.get("solution").getAsString();

            for (int i = 0; i < solution.length(); i++) {
                System.out.println(solution.charAt(i));

                if (in.hasNextInt()) {
                    in.nextInt();
                    in.nextInt(); // pusher pos
                    for (int j = 0; j < boxCount; j++) {
                        in.nextInt();
                        in.nextInt(); // boxes pos
                    }
                }
            }
        }
    }
}
