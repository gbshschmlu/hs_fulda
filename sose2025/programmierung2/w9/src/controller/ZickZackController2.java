package controller;

import javashooter.controller.LimitedTimeController;

public class ZickZackController2 extends LimitedTimeController {

	private static final double TOGGLE_INTERVAL = 0.5;
	private static final double VX = 30.0;

	private double lastToggleTime;

	public ZickZackController2(double g0, double duration) {
		super(g0, duration);
		this.lastToggleTime = g0; // erster Wechsel nach 0,5 s
	}

	@Override
	public void updateObject() {
		double gameTime = getPlayground().getGameTime();
		if (gameObject != null) {
			// Seitliche Richtung alle 0,5 s umkehren
			if ((gameTime - lastToggleTime) >= TOGGLE_INTERVAL) {
				double currentVX = gameObject.getVX();
				double newVX;

				// Bestimmen, in welche Richtung der Schuss als Nächstes wandern soll
				if (currentVX >= 0) {
					newVX = -VX; // nach links
				} else {
					newVX = VX; // nach rechts
				}

				gameObject.setVX(newVX);
				lastToggleTime += TOGGLE_INTERVAL; // Intervall aktualisieren
			}

			// Standard‑Logik des LimitedTimeController (Bewegung, Lifetime‑Check)
			super.updateObject();
		}
	}
}