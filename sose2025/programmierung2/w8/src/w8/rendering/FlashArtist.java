package w8.rendering;

import java.awt.Color;
import java.awt.Graphics2D;
import javashooter.gameobjects.GameObject;
import javashooter.rendering.RectArtist;

public class FlashArtist extends RectArtist {
    private double startTime;
    private Color color1 = Color.RED;
    private Color color2 = Color.BLUE;
    
    public FlashArtist(GameObject go, double width, double height, Color initialColor, double startTime) {
        super(go, width, height, initialColor);
        this.startTime = startTime;
    }
    
    @Override
    public void draw(Graphics2D g) {
        // Aktuelle Spielzeit ermitteln
        double currentTime = gameObject.getPlayground().getGameTime();
        double elapsedTime = currentTime - startTime;
        int flashCount = (int)(elapsedTime / 0.5);
        
        // Farbe alle 0.5 Sekunden wechseln
        if (flashCount % 2 == 0) {
            g.setColor(color1);
        } else {
            g.setColor(color2);
        }
        
        // Rechteck zeichnen (ohne super.draw zu verwenden, da wir die Farbe bereits gesetzt haben)
        g.fillRect((int)(- this.width / 2.), (int)(- this.height / 2.),
                  (int)this.width, (int)this.height);
    }
}
