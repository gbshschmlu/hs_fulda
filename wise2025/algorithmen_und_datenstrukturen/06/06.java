import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.Scanner;

public class Uebungsblatt06 {

    // === Aufgabe 6.1: Nullen und Neunen ===
    // Strategie: Breitensuche (BFS) mit einer Queue.
    // Wir generieren Zahlen als Strings: "9", "90", "99", "900"...
    public static void findSmallestMultiple(int n) {
        if (n <= 0) {
            System.out.println("Bitte eine positive Zahl eingeben.");
            return;
        }

        Queue<String> queue = new LinkedList<>();
        queue.add("9");

        System.out.println("Suche Vielfaches für N=" + n + "...");

        // Sicherheitsabbruch, falls N sehr groß ist (Long Overflow Gefahr)
        int iterations = 0;

        while (!queue.isEmpty()) {
            String currentS = queue.remove();

            try {
                long val = Long.parseLong(currentS);

                // Check: Ist es ein Vielfaches?
                if (val % n == 0) {
                    System.out.println(
                        "Gefunden: " +
                            val +
                            " (Berechnung: " +
                            val +
                            " / " +
                            n +
                            " = " +
                            (val / n) +
                            ")"
                    );
                    return;
                }

                // Generiere nächste Zahlen: Erst die mit 0, dann die mit 9
                // (damit wir die *kleinste* Zahl zuerst finden -> BFS)
                queue.add(currentS + "0");
                queue.add(currentS + "9");
            } catch (NumberFormatException e) {
                System.out.println("Zahl zu groß für long! Abbruch bei " + currentS);
                return;
            }

            if (++iterations > 100_000) {
                System.out.println("Suche abgebrochen (zu viele Iterationen).");
                return;
            }
        }
    }

    // === Aufgabe 6.2: Fibonacci mit Queue ===
    // f(n) = f(n-1) + f(n-2)
    // Queue speichert immer die letzten zwei Werte [f(i-2), f(i-1)]
    public static void fibonacciWithQueue(int n) {
        if (n <= 0) {
            System.out.println("n muss > 0 sein.");
            return;
        }
        if (n == 1 || n == 2) {
            System.out.println("f(" + n + ") = 1");
            return;
        }

        Queue<Long> q = new LinkedList<>();
        // Startwerte f(1) und f(2)
        q.add(1L);
        q.add(1L);

        // Wir berechnen ab f(3) bis f(n)
        for (int i = 3; i <= n; i++) {
            long f_minus_2 = q.remove(); // Das älteste Element entfernen
            long f_minus_1 = q.peek(); // Das verbleibende Element ansehen (ist jetzt vorne)

            long f_current = f_minus_1 + f_minus_2;

            // Queue wieder auffüllen für nächsten Schritt: [f(i-1), f(current)]
            q.add(f_current);
        }

        // Am Ende ist das neueste Element hinten in der Queue (oder peek() beim nächsten Schritt)
        // Die Queue enthält [f(n-1), f(n)]. Wir wollen das letzte hinzugefügte.
        // Da wir nicht direkt ans Ende kommen bei Queue, entfernen wir eins.
        q.remove();
        System.out.println("f(" + n + ") = " + q.peek());
    }

    // === Aufgabe 6.3: Offenes Hashing (Verkettung) Simulation ===
    public static void simluateOpenHashing() {
        System.out.println(
            "\n--- Simulation Aufgabe 6.3 (Offenes Hashing / Chaining) ---"
        );
        String[] inputs = {
            "Patrizia",
            "Sebastian",
            "Maike",
            "Lukas",
            "Nele",
            "Sarah",
            "Matthias",
            "Manuel",
        };

        // Array von Listen (Chaining)
        ArrayList<String>[] table = new ArrayList[8];
        for (int i = 0; i < 8; i++) table[i] = new ArrayList<>();

        for (String s : inputs) {
            int hash = hashFunctionStrings(s);
            System.out.printf(
                "Insert: %-10s | Vokale: %d, Len: %d | Hash: (V+L)%%8 = %d\n",
                s,
                countVowels(s),
                s.length(),
                hash
            );
            table[hash].add(s);
        }

        System.out.println("\nErgebnistabelle:");
        for (int i = 0; i < 8; i++) {
            System.out.println("Index " + i + ": " + table[i]);
        }
    }

    private static int hashFunctionStrings(String s) {
        return (countVowels(s) + s.length()) % 8;
    }

    private static int countVowels(String s) {
        int count = 0;
        String lower = s.toLowerCase();
        for (char c : lower.toCharArray()) {
            if ("aeiou".indexOf(c) != -1) count++;
        }
        return count;
    }

    // === Aufgabe 6.4: Geschlossenes Hashing (Sondieren) Simulation ===
    public static void simulateClosedHashing() {
        System.out.println(
            "\n--- Simulation Aufgabe 6.4 (Geschlossenes Hashing / Probing) ---"
        );
        int[] keys = { 1001, 1542, 429, 1320, 17, 900, 417, 2302, 1920 };
        int N = 10;

        // 1. Lineares Sondieren
        System.out.println("\n>> Lineares Sondieren:");
        Integer[] tableLin = new Integer[N];
        for (int k : keys) {
            insertLinear(tableLin, k, N);
        }
        printTable(tableLin);

        // 2. Quadratisches Sondieren
        System.out.println("\n>> Quadratisches Sondieren:");
        Integer[] tableQuad = new Integer[N];
        for (int k : keys) {
            insertQuadratic(tableQuad, k, N);
        }
        printTable(tableQuad);
    }

    private static int hashFuncInt(int x) {
        return (x / 100) % 10;
    }

    private static void insertLinear(Integer[] table, int key, int N) {
        int home = hashFuncInt(key);
        int idx = home;
        int i = 0;

        System.out.printf("Insert %d (h=%d): ", key, home);

        while (table[idx] != null && i < N) {
            System.out.print("Kollision bei " + idx + " -> ");
            i++;
            idx = (home + i) % N; // Linear: +1, +2, +3...
        }

        if (table[idx] == null) {
            table[idx] = key;
            System.out.println("Eingefügt bei " + idx);
        } else {
            System.out.println("Tabelle voll / Fehler!");
        }
    }

    private static void insertQuadratic(Integer[] table, int key, int N) {
        int home = hashFuncInt(key);
        int idx = home;
        int i = 0;

        System.out.printf("Insert %d (h=%d): ", key, home);

        // Abbruchbedingung i < N ist hier vereinfacht, eigentlich komplexer bei quad. Sondieren
        while (table[idx] != null && i < N * 2) {
            System.out.print("Kollision bei " + idx + " -> ");
            i++;
            // Quadratisch: (h + i^2) % N
            // Vorsicht: Manchmal auch (-1)^i * ceil(i/2)^2 (alternierend).
            // Standard meist: + i*i
            idx = (home + (i * i)) % N;
        }

        if (table[idx] == null) {
            table[idx] = key;
            System.out.println("Eingefügt bei " + idx);
        } else {
            System.out.println("Konnte nicht eingefügt werden (Zyklus/Voll)!");
        }
    }

    private static void printTable(Integer[] table) {
        System.out.print("Tabelle: [");
        for (int i = 0; i < table.length; i++) {
            System.out.print(i + ":" + (table[i] == null ? "_" : table[i]));
            if (i < table.length - 1) System.out.print(", ");
        }
        System.out.println("]");
    }

    // === Main ===
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("=== Übungsblatt 6 ===");
        System.out.println("1. Aufgabe 6.1 (Nullen und Neunen)");
        System.out.println("2. Aufgabe 6.2 (Fibonacci)");
        System.out.println("3. Aufgabe 6.3 (Offenes Hashing Simulation)");
        System.out.println("4. Aufgabe 6.4 (Geschlossenes Hashing Simulation)");
        System.out.print("Wahl: ");

        if (scanner.hasNextInt()) {
            int choice = scanner.nextInt();
            switch (choice) {
                case 1:
                    System.out.print("Geben Sie N ein: ");
                    int n = scanner.nextInt();
                    findSmallestMultiple(n);
                    break;
                case 2:
                    System.out.print("Geben Sie n ein: ");
                    int fibN = scanner.nextInt();
                    fibonacciWithQueue(fibN);
                    break;
                case 3:
                    simluateOpenHashing();
                    break;
                case 4:
                    simulateClosedHashing();
                    break;
                default:
                    System.out.println("Ungültige Wahl.");
            }
        }
        scanner.close();
    }
}
