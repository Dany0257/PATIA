package sokoban;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import com.google.gson.*;

/**
 * Java translation of the Python PDDL Generator.
 * Consumes JSON levels from 'config' and outputs PDDL to 'generated_pddl'.
 */
public class GenPDDL {

    private static final String JSON_DIR = "config";
    private static final String PDDL_OUTPUT_DIR = "generated_pddl";

    private static String posName(int row, int col) {
        return String.format("p%d_%d", row + 1, col + 1);
    }

    private static boolean isWall(String[] grid, int r, int c, int numRows, int numCols) {
        if (r < 0 || r >= numRows || c < 0 || c >= numCols) {
            return true;
        }
        return grid[r].charAt(c) == '#';
    }

    public static void convertTestInToPddl(File jsonPath, String pddlPath, int levelNum) throws IOException {
        String content = new String(Files.readAllBytes(jsonPath.toPath()));
        JsonObject data = new JsonParser().parse(content).getAsJsonObject();
        String testIn = data.get("testIn").getAsString();

        String[] gridLines = testIn.trim().split("\n");
        int numRows = gridLines.length;
        int numCols = 0;
        for (String line : gridLines)
            numCols = Math.max(numCols, line.length());

        String[] grid = new String[numRows];
        for (int i = 0; i < numRows; i++) {
            grid[i] = String.format("%-" + numCols + "s", gridLines[i]);
        }

        Set<String> objects = new TreeSet<>();
        List<String> init = new ArrayList<>();
        List<String> goals = new ArrayList<>();

        for (int r = 0; r < numRows; r++) {
            for (int c = 0; c < numCols; c++) {
                char cell = grid[r].charAt(c);
                String name = posName(r, c);

                if (" @+$*.".indexOf(cell) != -1) {
                    objects.add(name);
                    if (cell == ' ') {
                        init.add("(isEmpty " + name + ")");
                    } else if (cell == '@') {
                        init.add("(playerIsAt " + name + ")");
                    } else if (cell == '.') {
                        init.add("(isEmpty " + name + ")");
                        goals.add("(boxIsAt " + name + ")");
                    } else if (cell == '$') {
                        init.add("(boxIsAt " + name + ")");
                    } else if (cell == '+') {
                        init.add("(playerIsAt " + name + ")");
                        goals.add("(boxIsAt " + name + ")");
                    } else if (cell == '*') {
                        init.add("(boxIsAt " + name + ")");
                        goals.add("(boxIsAt " + name + ")");
                    }
                }
            }
        }

        // Adjacency
        int[][] directions = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }; // left, right, up, down
        String[] dNames = { "Left", "Right", "Up", "Down" };

        for (int r = 0; r < numRows; r++) {
            for (int c = 0; c < numCols; c++) {
                String fromName = posName(r, c);
                for (int i = 0; i < 4; i++) {
                    int nr = r + directions[i][0];
                    int nc = c + directions[i][1];
                    if (nr >= 0 && nr < numRows && nc >= 0 && nc < numCols) {
                        String toName = posName(nr, nc);
                        if (grid[r].charAt(c) != '#' && grid[nr].charAt(nc) != '#') {
                            init.add("(is" + dNames[i] + " " + fromName + " " + toName + ")");
                        }
                    }
                }
            }
        }

        // Deadlock Detection
        for (int r = 0; r < numRows; r++) {
            for (int c = 0; c < numCols; c++) {
                char cell = grid[r].charAt(c);
                String name = posName(r, c);
                if (" @$".indexOf(cell) != -1 && ".+*".indexOf(cell) == -1) {
                    boolean north = isWall(grid, r - 1, c, numRows, numCols);
                    boolean south = isWall(grid, r + 1, c, numRows, numCols);
                    boolean left = isWall(grid, r, c - 1, numRows, numCols);
                    boolean right = isWall(grid, r, c + 1, numRows, numCols);
                    if ((north && left) || (north && right) || (south && left) || (south && right)) {
                        init.add("(deadlock " + name + ")");
                    }
                }
            }
        }

        try (PrintWriter pw = new PrintWriter(new FileWriter(pddlPath))) {
            pw.println("; testIn for level " + levelNum);
            pw.println("(define (problem Sokoban" + levelNum + ")");
            pw.println("  (:domain Sokoban)");
            pw.print("  (:objects\n    ");
            for (String obj : objects)
                pw.print(obj + " ");
            pw.println("- place\n  )");
            pw.println("  (:init");
            Collections.sort(init);
            for (String i : init)
                pw.println("    " + i);
            pw.println("  )");
            pw.println("  (:goal (and");
            Collections.sort(goals);
            for (String g : goals)
                pw.println("    " + g);
            pw.println("  ))");
            pw.println(")");
        }
        System.out.println(" PDDL généré : " + pddlPath);
    }

    public static void main(String[] args) throws IOException {
        File jsonDir = new File(JSON_DIR);
        File outputDir = new File(PDDL_OUTPUT_DIR);
        if (!outputDir.exists())
            outputDir.mkdirs();

        File[] files = jsonDir.listFiles((dir, name) -> name.startsWith("test") && name.endsWith(".json"));
        if (files != null) {
            Arrays.sort(files, Comparator.comparing(File::getName));
            for (File file : files) {
                String name = file.getName();
                int levelNum = Integer.parseInt(name.replaceAll("[^0-9]", ""));
                String pddlPath = Paths.get(PDDL_OUTPUT_DIR, String.format("problem_%02d.pddl", levelNum)).toString();
                convertTestInToPddl(file, pddlPath, levelNum);
            }
        }
        System.out.println(" Conversion terminée pour tous les fichiers.");
    }
}
