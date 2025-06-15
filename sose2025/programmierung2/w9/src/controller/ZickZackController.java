package controller;

import javashooter.controller.LimitedTimeController;

// Animiertes Ego-Objekt
public class ZickZackController extends LimitedTimeController {

    private double lastDirectionChange = 0;
    private boolean movingRight = true;

    public ZickZackController(double gameTime, double duration) {
        super(gameTime, duration);
        this.lastDirectionChange = gameTime;
    }

    @Override
    public void updateObject() {
        double currentTime = getPlayground().getGameTime();

        if (currentTime - lastDirectionChange > 0.5) {
            // Richtung wechseln
            movingRight = !movingRight;

            //  -30 oder 30 Pixel/s
            double newVX = movingRight ? 30 : -30;
            gameObject.setVX(newVX);

            // Zeit für nächsten Wechsel setzen
            lastDirectionChange = currentTime;
        }

        super.updateObject();
    }
}
