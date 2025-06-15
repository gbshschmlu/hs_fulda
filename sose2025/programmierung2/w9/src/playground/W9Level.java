package playground;

import controller.ShieldController;
import controller.ZickZackController;
import javashooter.collider.CircleCollider;
import javashooter.gameobjects.GameObject;
import javashooter.rendering.CircleArtist;
import javashooter.rendering.PulsatingCircleArtist;
import spaceinvadersProject.playground.SpaceInvadersLevel;

import java.awt.*;

public class W9Level extends SpaceInvadersLevel {

    private static final double ROTIERENDE_SCHUESSE_DAUER = 5.0; // 5 Sekunden
    private static final double SCHILD_DAUER = 5.0; // 5 Sekunden
    private static final int SCHILD_RADIUS = 50; // 50 Pixel
    private double rotatingShotsUntil = 0;

    @Override
    public String getName() {
        return "W9 Level";
    }

    @Override
    protected int calcNrEnemies() {
        return 1;
    }


    @Override
    protected void actionIfEgoCollidesWithCollect(GameObject collect, GameObject ego) {
        rotatingShotsUntil = getGameTime() + ROTIERENDE_SCHUESSE_DAUER;

        // Schild erstellen
        double gameTime = getGameTime();

        // Halbdurchsichtige Farbe (mit Alpha-Kanal)
        Color schildFarbe = new Color(55, 55, 201, 215);

        // Schild-Objekt erstellen
        GameObject schild = new GameObject("schild" + gameTime, this,
                ego.getX(), ego.getY(), 0, 0);

        // CircleArtist hinzufügen ohne Collider
        schild.addArtist(new CircleArtist(schild, SCHILD_RADIUS, schildFarbe));

        // ShieldController setzen
        schild.setController(new ShieldController(gameTime, SCHILD_DAUER, ego));

        // Zum Playground hinzufügen
        addObject(schild);

        // Standardverhalten durch Elternmethode
        super.actionIfEgoCollidesWithCollect(collect, ego);
    }

    @Override
    // Drehende Schüsse
    public GameObject createEnemyShot(GameObject ego) {
        GameObject shot = super.createEnemyShot(ego);

        if (shot == null) {
            return null;
        }

        if (getGameTime() <= rotatingShotsUntil) {
            shot.setOmega(Math.PI);
        }

        return shot;
    }

    @Override
    // Animiertes Ego-Objekt
    protected GameObject createEgoObject() {
        GameObject ego = super.createEgoObject();

        if (ego == null) {
            return null;
        }

        PulsatingCircleArtist pulsatingArtist = new PulsatingCircleArtist(
                ego,
                EGORAD,
                Color.GREEN,
                0.7,
                (double) 1 /30
        );

        ego.addArtist(pulsatingArtist);

        return ego;
    }
}
