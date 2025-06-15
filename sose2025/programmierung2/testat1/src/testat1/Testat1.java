package testat1;

import javashooter.gameutils.GameLoop;
import javashooter.playground.Playground;
import playground.ProjektLevel1;
import playground.ProjektLevel2;
import playground.ProjektLevel3;


public class Testat1 extends GameLoop {
    // Personen:
    //	Luca M. Schmidt
    // 	Roman W. Sippel

    // Verständnisfrage: welche Konstruktoren werden bei der Instanziierung von Testat1 aufgerufen?
    //	- Objekt
    //	- Gameloop
    //	- Testat1

    // Achtung: Sie müssen zuerst prüfen, ob diese Referenz nicht null ist bevor Sie die Methode getName aufrufen! Warum?
    //  Wenn das Objekt null ist, kann die Methode nicht aufgerufen werden, da es kein Objekt gibt.
    //  Dies führt zu einem NullPointerException

    // Spielen Sie die drei Level durch und überzeugen Sie Sich, dass sie identisch sind. Warum?
    //  Alle drei Level sind identisch, weil sie alle von der gleichen Klasse erben und nichts außer dessen Namen überschreiben

    // Damit das klappt, muss auch die Klasse javashooter.playground.GameObject importiert werden. Warum?
    //  Da man den Typen GameObject in der Methode actionIfEnemyIsHit() als parameter typ verwendet, muss die Klasse importiert werden.


    public Testat1() {
        System.out.println("Hallo");
    }

    @Override
    public Playground nextLevel(Playground currentLevel) {
        // x -> 1
        if (currentLevel == null) {
            return new ProjektLevel1();
        }

        switch (currentLevel.getName()) {
            // 1 -> 2
            case "Level1" -> {
                return new ProjektLevel2();
            }
            // 2 -> 3
            case "Level2" -> {
                return new ProjektLevel3();
            }
            // 3 -> 1
            case "Level3" -> {
                return new ProjektLevel1();
            }
        }
        return currentLevel;
    }

    public static void main(String[] args) {
        ProjektLevel1 level1 = new ProjektLevel1();
        System.out.println(level1.getName());
        ProjektLevel2 level2 = new ProjektLevel2();
        System.out.println(level2.getName());
        ProjektLevel3 level3 = new ProjektLevel3();
        System.out.println(level3.getName());

        Testat1 game = new Testat1();
        game.runGame(args);
    }

}
