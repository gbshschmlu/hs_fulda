package playground;

import javashooter.gameobjects.GameObject;
import spaceinvadersProject.playground.SpaceInvadersLevel;

public class ProjektLevel1 extends SpaceInvadersLevel {
	@Override
	public String getName() {
		return "Level1";
	}

	@Override
	protected int calcNrEnemies() {
		return 1;
	}

	@Override
	protected String getStartupMessage() {
		return "Level1";
	}

	@Override
	protected void actionIfEnemyIsHit(GameObject enemy, GameObject shot) {
		// Eigene Aktion
		System.out.println("AUA!!");

		// Original aufruf
		super.actionIfEnemyIsHit(enemy, shot);
	}
}
