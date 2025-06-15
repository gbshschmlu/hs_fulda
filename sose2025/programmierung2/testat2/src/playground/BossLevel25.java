package playground;

import javashooter.gameobjects.GameObject;
import spaceinvadersProject.playground.SpaceInvadersLevel;

import java.awt.*;
import java.awt.font.TextAttribute;
import java.text.AttributedString;

public class BossLevel25 extends SpaceInvadersLevel {
    protected int nrShots = 0;

    @Override
    protected String getStartupMessage() {
        return "BossLevel!!";
    }


    @Override
    protected int calcNrEnemies() {
        return 1;
    }

    @Override
    protected double calcEnemySpeedX() {
        return 180.0;
    }

    @Override
    protected double calcEnemySpeedY() {
        return 40.0;
    }

    @Override
    protected double calcEnemyShotProb() {
        return 0.01 * this.getTimestep();
    }

    @Override
    protected void actionIfEnemyIsHit(GameObject e, GameObject shot) {
        nrShots++;

        if (nrShots >= 20) {
            super.actionIfEnemyIsHit(e, shot);
            return;
        }

        // Schuss des Bosses muss auch bei nicht tödlichem Treffer gelöscht werden
        deleteObject(shot.getId());
    }

    @Override
    public void redrawLevel(Graphics2D g2) {
        // Eigentliches Level zeichnen
        super.redrawLevel(g2);

        // Neuen Text zeichnen
        Font drawFont = new Font("SansSerif", Font.PLAIN, 20);
        AttributedString as = new AttributedString("Boss-Hits: " + nrShots + " / 20");
        as.addAttribute(TextAttribute.FONT, drawFont);
        as.addAttribute(TextAttribute.FOREGROUND, Color.yellow);
        g2.drawString(as.getIterator(), 120, 20);
    }

    @Override
    protected GameObject createEnemyShot(GameObject e) {
        // Eigentliches Schussobjekt erstellen
        GameObject shot = super.createEnemyShot(e);

        // Kein Schussobjekt erstellt -> dann auch nichts weiter tun
        if (shot == null) {
            return null;
        }

        // Ego-Objekt holen
        GameObject ego = this.getObject("ego");

        if (ego != null) {
            // Differenzvektor zwischen der Position des Aliens und der des Ego-Objekts
            double dx = ego.getX() - shot.getX();
            double dy = ego.getY() - shot.getY();

            // Norm des Differenzvektors
            double norm = Math.sqrt(dx * dx + dy * dy);

            // Geschwindigkeitsvektor berechnen
            double S = 400.0;  // Geschwindigkeit des Schusses
            double vx = (dx * S) / norm;  // Normierung des Vektors
            double vy = (dy * S) / norm;  // Normierung des Vektors

            // Geschwindigkeitsvektor setzen
            shot.setVX(vx);
            shot.setVY(vy);
        }

        return shot;
    }
}
