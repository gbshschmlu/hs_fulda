public class Uebungsblatt07 {

    static class Node {

        int key;
        Node left;
        Node right;

        public Node(int item) {
            key = item;
            left = right = null;
        }
    }

    static class BinarySearchTree {

        Node root;

        // Einfügen (Rekursiv)
        void insert(int key) {
            root = insertRec(root, key);
        }

        Node insertRec(Node root, int key) {
            if (root == null) {
                root = new Node(key);
                return root;
            }
            if (key < root.key) root.left = insertRec(root.left, key);
            else if (key > root.key) root.right = insertRec(root.right, key);
            return root;
        }

        // Aufgabe 7.1
        // V-L-R
        void printPreOrder(Node node) {
            if (node != null) {
                System.out.print(node.key + " ");
                printPreOrder(node.left);
                printPreOrder(node.right);
            }
        }

        // L-R-V
        void printPostOrder(Node node) {
            if (node != null) {
                printPostOrder(node.left);
                printPostOrder(node.right);
                System.out.print(node.key + " ");
            }
        }

        // L-V-R
        void printInOrder(Node node) {
            if (node != null) {
                printInOrder(node.left);
                System.out.print(node.key + " ");
                printInOrder(node.right);
            }
        }

        // Aufgabe 7.2: Finde kleinsten Schlüssel >= k
        public Integer findMinKeyNotSmallerThan(int k) {
            Node current = root;
            Integer bestCandidate = null;

            while (current != null) {
                if (current.key == k) {
                    // Exakter Treffer: Kleiner geht es nicht für ">= k"
                    return current.key;
                } else if (current.key > k) {
                    // Der aktuelle Knoten ist größer als k.
                    // Er ist ein Kandidat für das Ergebnis.
                    // Aber vielleicht gibt es links noch einen kleineren, der auch >= k ist.
                    bestCandidate = current.key;
                    current = current.left;
                } else {
                    // Der aktuelle Knoten ist kleiner als k.
                    // Er kommt nicht in Frage. Alles links von ihm auch nicht.
                    // Wir müssen rechts suchen, um größere Werte zu finden.
                    current = current.right;
                }
            }
            return bestCandidate;
        }
    }

    public static void main(String[] args) {
        BinarySearchTree tree = new BinarySearchTree();

        // 1. Aufbau des Baums aus Aufgabe 7.1
        int[] input = { 30, 40, 24, 58, 48, 26, 11, 13 };
        System.out.println("Einfügen: 30, 40, 24, 58, 48, 26, 11, 13");
        for (int val : input) {
            tree.insert(val);
        }

        System.out.println("\n=== Aufgabe 7.1: Traversierungen ===");

        System.out.print("Pre-Order:  ");
        tree.printPreOrder(tree.root);
        System.out.println();

        System.out.print("Post-Order: ");
        tree.printPostOrder(tree.root);
        System.out.println();

        System.out.print("In-Order:   ");
        tree.printInOrder(tree.root);
        System.out.println("\n(Beobachtung: In-Order ist sortiert!)");

        System.out.println("\n=== Aufgabe 7.2: Minimaler Schlüssel >= k ===");

        // Testfälle
        int[] testCases = {
            25, // Erwartet: 26 (26 ist kleinste Zahl > 25 im Baum)
            11, // Erwartet: 11 (Exakter Treffer)
            50, // Erwartet: 58 (58 ist kleinste Zahl > 50)
            10, // Erwartet: 11 (Alles im Baum ist größer)
            60, // Erwartet: null (Nichts im Baum ist >= 60)
        };

        for (int k : testCases) {
            Integer result = tree.findMinKeyNotSmallerThan(k);
            System.out.printf("Suche k=%d \t-> Gefunden: %s\n", k, result);
        }
    }
}
