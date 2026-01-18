import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Rot-Schwarz-Baum Implementierung mit generischen Comparable-Objekten.
 *
 * Rot-Schwarz-Eigenschaften:
 * 1. Jeder Knoten ist entweder rot oder schwarz
 * 2. Die Wurzel ist schwarz
 * 3. Alle Blätter (NIL) sind schwarz
 * 4. Rote Knoten haben nur schwarze Kinder
 * 5. Jeder Pfad von einem Knoten zu seinen Blättern enthält gleich viele schwarze Knoten
 *
 * @param <T> Typ der zu speichernden Elemente (muss Comparable implementieren)
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
     * Fügt einen neuen Schlüssel in den Rot-Schwarz-Baum ein.
     * Orientiert sich an der insertNode-Methode aus der Vorlesung (Folie 309).
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
     * Repariert Rot-Schwarz-Verletzungen nach dem Einfügen.
     *
     * Es gibt drei Hauptfälle (jeweils gespiegelt für links/rechts):
     * - Fall 1: Onkel ist rot
     * - Fall 2: Onkel ist schwarz, Knoten ist inneres Kind
     * - Fall 3: Onkel ist schwarz, Knoten ist äußeres Kind
     *
     * @param node Der neu eingefügte Knoten
     */
    private void insertFixup(Node node) {
        // Solange der Parent rot ist, haben wir eine Verletzung (rot-rot)
        while (node.parent != null && node.parent.color == RED) {

            if (node.parent == node.parent.parent.left) {
                // Parent ist linkes Kind des Großelternknotens
                Node uncle = node.parent.parent.right;

                if (getColor(uncle) == RED) {
                    // ==========================================
                    // FALL 1: Onkel ist rot
                    // ==========================================
                    // Lösung: Umfärben von Parent, Onkel und Großeltern
                    // Dann weiter oben prüfen
                    node.parent.color = BLACK;
                    uncle.color = BLACK;
                    node.parent.parent.color = RED;
                    node = node.parent.parent;
                } else {
                    if (node == node.parent.right) {
                        // ==========================================
                        // FALL 2: Onkel ist schwarz, Knoten ist rechtes Kind (inneres Kind)
                        // ==========================================
                        // Lösung: Linksrotation um Parent, dann Fall 3
                        node = node.parent;
                        rotateLeft(node);
                    }
                    // ==========================================
                    // FALL 3: Onkel ist schwarz, Knoten ist linkes Kind (äußeres Kind)
                    // ==========================================
                    // Lösung: Umfärben und Rechtsrotation um Großeltern
                    node.parent.color = BLACK;
                    node.parent.parent.color = RED;
                    rotateRight(node.parent.parent);
                }
            } else {
                // Parent ist rechtes Kind des Großelternknotens (gespiegelte Fälle)
                Node uncle = node.parent.parent.left;

                if (getColor(uncle) == RED) {
                    // ==========================================
                    // FALL 1 (gespiegelt): Onkel ist rot
                    // ==========================================
                    node.parent.color = BLACK;
                    uncle.color = BLACK;
                    node.parent.parent.color = RED;
                    node = node.parent.parent;
                } else {
                    if (node == node.parent.left) {
                        // ==========================================
                        // FALL 2 (gespiegelt): Onkel ist schwarz, Knoten ist linkes Kind
                        // ==========================================
                        node = node.parent;
                        rotateRight(node);
                    }
                    // ==========================================
                    // FALL 3 (gespiegelt): Onkel ist schwarz, Knoten ist rechtes Kind
                    // ==========================================
                    node.parent.color = BLACK;
                    node.parent.parent.color = RED;
                    rotateLeft(node.parent.parent);
                }
            }
        }

        // Wurzel muss immer schwarz sein (Eigenschaft 2)
        root.color = BLACK;
    }

    /**
     * Gibt die Farbe eines Knotens zurück.
     * NIL-Knoten (null) gelten als schwarz.
     */
    private boolean getColor(Node node) {
        if (node == null) {
            return BLACK;
        }
        return node.color;
    }

    /**
     * Führt eine Linksrotation um den gegebenen Knoten durch.
     *
     *     x                y
     *    / \              / \
     *   a   y    -->     x   c
     *      / \          / \
     *     b   c        a   b
     */
    private void rotateLeft(Node x) {
        Node y = x.right;

        // b wird rechtes Kind von x
        x.right = y.left;
        if (y.left != null) {
            y.left.parent = x;
        }

        // y übernimmt die Position von x
        y.parent = x.parent;
        if (x.parent == null) {
            root = y;
        } else if (x == x.parent.left) {
            x.parent.left = y;
        } else {
            x.parent.right = y;
        }

        // x wird linkes Kind von y
        y.left = x;
        x.parent = y;
    }

    /**
     * Führt eine Rechtsrotation um den gegebenen Knoten durch.
     *
     *       y              x
     *      / \            / \
     *     x   c   -->    a   y
     *    / \                / \
     *   a   b              b   c
     */
    private void rotateRight(Node y) {
        Node x = y.left;

        // b wird linkes Kind von y
        y.left = x.right;
        if (x.right != null) {
            x.right.parent = y;
        }

        // x übernimmt die Position von y
        x.parent = y.parent;
        if (y.parent == null) {
            root = x;
        } else if (y == y.parent.left) {
            y.parent.left = x;
        } else {
            y.parent.right = x;
        }

        // y wird rechtes Kind von x
        x.right = y;
        y.parent = x;
    }

    /**
     * Gibt die aktuelle Baumstruktur im DOT-Format in eine Datei aus.
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
     * Hilfsmethode zum rekursiven Sammeln der Knoten und Kanten für die DOT-Ausgab mit eindeutiger ID.
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
     * Gibt die Anzahl der Knoten im Baum zurück.
     */
    public int getSize() {
        return size;
    }

    /**
     * Prüft, ob der Baum leer ist.
     */
    public boolean isEmpty() {
        return root == null;
    }
}
