public class Main {

    // Aufgabe 1.1: Lineare Suche
    public static int linearSearch(int[] arr, int target) {
        // Durchlaufe das Array
        for (int i = 0; i < arr.length; i++) {
            // Überprüfe, ob das aktuelle Element das Ziel ist
            if (arr[i] == target) {
                return i;
            }
        }
        return -1;
    }

    // Aufgabe 1.1: Binäre Suche
    public static int binarySearch(int[] arr, int target) {
        int left = 0;
        int right = arr.length - 1;

        // Solange der linke Index kleiner oder gleich dem rechten Index ist
        while (left <= right) {
            // Mittleren Index im aktuellen Bereich berechnen
            int mid = left + (right - left) / 2;

            // Überprüfen, ob das mittlere Element das Ziel ist
            if (arr[mid] == target) {
                return mid;
            }
            // Entscheiden, ob im linken oder rechten Teil weitergesucht wird
            if (arr[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return -1;
    }

    // Aufgabe 1.2: Bubble Sort
    public static void bubbleSort(int[] arr) {
        int n = arr.length;
        // Wie oft man durch das Array gehen muss
        for (int i = 0; i < n - 1; i++) {
            // Vergleiche benachbarte Elemente
            // n - i - 1, da die letzten i Elemente bereits sortiert sind
            for (int j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    // Tausche arr[j] und arr[j + 1] wenn sie in der falschen Reihenfolge sind
                    int temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }
            }
        }
    }

    // Aufgabe 1.3: Selection Sort
    public static void selectionSort(int[] arr) {
        int n = arr.length;
        // i trennt das unsortierte und sortierte Segment
        for (int i = 0; i < n - 1; i++) {
            // Finde das kleinste Element im unsortierten Segment
            int minIdx = i;
            for (int j = i + 1; j < n; j++) {
                if (arr[j] < arr[minIdx]) {
                    minIdx = j;
                }
            }

            // Tausche das gefundene kleinste Element mit dem ersten Element des unsortierten Segments
            int temp = arr[minIdx];
            arr[minIdx] = arr[i];
            arr[i] = temp;
        }
    }

    public static void main(String[] args) {
        System.out.println("=== Aufgabe 1.1: Laufzeitmessungen Suche ===\n");

        int[] sizes = { 1000, 10000, 100000, 1000000 };

        for (int size : sizes) {
            int[] arr = new int[size];
            for (int i = 0; i < size; i++) {
                arr[i] = i;
            }

            // Lineare Suche - Element ganz vorne
            long start = System.nanoTime();
            linearSearch(arr, 0);
            long end = System.nanoTime();
            System.out.printf(
                "Linear Search (n=%d, vorne): %.3f ms\n",
                size,
                (end - start) / 1_000_000.0
            );

            // Lineare Suche - Element ganz hinten
            start = System.nanoTime();
            linearSearch(arr, size - 1);
            end = System.nanoTime();
            System.out.printf(
                "Linear Search (n=%d, hinten): %.3f ms\n",
                size,
                (end - start) / 1_000_000.0
            );

            // Lineare Suche - Element nicht vorhanden
            start = System.nanoTime();
            linearSearch(arr, -1);
            end = System.nanoTime();
            System.out.printf(
                "Linear Search (n=%d, nicht vorhanden): %.3f ms\n",
                size,
                (end - start) / 1_000_000.0
            );

            // Binäre Suche - Element ganz vorne
            start = System.nanoTime();
            binarySearch(arr, 0);
            end = System.nanoTime();
            System.out.printf(
                "Binary Search (n=%d, vorne): %.3f µs\n",
                size,
                (end - start) / 1000.0
            );

            // Binäre Suche - Element in der Mitte
            start = System.nanoTime();
            binarySearch(arr, size / 2);
            end = System.nanoTime();
            System.out.printf(
                "Binary Search (n=%d, mitte): %.3f µs\n",
                size,
                (end - start) / 1000.0
            );

            // Binäre Suche - Element ganz hinten
            start = System.nanoTime();
            binarySearch(arr, size - 1);
            end = System.nanoTime();
            System.out.printf(
                "Binary Search (n=%d, hinten): %.3f µs\n",
                size,
                (end - start) / 1000.0
            );

            // Binäre Suche - Element nicht vorhanden
            start = System.nanoTime();
            binarySearch(arr, size + 1);
            end = System.nanoTime();
            System.out.printf(
                "Binary Search (n=%d, nicht vorhanden): %.3f µs\n\n",
                size,
                (end - start) / 1000.0
            );
        }

        System.out.println("=== Aufgabe 1.2: Laufzeitmessungen BUBBLE SORT ===\n");

        int[] sortSizes = { 1000, 2000, 5000, 10000 };

        for (int size : sortSizes) {
            // Worst case: absteigend sortiert
            int[] arr = new int[size];
            for (int i = 0; i < size; i++) {
                arr[i] = size - i;
            }

            long start = System.nanoTime();
            bubbleSort(arr.clone());
            long end = System.nanoTime();
            System.out.printf(
                "Bubble Sort (n=%d, worst case): %.3f ms\n",
                size,
                (end - start) / 1_000_000.0
            );

            // Best case: bereits sortiert
            for (int i = 0; i < size; i++) {
                arr[i] = i;
            }

            start = System.nanoTime();
            bubbleSort(arr.clone());
            end = System.nanoTime();
            System.out.printf(
                "Bubble Sort (n=%d, best case): %.3f ms\n\n",
                size,
                (end - start) / 1_000_000.0
            );
        }

        System.out.println("=== Aufgabe 1.3: Laufzeitmessungen SELECTION SORT ===\n");

        for (int size : sortSizes) {
            // Worst case: absteigend sortiert
            int[] arr = new int[size];
            for (int i = 0; i < size; i++) {
                arr[i] = size - i;
            }

            long start = System.nanoTime();
            selectionSort(arr.clone());
            long end = System.nanoTime();
            System.out.printf(
                "Selection Sort (n=%d, worst case): %.3f ms\n",
                size,
                (end - start) / 1_000_000.0
            );

            // Best case: bereits sortiert
            for (int i = 0; i < size; i++) {
                arr[i] = i;
            }

            start = System.nanoTime();
            selectionSort(arr.clone());
            end = System.nanoTime();
            System.out.printf(
                "Selection Sort (n=%d, best case): %.3f ms\n\n",
                size,
                (end - start) / 1_000_000.0
            );
        }
    }
}
