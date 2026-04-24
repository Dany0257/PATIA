package sokoban;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;
import com.google.gson.*;

/**
 * Java translation of the plan-to-json conversion script.
 * Reads 'plans/plan_XX.txt' and outputs 'solutions_json/solution_XX.json'.
 */
public class GenJson {

    private static final String PLANS_DIR = "plans";
    private static final String SOLUTIONS_DIR = "solutions_json";

    private static final Map<String, String> DIR_MAP = new HashMap<>();
    static {
        DIR_MAP.put("down", "D");
        DIR_MAP.put("up", "U");
        DIR_MAP.put("left", "L");
        DIR_MAP.put("right", "R");
    }

    public static void convertPlanToJson(File planPath, String level) throws IOException {
        List<String> moves = new ArrayList<>();

        // Regex pour capturer la direction après "push-" ou "move-"
        Pattern pattern = Pattern.compile("(?:push|move)-(down|up|left|right)", Pattern.CASE_INSENSITIVE);

        try (BufferedReader br = new BufferedReader(new FileReader(planPath))) {
            String line;
            while ((line = br.readLine()) != null) {
                Matcher matcher = pattern.matcher(line);
                if (matcher.find()) {
                    String directionWord = matcher.group(1).toLowerCase();
                    String letter = DIR_MAP.get(directionWord);
                    if (letter != null) {
                        moves.add(letter);
                    }
                }
            }
        }

        JsonObject solutionData = new JsonObject();
        solutionData.addProperty("level", Integer.parseInt(level));

        StringBuilder sb = new StringBuilder();
        for (String m : moves)
            sb.append(m);
        solutionData.addProperty("solution", sb.toString());

        File outputFile = new File(SOLUTIONS_DIR + "/solution_" + level + ".json");
        try (PrintWriter pw = new PrintWriter(new FileWriter(outputFile))) {
            Gson gson = new GsonBuilder().setPrettyPrinting().create();
            pw.println(gson.toJson(solutionData));
        }

        System.out.println(" Solution enregistrée : " + outputFile.getPath() + " (" + sb.length() + " mouvements)");
    }

    public static void main(String[] args) throws IOException {
        File plansDir = new File(PLANS_DIR);
        File solutionsDir = new File(SOLUTIONS_DIR);
        if (!solutionsDir.exists())
            solutionsDir.mkdirs();

        File[] files = plansDir.listFiles((dir, name) -> name.startsWith("plan_") && name.endsWith(".txt"));
        if (files != null) {
            Arrays.sort(files, Comparator.comparing(File::getName));
            for (File file : files) {
                String name = file.getName();
                String level = name.replace("plan_", "").replace(".txt", "");
                convertPlanToJson(file, level);
            }
        }
        System.out.println(" Tous les plans ont été convertis en JSON.");
    }
}
