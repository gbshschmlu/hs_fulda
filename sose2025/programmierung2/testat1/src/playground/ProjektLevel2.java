package playground;

import spaceinvadersProject.playground.SpaceInvadersLevel;

public class ProjektLevel2 extends SpaceInvadersLevel {
    @Override
    public String getName() {
        return "Level2";
    }


    @Override
    protected int calcNrEnemies() {
        return 5;
    }

    @Override
    protected String getStartupMessage() {
        return "Level2";
    }
}
