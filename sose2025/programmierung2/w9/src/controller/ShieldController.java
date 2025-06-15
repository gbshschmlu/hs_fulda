package controller;

import javashooter.controller.LimitedTimeController;
import javashooter.gameobjects.GameObject;

// Schutzschild
public class ShieldController extends LimitedTimeController {
    private GameObject egoObject;
    
    public ShieldController(double gameTime, double duration, GameObject egoObject) {
        super(gameTime, duration);
        this.egoObject = egoObject;
    }
    
    @Override
    public void updateObject() {
        // Schild folgt dem Ego-Objekt
        if (egoObject != null && egoObject.isActive()) {
            gameObject.setX(egoObject.getX());
            gameObject.setY(egoObject.getY());
        }
        
        // Begrenztes Leben durch Elternklasse verwalten
        super.updateObject();
    }
}
