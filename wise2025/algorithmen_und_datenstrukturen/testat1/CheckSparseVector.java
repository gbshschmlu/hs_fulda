public class CheckSparseVector {
    // Flo: 1 + 6
    // Roman: 3 + 5
    // Joshi: 2 + 7
    // Luca: 4 + 8

    public static void main(String[] args) {
        System.out.println("=== Test 1 ===");
        test1_ConstructorAndGetLength();

        System.out.println("\n=== Test 2 ===");
        test2_SetAndGetElement();

        System.out.println("\n=== Test 3 ===");
        test3_RemoveElement();

        System.out.println("\n=== Test 4 ===");
        test4_Equals();

        System.out.println("\n=== Test 5 ===");
        test5_SetElementMultipleAndSorting();

        System.out.println("\n=== Test 6 ===");
        test6_AddOverlapping();

        System.out.println("\n=== Test 7 ===");
        test7_AddNonOverlapping();

        System.out.println("\n=== Test 8 ===");
        test8_ExceptionsAndEdgeCases();
    }

    // Test 1 (Flo): Konstruktor und getLength
    // Testet die Initialisierung von Vektoren mit verschiedenen Längen
    public static void test1_ConstructorAndGetLength() {
        SparseVector v1 = new SparseVector(10);
        if (v1.getLength() == 10) {
            System.out.println("B: getLength() gibt 10 zurück");
        } else {
            System.out.println("F: getLength() liefert " + v1.getLength() + " statt 10");
        }

        SparseVector v2 = new SparseVector();
        if (v2.getLength() == 0) {
            System.out.println("B: getLength() gibt 0 zurück für leeren Vektor");
        } else {
            System.out.println("F: getLength() liefert " + v2.getLength() + " statt 0");
        }
    }

    // Test 2 (Joshi): setElement und getElement
    // Testet das Setzen und Abrufen einzelner Elemente
    public static void test2_SetAndGetElement() {
        try {
            SparseVector vec = new SparseVector(5);
            System.out.println("I: Vektor mit Länge 5 erstellt");

            vec.setElement(2, 3.5);
            double value2 = vec.getElement(2);
            if (Math.abs(value2 - 3.5) < 1e-10) {
                System.out.println("B: getElement(2) = 3.5");
            } else {
                System.out.println("F: getElement(2) = " + value2 + " statt 3.5");
            }

            double value0 = vec.getElement(0);
            if (Math.abs(value0 - 0.0) < 1e-10) {
                System.out.println("B: getElement(0) = 0.0");
            } else {
                System.out.println("F: getElement(0) = " + value0 + " statt 0.0");
            }
        } catch (Exception e) {
            System.out.println("F: Exception aufgetreten: " + e.getMessage());
        }
    }

    // Test 3 (Roman): removeElement
    // Testet das Entfernen von Elementen aus dem Vektor
    private static void test3_RemoveElement() {
        SparseVector v = new SparseVector(5);
        v.setElement(2, 42.0);
        System.out.println("I: Wert an Index 2: " + v.getElement(2));

        v.removeElement(2);
        double valueAfterRemove = v.getElement(2);
        if (valueAfterRemove == 0.0) {
            System.out.println("B: Element erfolgreich entfernt");
        } else {
            System.out.println("F: Wert nach removeElement = " + valueAfterRemove + " statt 0.0");
        }
    }

    // Test 4 (Luca): equals
    // Testet die Gleichheit von Vektoren in verschiedenen Szenarien
    public static void test4_Equals() {
        SparseVector v1 = new SparseVector(10);
        SparseVector v2 = new SparseVector(10);

        // Beide leer
        if (v1.equals(v2)) {
            System.out.println("B: Zwei leere Vektoren sind gleich");
        } else {
            System.out.println("F: Zwei leere Vektoren sollten gleich sein");
        }

        // Gleiche Elemente
        v1.setElement(2, 3.5);
        v1.setElement(5, 7.2);
        v1.setElement(8, 1.1);
        v2.setElement(2, 3.5);
        v2.setElement(5, 7.2);
        v2.setElement(8, 1.1);
        if (v1.equals(v2)) {
            System.out.println("B: Vektoren mit gleichen Elementen sind gleich");
        } else {
            System.out.println("F: Vektoren mit gleichen Elementen sollten gleich sein");
        }

        // Ein Element unterschiedlich
        v2.setElement(5, 9.9);
        if (!v1.equals(v2)) {
            System.out.println("B: Vektoren mit unterschiedlichen Werten sind nicht gleich");
        } else {
            System.out.println("F: Vektoren mit unterschiedlichen Werten sollten nicht gleich sein");
        }

        // Unterschiedliche Anzahl Elemente
        v2.setElement(5, 7.2);
        v2.setElement(9, 4.4);
        if (!v1.equals(v2)) {
            System.out.println("B: Vektoren mit unterschiedlicher Anzahl sind nicht gleich");
        } else {
            System.out.println("F: Vektoren mit unterschiedlicher Anzahl sollten nicht gleich sein");
        }

        // Unterschiedliche Längen
        SparseVector v3 = new SparseVector(5);
        if (!v1.equals(v3)) {
            System.out.println("B: Vektoren mit unterschiedlicher Länge sind nicht gleich");
        } else {
            System.out.println("F: Vektoren mit unterschiedlicher Länge sollten nicht gleich sein");
        }

        // Vergleich mit null
        if (!v1.equals(null)) {
            System.out.println("B: Vergleich mit null gibt false zurück");
        } else {
            System.out.println("F: Vergleich mit null sollte false zurückgeben");
        }
    }

    // Test 5 (Roman): setElement mit mehreren Elementen und Sortierung
    // Testet ob Elemente in falscher Reihenfolge gesetzt werden können
    private static void test5_SetElementMultipleAndSorting() {
        SparseVector v = new SparseVector(10);
        v.setElement(8, 8.0);
        v.setElement(3, 3.0);
        v.setElement(5, 5.0);

        boolean ok = true;
        for (int i = 0; i < v.getLength(); i++) {
            double val = v.getElement(i);
            double expected = (i == 3) ? 3.0 : (i == 5) ? 5.0 : (i == 8) ? 8.0 : 0.0;
            if (val != expected) {
                ok = false;
                System.out.println("F: Index " + i + " = " + val + " statt " + expected);
            }
        }

        if (ok) {
            System.out.println("B: Alle Elemente korrekt sortiert");
        }
    }

    // Test 6 (Flo): add mit überlappenden Indizes
    // Testet Addition wenn beide Vektoren Werte an gleichen Indizes haben
    public static void test6_AddOverlapping() {
        SparseVector v1 = new SparseVector(5);
        SparseVector v2 = new SparseVector(5);

        v1.setElement(1, 3.0);
        v1.setElement(3, -2.0);
        v2.setElement(1, 4.0);
        v2.setElement(3, 2.0);

        v1.add(v2);

        boolean success = true;
        if (v1.getElement(1) == 7.0) {
            System.out.println("B: Index 1 korrekt addiert (7.0)");
        } else {
            System.out.println("F: Index 1 = " + v1.getElement(1) + " statt 7.0");
            success = false;
        }

        if (v1.getElement(3) == 0.0) {
            System.out.println("B: Index 3 korrekt entfernt (Sparse-Eigenschaft)");
        } else {
            System.out.println("F: Index 3 = " + v1.getElement(3) + " statt 0.0");
            success = false;
        }

        if (!success) {
            System.out.println("F: Test fehlgeschlagen");
        }
    }

    // Test 7 (Joshi): add mit nicht-überlappenden Indizen
    // Testet Addition wenn Vektoren keine gemeinsamen Indizes haben
    public static void test7_AddNonOverlapping() {
        try {
            SparseVector vec1 = new SparseVector(7);
            SparseVector vec2 = new SparseVector(7);
            System.out.println("I: Zwei Vektoren mit Länge 7 erstellt");

            vec1.setElement(1, 1.1);
            vec1.setElement(3, 3.3);
            vec1.setElement(5, 5.5);

            vec2.setElement(2, 2.2);
            vec2.setElement(4, 4.4);
            vec2.setElement(6, 6.6);

            vec1.add(vec2);

            boolean ok = true;
            ok &= Math.abs(vec1.getElement(1) - 1.1) < 1e-10;
            ok &= Math.abs(vec1.getElement(2) - 2.2) < 1e-10;
            ok &= Math.abs(vec1.getElement(3) - 3.3) < 1e-10;
            ok &= Math.abs(vec1.getElement(4) - 4.4) < 1e-10;
            ok &= Math.abs(vec1.getElement(5) - 5.5) < 1e-10;
            ok &= Math.abs(vec1.getElement(6) - 6.6) < 1e-10;
            ok &= Math.abs(vec1.getElement(0) - 0.0) < 1e-10;

            if (ok) {
                System.out.println("B: Alle Elemente korrekt addiert");
            } else {
                System.out.println("F: Mindestens ein Element falsch");
            }
        } catch (Exception e) {
            System.out.println("F: Exception aufgetreten: " + e.getMessage());
        }
    }

    // Test 8 (Luca): Exceptions und Randfälle
    // Testet Fehlerbehandlung und Edge Cases
    public static void test8_ExceptionsAndEdgeCases() {
        SparseVector v = new SparseVector(5);

        // Negativer Index bei setElement
        try {
            v.setElement(-1, 5.0);
            System.out.println("F: Negativer Index sollte Exception werfen");
        } catch (Exception e) {
            System.out.println("B: Negativer Index wirft " + e.getClass().getSimpleName());
        }

        // Index >= length bei setElement
        try {
            v.setElement(10, 5.0);
            System.out.println("F: Index >= length sollte Exception werfen");
        } catch (Exception e) {
            System.out.println("B: Index >= length wirft " + e.getClass().getSimpleName());
        }

        // Negativer Index bei getElement
        try {
            v.getElement(-1);
            System.out.println("F: Negativer Index sollte Exception werfen");
        } catch (Exception e) {
            System.out.println("B: Negativer Index wirft " + e.getClass().getSimpleName());
        }

        // Index >= length bei getElement
        try {
            v.getElement(10);
            System.out.println("F: Index >= length sollte Exception werfen");
        } catch (Exception e) {
            System.out.println("B: Index >= length wirft " + e.getClass().getSimpleName());
        }

        // add() mit null
        try {
            v.add(null);
            System.out.println("F: add(null) sollte Exception werfen");
        } catch (IllegalArgumentException e) {
            System.out.println("B: add(null) wirft IllegalArgumentException");
        } catch (Exception e) {
            System.out.println("F: add(null) wirft falsche Exception: " + e.getClass().getSimpleName());
        }

        // add() mit unterschiedlichen Längen
        try {
            SparseVector v2 = new SparseVector(10);
            v.add(v2);
            System.out.println("F: add() mit unterschiedlichen Längen sollte Exception werfen");
        } catch (IllegalArgumentException e) {
            System.out.println("B: add() mit unterschiedlichen Längen wirft IllegalArgumentException");
        } catch (Exception e) {
            System.out.println("F: add() wirft falsche Exception: " + e.getClass().getSimpleName());
        }

        // Negativer Konstruktor-Parameter
        try {
            SparseVector vNeg = new SparseVector(-5);
            System.out.println("F: Negative Länge sollte Exception werfen");
        } catch (IllegalArgumentException e) {
            System.out.println("B: Negative Länge wirft IllegalArgumentException");
        } catch (Exception e) {
            System.out.println("F: Konstruktor wirft falsche Exception: " + e.getClass().getSimpleName());
        }

        // setElement mit 0.0 entfernt Element
        SparseVector v3 = new SparseVector(5);
        v3.setElement(2, 5.0);
        v3.setElement(2, 0.0);
        double result = v3.getElement(2);
        if (result == 0.0) {
            System.out.println("B: setElement mit 0.0 entfernt Element korrekt");
        } else {
            System.out.println("F: setElement mit 0.0 sollte Element entfernen");
        }
    }
}
