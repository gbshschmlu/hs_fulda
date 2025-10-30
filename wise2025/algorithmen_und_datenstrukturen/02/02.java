public class Main {

    // Aufgabe 2.3: Insertion Sort
    public static void insertionSort(int[] arr) {
        for (int i = 1; i < arr.length; i++) {
            int current = arr[i];
            int j = i - 1;

            // Verschiebe Elemente nach rechts, bis die richtige Position für 'current' gefunden ist.
            while (j >= 0 && arr[j] > current) {
                arr[j + 1] = arr[j];
                j--;
            }
            arr[j + 1] = current;
        }
    }

    public static void main(String[] args) {
        System.out.println("=== Aufgabe 2.3: Laufzeitmessungen INSERTION SORT ===\n");

        int[] sortSizes = { 1000, 2000, 5000, 10000 };

        for (int size : sortSizes) {
            // Worst Case: Absteigend sortiertes Array
            int[] arrWorst = new int[size];
            for (int i = 0; i < size; i++) {
                arrWorst[i] = size - i;
            }

            long start = System.nanoTime();
            insertionSort(arrWorst);
            long end = System.nanoTime();
            System.out.printf(
                    "Insertion Sort (n=%d, worst case): %.3f ms\n",
                    size,
                    (end - start) / 1_000_000.0);

            // Best Case: Bereits aufsteigend sortiertes Array
            int[] arrBest = new int[size];
            for (int i = 0; i < size; i++) {
                arrBest[i] = i;
            }

            start = System.nanoTime();
            insertionSort(arrBest);
            end = System.nanoTime();
            System.out.printf(
                    "Insertion Sort (n=%d, best case): %.3f ms\n\n",
                    size,
                    (end - start) / 1_000_000.0);
        }
    }
}
