import java.util.ArrayDeque;
import java.util.Deque;

public class Uebungsblatt05 {

    // Implementierung einer Queue mit verketteter Liste -> 5.1

    // Ein einzelner Knoten für die verkettete Liste
    static class QueueNode<T> {

        T data;
        QueueNode<T> next;

        public QueueNode(T data) {
            this.data = data;
            this.next = null;
        }
    }

    // Die Queue-Klasse (Generisch, damit sie Strings oder Integers speichern kann)
    static class MyQueue<T> {

        private QueueNode<T> first; // Kopf der Schlange (Entnahme hier)
        private QueueNode<T> last; // Ende der Schlange (Einfügen hier)

        public MyQueue() {
            this.first = null;
            this.last = null;
        }

        public boolean isEmpty() {
            return first == null;
        }

        // Hinzufügen (hinten)
        public void enqueue(T item) {
            QueueNode<T> oldLast = last;
            last = new QueueNode<>(item);
            if (isEmpty()) {
                // Wenn Liste vorher leer war, ist das neue Element auch first
                first = last;
            } else {
                // Sonst hängen wir es an den alten letzten Knoten an
                if (oldLast != null) {
                    oldLast.next = last;
                }
            }
        }

        // Entfernen (vorne)
        public T dequeue() {
            if (isEmpty()) {
                throw new RuntimeException("Queue ist leer!");
            }
            T item = first.data;
            first = first.next;

            // Wenn die Queue jetzt leer ist, muss auch last null sein
            if (first == null) {
                last = null;
            }
            return item;
        }
    }

    // Algorithmus zur Überprüfung von Klammern -> 5.2
    public static boolean checkBrackets(String input) {
        // Wir nutzen Deque als Stack
        // Operationen: push() und pop()
        Deque<Character> stack = new ArrayDeque<>();

        for (char c : input.toCharArray()) {
            // 1. Öffnende Klammern auf den Stack
            if (c == '(' || c == '[' || c == '{') {
                stack.push(c);
            }
            // 2. Schließende Klammern prüfen
            else if (c == ')' || c == ']' || c == '}') {
                // Fehler: Schließende Klammer, aber Stack ist leer
                if (stack.isEmpty()) {
                    return false;
                }

                char lastOpen = stack.pop();

                // Prüfen, ob das Paar zusammenpasst
                if (!isMatchingPair(lastOpen, c)) {
                    return false;
                }
            }
            // Andere Zeichen (a, b, x...) werden ignoriert
        }

        // 3. Am Ende muss der Stack leer sein (alle Klammern geschlossen)
        return stack.isEmpty();
    }

    private static boolean isMatchingPair(char open, char close) {
        return (
            (open == '(' && close == ')') ||
            (open == '[' && close == ']') ||
            (open == '{' && close == '}')
        );
    }

    // Main
    public static void main(String[] args) {
        System.out.println("-- 5.1 --");

        MyQueue<String> stringQueue = new MyQueue<>();

        // "Use-Case zur Ausgabe von Strings reproduzieren"
        String[] words = { "Dies", "ist", "ein", "Test", "für", "die", "Queue" };

        System.out.println("Enqueueing:");
        for (String w : words) {
            System.out.print(w + " ");
            stringQueue.enqueue(w);
        }
        System.out.println("\n\nDequeueing:");

        while (!stringQueue.isEmpty()) {
            System.out.print(stringQueue.dequeue() + " ");
        }
        System.out.println("\n");

        System.out.println("-- 5.2 --");

        // Tests PDF
        String test1 = "{x[(a)b]}";
        String test2 = "{a(b)x[d]"; // !

        // Eigene Tests
        String test3 = "(a[b]c)";
        String test4 = "(a[b)c]"; // !
        String test5 = "((()))";

        testBracket(test1);
        testBracket(test2);
        testBracket(test3);
        testBracket(test4);
        testBracket(test5);
    }

    private static void testBracket(String s) {
        boolean result = checkBrackets(s);
        System.out.printf("String: %-15s -> %s\n", s, (result ? "Gültig" : "Ungültig"));
    }
}
