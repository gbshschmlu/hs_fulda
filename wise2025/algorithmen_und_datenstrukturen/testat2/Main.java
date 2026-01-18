import java.util.Random;

/**
 * Wrapper-Klasse für Integer, die das Comparable-Interface implementiert.
 * Ermöglicht die Verwendung von int-Werten im generischen RBTree.
 */
class IntComparable implements Comparable<IntComparable> {
    private final int value;

    public IntComparable(int value) {
        this.value = value;
    }

    public int getValue() {
        return value;
    }

    @Override
    public int compareTo(IntComparable other) {
        return Integer.compare(this.value, other.value);
    }

    @Override
    public String toString() {
        return String.valueOf(value);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        IntComparable that = (IntComparable) obj;
        return value == that.value;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(value);
    }
}

/**
 * Testprogramm für die RBTree-Implementierung.
 * Generiert 15 zufällige Integer-Zahlen und fügt sie in den Baum ein.
 * Nach jedem Einfügen wird der aktuelle Baumzustand als DOT-Datei gespeichert.
 */
public class Main {

    // Konfiguration
    private static final int NUM_INSERTIONS = 15;
    private static final int RANDOM_BOUND = 100;  // Zufallszahlen von 0 bis 99
    private static final String OUTPUT_DIR = "dot_output";

    public static void main(String[] args) {
        // Output-Verzeichnis erstellen
        java.io.File dir = new java.io.File(OUTPUT_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        RBTree<IntComparable> tree = new RBTree<>();
        Random random = new Random();

        // Optional: Seed setzen für reproduzierbare Ergebnisse
        // random.setSeed(42);

        System.out.println("=== Rot-Schwarz-Baum Test ===\n");
        System.out.println("Füge " + NUM_INSERTIONS + " zufällige Zahlen ein:\n");

        int[] insertedValues = new int[NUM_INSERTIONS];

        for (int i = 0; i < NUM_INSERTIONS; i++) {
            int value = random.nextInt(RANDOM_BOUND);
            insertedValues[i] = value;

            System.out.printf("Schritt %2d: Füge %2d ein%n", i + 1, value);

            tree.insert(new IntComparable(value));

            // DOT-Datei nach jedem Insert erstellen
            String filename = String.format("%s/tree_%02d.dot", OUTPUT_DIR, i + 1);
            tree.printDOT(filename);
        }

        System.out.println("\n=== Zusammenfassung ===");
        System.out.println("Eingefügte Werte: ");
        System.out.print("  ");
        for (int i = 0; i < insertedValues.length; i++) {
            System.out.print(insertedValues[i]);
            if (i < insertedValues.length - 1) {
                System.out.print(", ");
            }
        }
        System.out.println("\n");
        System.out.println("Anzahl Knoten im Baum: " + tree.getSize());
        System.out.println("\nDOT-Dateien wurden in '" + OUTPUT_DIR + "/' gespeichert.");
    }
}
