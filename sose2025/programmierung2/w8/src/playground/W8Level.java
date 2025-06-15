package playground;

import java.awt.Color;

import javashooter.controller.KinematicsController;
import javashooter.gameobjects.GameObject;
import javashooter.gameobjects.RectObject;
import javashooter.collider.RectCollider;
import spaceinvadersProject.playground.SpaceInvadersLevel;
import w8.rendering.FlashArtist;

public class W8Level extends SpaceInvadersLevel {
    @Override
    public String getName() {
        return "W8 Level";
    }

    @Override
    protected int calcNrEnemies() {
        return 0;
    }
    
    @Override
    public void prepareLevel(String id) {
        super.prepareLevel(id);
        
        // Erstes fliegendes Objekt erstellen (blau)
        RectObject flyEnemy1 = new RectObject("fly_enemy1", this, 300, 300, 30, 20, 30, 30, Color.BLUE);


        KinematicsController controller1 = new KinematicsController();
        flyEnemy1.setController(controller1);

        RectCollider collider1 = new RectCollider("collider1", flyEnemy1, 30, 30);
        flyEnemy1.addCollider(collider1);

        addObject(flyEnemy1);
        
        // Zweites fliegendes Objekt erstellen (grün)
        RectObject flyEnemy2 = new RectObject("fly_enemy2", this, 200, 200, 0, 20, 30, 30, Color.GREEN);

        KinematicsController controller2 = new KinematicsController();
        flyEnemy2.setController(controller2);

        RectCollider collider2 = new RectCollider("collider2", flyEnemy2, 30, 30);
        flyEnemy2.addCollider(collider2);

        addObject(flyEnemy2);
        
        // Bonus: Drittes Objekt mit wechselnden Farben
        RectObject flyEnemy3 = getFlyEnemy3();

        addObject(flyEnemy3);
    }

    private RectObject getFlyEnemy3() {
        RectObject flyEnemy3 = new RectObject("fly_enemy3", this, 400, 400, 15, 15, 30, 30, Color.RED);

        KinematicsController controller3 = new KinematicsController();
        flyEnemy3.setController(controller3);

        RectCollider collider3 = new RectCollider("collider3", flyEnemy3, 30, 30);
        flyEnemy3.addCollider(collider3);

        double gameTime = this.getGameTime();
        FlashArtist flashArtist = new FlashArtist(flyEnemy3, 30, 30, Color.RED, gameTime);
        flyEnemy3.addArtist(flashArtist);
        return flyEnemy3;
    }

    @Override
    protected void actionIfEgoCollidesWithEnemy(GameObject enemy, GameObject ego) {
        if (enemy.getId().startsWith("fly_enemy")) {
            System.out.println("AUA");
        } else {
            super.actionIfEgoCollidesWithEnemy(enemy, ego);
        }
    }
    
    @Override
    protected void actionIfEnemyIsHit(GameObject e, GameObject shot) {
        if (e.getId().startsWith("fly_enemy")) {
            deleteObject(shot.getId());
        } else {
            super.actionIfEnemyIsHit(e, shot);
        }
    }
}
