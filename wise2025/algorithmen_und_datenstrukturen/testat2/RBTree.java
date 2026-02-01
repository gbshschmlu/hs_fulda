import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Rot-Schwarz-Baum Implementierung mit generischen Comparable-Objekten
 *
 * Rot-Schwarz-Eigenschaften:
 * 1. Jeder Knoten ist entweder rot oder schwarz
 * 2. Die Wurzel ist schwarz
 * 3. Alle NIL-Blätter sind schwarz
 * 4. Ein roter Knoten darf keine roten Kinder haben
 * 5. Alle Pfade von einem Knoten zu den Blättern enthalten gleich viele schwarze Knoten
 *
 * @param <T> Typ der zu speichernden Elemente
 */
public class RBTree<T extends Comparable<T>> {

    // Farb-Konstanten
    private static final boolean RED = true;
    private static final boolean BLACK = false;

    /**
     * Innere Klasse für Baumknoten
     */
    private class Node {
        T key;
        Node left, right, parent;
        boolean color;

        Node(T key) {
            this.key = key;
            this.color = RED; // Neue Knoten sind initial rot
            this.left = null;
            this.right = null;
            this.parent = null;
        }
    }

    private Node root;
    private int size;

    public RBTree() {
        root = null;
        size = 0;
    }

    /**
     * Fügt einen neuen Schlüssel in den Rot-Schwarz-Baum ein
     *
     * @param key Der einzufügende Schlüssel
     */
    public void insert(T key) {
        Node newNode = new Node(key);

        // Schritt 1: Normales BST-Einfügen
        if (root == null) {
            root = newNode;
        } else {
            Node current = root;
            Node parent = null;

            // Finde die richtige Einfügeposition
            while (current != null) {
                parent = current;
                int cmp = key.compareTo(current.key);
                if (cmp < 0) {
                    current = current.left;
                } else {
                    current = current.right;
                }
            }

            // Setze den Parent-Pointer und füge als Kind ein
            newNode.parent = parent;
            int cmp = key.compareTo(parent.key);
            if (cmp < 0) {
                parent.left = newNode;
            } else {
                parent.right = newNode;
            }
        }

        size++;

        // Schritt 2: Repariere mögliche Rot-Schwarz-Verletzungen
        insertFixup(newNode);
    }

    /**
     * Repariert Rot-Schwarz-Verletzungen nach dem Einfügen
     *
     * - Fall 3: Onkel ist rot
     * - Fall 4: Onkel ist schwarz, Knoten ist innerer Enkel
     * - Fall 5: Onkel ist schwarz, Knoten ist äußerer Enkel
     *
     * @param node Der neu eingefügte Knoten
     */
    private void insertFixup(Node node) {
        // Solange der Vater rot ist, haben wir eine Verletzung (rot-rot)
        while (node.parent != null && node.parent.color == RED) {

            if (node.parent == node.parent.parent.left) {
                // Vater ist linkes Kind des Großvaterknotens
                Node uncle = node.parent.parent.right;

                if (getColor(uncle) == RED) {
                    // ==========================================
                    // Fall 3: Onkel ist rot
                    // ==========================================
                    // Lösung: Umfärben von Vater, Onkel und Großvater
                    // Dann weiter oben prüfen
                    node.parent.color = BLACK;
                    uncle.color = BLACK;
                    node.parent.parent.color = RED;
                    node = node.parent.parent;
                } else {
                    if (node == node.parent.right) {
                        // ==========================================
                        // Fall 4: Onkel ist schwarz, Knoten ist rechtes Kind (innerer Enkel)
                        // ==========================================
                        // Lösung: Linksrotation um Vater, dann Fall 5
                        node = node.parent;
                        rotateLeft(node);
                    }
                    // ==========================================
                    // Fall 5: Onkel ist schwarz, Knoten ist linkes Kind (äußerer Enkel)
                    // ==========================================
                    // Lösung: Umfärben und Rechtsrotation um Großvater
                    node.parent.color = BLACK;
                    node.parent.parent.color = RED;
                    rotateRight(node.parent.parent);
                }
            } else {
                // Vater ist rechtes Kind des Großvaterknotens (gespiegelte Fälle)
                Node uncle = node.parent.parent.left;

                if (getColor(uncle) == RED) {
                    // ==========================================
                    // Fall 3 (gespiegelt): Onkel ist rot
                    // ==========================================
                    node.parent.color = BLACK;
                    uncle.color = BLACK;
                    node.parent.parent.color = RED;
                    node = node.parent.parent;
                } else {
                    if (node == node.parent.left) {
                        // ==========================================
                        // Fall 4 (gespiegelt): Onkel ist schwarz, Knoten ist linkes Kind
                        // ==========================================
                        node = node.parent;
                        rotateRight(node);
                    }
                    // ==========================================
                    // Fall 5 (gespiegelt): Onkel ist schwarz, Knoten ist rechtes Kind
                    // ==========================================
                    node.parent.color = BLACK;
                    node.parent.parent.color = RED;
                    rotateLeft(node.parent.parent);
                }
            }
        }
        // ==========================================
        // Fall 1 und 2: Der Knoten ist die neue Wurzel
        // ==========================================
        // Wurzel muss immer schwarz sein
        root.color = BLACK;
    }

    /**
     * Gibt die Farbe eines Knotens zurück
     * NIL-Knoten (null) gelten als schwarz
     */
    private boolean getColor(Node node) {
        if (node == null) {
            return BLACK;
        }
        return node.color;
    }

    /**
     * Rechts-Rotation - Eigenschaften
     *
     * ‣ Der linke Sohn L wird zur neuen Wurzel
     * ‣ Die Wurzel wird zum rechten Kind
     * ‣ Der rechte Teilbaum LR wird zum linken Sohn von N nach der Rotation
     * ‣ LL und R behalten ihre relative Position bei
     *
     *       N              L
     *      / \            / \
     *     L   R   -->    LL  N
     *    / \                / \
     *   LL  LR             LR  R
     *
     */
    private void rotateRight(Node N) {
        Node L = N.left;

        // LR wird linkes Kind von N
        N.left = L.right;
        if (L.right != null) {
            L.right.parent = N;
        }

        // L übernimmt die Position von N
        L.parent = N.parent;
        if (N.parent == null) {
            root = L;
        } else if (N == N.parent.left) {
            N.parent.left = L;
        } else {
            N.parent.right = L;
        }

        // N wird rechtes Kind von L
        L.right = N;
        N.parent = L;
    }

    /**
     * Linksrotation
     *
     *     N                R
     *    / \              / \
     *   L   R    -->     N   RR
     *      / \          / \
     *    RL   RR       L   RL
     */
    private void rotateLeft(Node N) {
        Node R = N.right;

        // RL wird rechtes Kind von N
        N.right = R.left;
        if (R.left != null) {
            R.left.parent = N;
        }

        // R übernimmt die Position von N
        R.parent = N.parent;
        if (N.parent == null) {
            root = R;
        } else if (N == N.parent.left) {
            N.parent.left = R;
        } else {
            N.parent.right = R;
        }

        // N wird linkes Kind von R
        R.left = N;
        N.parent = R;
    }

    /**
     * Gibt die aktuelle Baumstruktur im DOT-Format in eine Datei aus
     *
     * @param filename Der Dateiname für die DOT-Ausgabe
     */
    public void printDOT(String filename) {
        StringBuilder sb = new StringBuilder();

        sb.append("// Red Black Tree\n");
        sb.append("digraph G {\n");
        sb.append("\tgraph [ratio=.48];\n");
        sb.append("\tnode [style=filled, color=black, shape=circle, width=.6\n");
        sb.append("\t\tfontname=Helvetica, fontweight=bold, fontcolor=white,\n");
        sb.append("\t\tfontsize=24, fixedsize=true];\n\n");

        if (root != null) {
            List<String> nodeDefinitions = new ArrayList<>();
            List<String> edges = new ArrayList<>();
            int[] nodeCounter = {0};
            int[] nilCounter = {0};

            collectNodes(root, nodeDefinitions, edges, nodeCounter, nilCounter);

            // Knoten-Definitionen ausgeben
            for (String nodeDef : nodeDefinitions) {
                sb.append("\t").append(nodeDef).append("\n");
            }
            sb.append("\n");

            // Kanten ausgeben
            for (String edge : edges) {
                sb.append("\t").append(edge).append(";\n");
            }
        }

        sb.append("}\n");

        try (FileWriter writer = new FileWriter(filename)) {
            writer.write(sb.toString());
        } catch (IOException e) {
            System.err.println("Fehler beim Schreiben der DOT-Datei: " + e.getMessage());
        }
    }

    /**
     * Hilfsmethode zum rekursiven Sammeln der Knoten und Kanten für die DOT-Ausgab mit eindeutiger ID
     */
    private String collectNodes(Node node, List<String> nodeDefinitions,
                                List<String> edges, int[] nodeCounter, int[] nilCounter) {
        if (node == null) {
            return null;
        }

        // Eindeutige ID für diesen Knoten
        String nodeId = "n" + (nodeCounter[0]++);
        String colorAttr = (node.color == RED) ? ", fillcolor=red" : "";

        // Knoten mit Label (Wert) und Farbe definieren
        nodeDefinitions.add(nodeId + " [label=\"" + node.key.toString() + "\"" + colorAttr + "];");

        // Linkes Kind
        if (node.left != null) {
            String leftId = collectNodes(node.left, nodeDefinitions, edges, nodeCounter, nilCounter);
            edges.add(nodeId + " -> " + leftId);
        } else {
            String nilId = "nil" + (nilCounter[0]++);
            nodeDefinitions.add(nilId + " [label=\"NIL\", shape=record, width=.4, height=.25, fontsize=16];");
            edges.add(nodeId + " -> " + nilId);
        }

        // Rechtes Kind
        if (node.right != null) {
            String rightId = collectNodes(node.right, nodeDefinitions, edges, nodeCounter, nilCounter);
            edges.add(nodeId + " -> " + rightId);
        } else {
            String nilId = "nil" + (nilCounter[0]++);
            nodeDefinitions.add(nilId + " [label=\"NIL\", shape=record, width=.4, height=.25, fontsize=16];");
            edges.add(nodeId + " -> " + nilId);
        }

        return nodeId;
    }

    /**
     * Gibt die Anzahl der Knoten im Baum zurück
     */
    public int getSize() {
        return size;
    }

    /**
     * Prüft, ob der Baum leer ist
     */
    public boolean isEmpty() {
        return root == null;
    }
}
