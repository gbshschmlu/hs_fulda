package w8;

import javashooter.gameutils.GameLoop;
import javashooter.playground.Playground;
import playground.W8Level;

public class EigenesSpielW8 extends GameLoop {
    // Personen
    //	Luca M. Schmidt

    // Prüfen Sie, ob es etwas ausmacht, ob man die Objekte zum Level hinzufügt und
    // danach Controller und Collider für sie festlegt, oder andersherum. Warum ist das
    // so?
    //    Ja, die Reihenfolge ist wichtig.
    //    Ein GameObject benötigt seinen Controller und Collider für Logik und Kollisionserkennung.
    //    Werden diese erst nach dem Hinzufügen des Objekts zum Level gesetzt, kann es zu unerwartetem
    //    Verhalten kommen, da die Komponenten bei Aktivierung des Objekts möglicherweise noch nicht verfügbar sind.

    // Was passiert, wenn Sie den beiden von Ihnen erzeugten
    // Objekten keinen Collider hinzufügen? Und warum?
    //    Ohne Collider können die Objekte nicht mit anderen Objekten interagieren oder Kollisionen erkennen.
    //    Dadurch wird das "Aua" nicht mehr ausgelöst, wenn es auf den Spieler trifft.

    @Override
    public Playground nextLevel(Playground currentLevel) {
        if (currentLevel == null) {
            return new W8Level();
        }
        return null;
    }

    public static void main(String[] args) {
        EigenesSpielW8 test = new EigenesSpielW8();
        test.runGame(args);
    }

}
