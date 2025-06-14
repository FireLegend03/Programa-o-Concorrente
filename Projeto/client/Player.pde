public class Player{

    private PVector position = new PVector(0, 0); // Player position
    private float radius = 20; // Player radius
    private int points;
    private float r, g, b; // Player color
    private String name; // Player name

    public Player(float r, float g, float b) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.points = 0;
    }

    public void updatePlayer(String name ,float x, float y, int points) {
        this.name = name;
        this.position.x = x;
        this.position.y = y;
        this.points = points;
    }

    public void setName(String name) {
        this.name = name;
    }
    public String getName() {
        return this.name;
    }

    public int getPoints() {
        return this.points;
    }

    public void renderPlayer(){
        pushMatrix();
        stroke(0);
        fill(this.r, this.g, this.b);
        circle(this.position.x, this.position.y, this.radius);
        popMatrix();
    }
}
