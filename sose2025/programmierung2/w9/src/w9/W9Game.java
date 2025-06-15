package w9;

import javashooter.gameutils.GameLoop;
import javashooter.playground.Playground;
import playground.W9Level;

public class W9Game extends GameLoop {
    // Personen
    //	Luca M, Schmidt

    // Aufgabe 3 Frage
    //	Es geht sonst nicht, da man die Methode sonst außerhalb
    //	des Packages nicht sehen (und somit überschreiben) kann.

    @Override
    public Playground nextLevel(Playground currentLevel) {
        if (currentLevel == null) {
            return new W9Level();
        }
        return null;
    }

    public static void main(String[] args) {
        W9Game test = new W9Game();
        test.runGame(args);
    }

}
