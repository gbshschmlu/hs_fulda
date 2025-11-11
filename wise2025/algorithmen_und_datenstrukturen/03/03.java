import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;

public class Uebungsblatt03 {

    private static final Random RAND = new Random();

    // === Aufgabe 3.1: QUICK SORT (Middle Pivot) ===
    public static void quickSortMiddlePivot(int[] a) {
        quicksort(a, 0, a.length - 1, "middle");
    }

    // === Aufgabe 3.2: Randomized QUICK SORT ===
    public static void quickSortRandomPivot(int[] a) {
        quicksort(a, 0, a.length - 1, "random");
    }

    // === Aufgabe 3.4: QUICK SORT (Median-of-Medians Pivot) ===
    public static void quickSortMedianPivot(int[] a) {
        quicksort(a, 0, a.length - 1, "median");
    }

    // Quicksort aus der Vorlesugn (+ Pivot-Strategie)
    private static void quicksort(int[] a, int left, int right, String pivotStrategy) {
        if (left >= right) {
            return;
        }

        int pivot;
        if (pivotStrategy.equals("median")) {
            int[] subarray = Arrays.copyOfRange(a, left, right + 1);
            pivot = select(subarray, subarray.length / 2);
        } else {
            int pivotIndex = getPivotIndex(left, right, pivotStrategy);
            pivot = a[pivotIndex];
        }

        int i = left,
            j = right;
        int tmp;
        while (i <= j) {
            while (a[i] < pivot) i++;
            while (a[j] > pivot) j--;
            if (i <= j) {
                tmp = a[i];
                a[i] = a[j];
                a[j] = tmp;
                i++;
                j--;
            }
        }

        if (left < j) quicksort(a, left, j, pivotStrategy);
        if (i < right) quicksort(a, i, right, pivotStrategy);
    }

    private static int getPivotIndex(int left, int right, String strategy) {
        switch (strategy) {
            case "random":
                return left + RAND.nextInt(right - left + 1);
            case "middle":
            default:
                return left + (right - left) / 2;
        }
    }

    // === Aufgabe 3.3: Linear Time Median (Select Algorithm) ===
    public static int select(int[] s, int k) {
        if (s.length < 50) {
            Arrays.sort(s);
            return s[k];
        }

        // Teile S in Gruppen von 5 Elementen
        List<Integer> medians = new ArrayList<>();
        for (int i = 0; i < s.length / 5; i++) {
            int[] group = new int[5];
            System.arraycopy(s, i * 5, group, 0, 5);
            Arrays.sort(group);
            medians.add(group[2]);
        }

        // Behandle die letzte Gruppe, falls vorhanden
        if (s.length % 5 > 0) {
            int[] lastGroup = new int[s.length % 5];
            System.arraycopy(
                s,
                s.length - lastGroup.length,
                lastGroup,
                0,
                lastGroup.length
            );
            Arrays.sort(lastGroup);
            medians.add(lastGroup[lastGroup.length / 2]);
        }

        int[] mediansArray = medians
            .stream()
            .mapToInt(i -> i)
            .toArray();
        int m = select(mediansArray, mediansArray.length / 2);

        // Bilde Mengen A, B, C basierend auf dem Median der Mediane 'm'
        List<Integer> aList = new ArrayList<>();
        List<Integer> bList = new ArrayList<>();
        List<Integer> cList = new ArrayList<>();
        for (int val : s) {
            if (val < m) aList.add(val);
            else if (val == m) bList.add(val);
            else cList.add(val);
        }

        if (k < aList.size()) {
            return select(
                aList
                    .stream()
                    .mapToInt(i -> i)
                    .toArray(),
                k
            );
        } else if (k < aList.size() + bList.size()) {
            return m;
        } else {
            return select(
                cList
                    .stream()
                    .mapToInt(i -> i)
                    .toArray(),
                k - aList.size() - bList.size()
            );
        }
    }

    // ---

    public static void main(String[] args) {
        int[] sizes = { 10000, 50000, 100000 };

        // Aufgabe 3.1
        System.out.println("=== Aufgabe 3.1: QUICK SORT (Middle Pivot) ===\n");
        for (int size : sizes) {
            benchmark(size, "Middle", "middle");
        }

        // Aufgabe 3.2
        System.out.println("\n=== Aufgabe 3.2: Randomized QUICK SORT ===\n");
        for (int size : sizes) {
            benchmark(size, "Random", "random");
        }

        // Aufgabe 3.3
        System.out.println(
            "\n=== Aufgabe 3.3: Linear Time Median (Select Algorithm) ===\n"
        );
        int[] medianSizes = { 100000, 500000, 1000000 };
        for (int size : medianSizes) {
            int[] arr = createRandomArray(size);
            long start = System.nanoTime();
            select(arr.clone(), arr.length / 2);
            long end = System.nanoTime();
            System.out.printf(
                "Median-of-Medians (n=%d): %.3f ms\n",
                size,
                (end - start) / 1_000_000.0
            );
        }

        // Aufgabe 3.4
        System.out.println(
            "\n\n=== Aufgabe 3.4: QUICK SORT (Median-of-Medians Pivot) ===\n"
        );
        for (int size : sizes) {
            benchmark(size, "Median", "median");
        }
    }

    private static void benchmark(int size, String name, String strategy) {
        int[] average = createRandomArray(size);
        int[] worstCase = createWorstCaseForMiddlePivot(size);

        // Average Case: Zufälliges Array
        long start = System.nanoTime();
        quicksort(average, 0, average.length - 1, strategy);
        long end = System.nanoTime();
        System.out.printf(
            "Quick Sort (%s, n=%d, average): %.3f ms\n",
            name,
            size,
            (end - start) / 1_000_000.0
        );

        // Worst Case: Speziell konstruiert
        start = System.nanoTime();
        quicksort(worstCase, 0, worstCase.length - 1, strategy);
        end = System.nanoTime();
        System.out.printf(
            "Quick Sort (%s, n=%d, worst case): %.3f ms\n\n",
            name,
            size,
            (end - start) / 1_000_000.0
        );
    }

    // Hilfsmethoden

    private static int[] createRandomArray(int size) {
        List<Integer> list = new ArrayList<>(size);
        for (int i = 0; i < size; i++) {
            list.add(i);
        }
        Collections.shuffle(list);
        return list
            .stream()
            .mapToInt(i -> i)
            .toArray();
    }

    private static int[] createWorstCaseForMiddlePivot(int size) {
        int[] arr = new int[size];

        // Strategie: Viele Duplikate des mittleren Werts
        // Das führt dazu, dass viele Elemente gleich dem Pivot sind
        // und die Partitionierung sehr ineffizient wird

        int mid = size / 2;
        for (int i = 0; i < size; i++) {
            if (i < size / 4) {
                arr[i] = 1; // Untere Werte
            } else if (i >= (3 * size) / 4) {
                arr[i] = 3; // Obere Werte
            } else {
                arr[i] = 2; // Viele Duplikate in der Mitte
            }
        }

        return arr;
    }
}
