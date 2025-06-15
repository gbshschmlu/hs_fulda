package testat2;

import javashooter.gameutils.GameLoop;
import javashooter.playground.Playground;
import playground.BossLevel25;

public class Testat2 extends GameLoop {
	// Personen
	//	Luca M. Schmidt

	@Override
	public Playground nextLevel(Playground currentLevel) {
		if (currentLevel == null) {
			return new BossLevel25();
		}
		return null;
	}

	public static void main(String[] args) {
		Testat2 test = new Testat2();
		test.runGame(args);
	}

}

