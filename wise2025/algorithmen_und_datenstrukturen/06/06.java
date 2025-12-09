import java.util.LinkedList;
import java.util.Queue;
import java.util.Scanner;

public class Uebungsblatt06 {

    // Aufgabe 6.1
    public static void findSmallestMultiple(int n) {
        if (n <= 0) {
            System.out.println("Bitte eine positive Zahl eingeben.");
            return;
        }

        Queue<String> queue = new LinkedList<>();
        queue.add("9");

        System.out.println("Suche Vielfaches für N=" + n + "...");

        // Long Overflow Gefahr
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

    // Aufgabe 6.2
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

        // Berechnen ab f(3) bis f(n)
        for (int i = 3; i <= n; i++) {
            long f_minus_2 = q.remove(); // Das älteste Element entfernen
            long f_minus_1 = q.peek(); // Das verbleibende Element ansehen (vorne)

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

    // Main
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("=== Übungsblatt 6 ===");
        System.out.println("1. Aufgabe 6.1 (Nullen und Neunen)");
        System.out.println("2. Aufgabe 6.2 (Fibonacci)");
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
                default:
                    System.out.println("Ungültige Wahl.");
            }
        }
        scanner.close();
    }
}
