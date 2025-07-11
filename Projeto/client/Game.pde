import processing.sound.*;

private enum State{
    MENU,
    REGISTER,
    LOGIN,
    DELETE_ACCOUNT,
    LOGGED,
    LOBBY,
    PLAYING,
    MATCH_OVER,
    TOP_10
}

private State currentState;

private ConnectionManager cm;

private Player player = new Player(255, 255, 255); // Jogador é Branco
private Player opponent = new Player(255, 0, 255); // adversário é Fuschia

private Shot[] playerShots = new Shot[20]; // Array de tiros do jogador
private Shot[] opponentShots = new Shot[20]; // Array de tiros do adversário

private Item[] blueItems = new Item[2]; // Array de itens azuis
private Item[] redItems = new Item[2]; // Array de itens vermelhos
private Item[] greenItems = new Item[2]; // Array de itens verdes
private Item[] orangeItems = new Item[2]; // Array de itens laranjas

private boolean matchThreadStarted = false;

private Button loginButton;
private Button registerButton;
private Button continueButton;
private Button backButton;
private Button playButton;
private Button playAgainButton;
private Button top10Button;
private Button deleteButton;

private PImage menuBackground;
private PImage matchBackground;

private InputBox usernameBox;
private InputBox passwordBox;

private SoundFile battleTheme;

private char previousKey = ' ';
private String MatchResult;
private String CurrentTime;
private String top10;

void setup() {
    size(1000, 600); 
    background(1);
    currentState = State.MENU;

    menuBackground = loadImage("Images/menu.png");
    matchBackground = loadImage("Images/battle1.jpg");
    
    menuBackground.resize(width, height);
    matchBackground.resize(width, height);
    
    image(menuBackground, 0, 0);

    battleTheme = new SoundFile(this, "Sound/ducktales_moon_theme.wav");
    
    try {
        cm = new ConnectionManager("172.26.82.219", 1111); // Connect to the server
    } catch (Exception e) {
        println("Connection failed: " + e.getMessage());
    }
    
    // Initialize buttons
    registerButton = new Button("Images/register_default.png", "Images/register_hover.png", 0, 0);
    registerButton.updatePosition(width/2 - registerButton.width/2, height/2 - registerButton.height/2);
    
    loginButton = new Button("Images/login_default.png", "Images/login_hover.png", 0, 0);
    loginButton.updatePosition(width/2 - loginButton.width/2, height/2 + loginButton.height/2);
    
    deleteButton = new Button("Images/delete_default.png", "Images/delete_hover.png", 0, 0);
    deleteButton.updatePosition(width/2 - deleteButton.width/2, height/2 + deleteButton.height*1.5);
    
    backButton = new Button("Images/back_default.png", "Images/back_hover.png", 0, 0);
    backButton.updatePosition(0, backButton.height/2);

    continueButton = new Button("Images/continue_default.png", "Images/continue_hover.png", 0, 0);
    continueButton.updatePosition(width/2 - continueButton.width/2, height/2 + continueButton.height*1.5);
    
    playButton = new Button("Images/play_default.png", "Images/play_hover.png", 0, 0);
    playButton.updatePosition(width/2 - playButton.width/2, height/2 - playButton.height*2);    

    playAgainButton = new Button("Images/play_again_default.png", "Images/play_again_hover.png", 0, 0);
    playAgainButton.updatePosition(width/2 - playAgainButton.width/2, height/2 + playAgainButton.height*2);

    top10Button = new Button("Images/top10_default.png", "Images/top10_hover.png", 0, 0);
    top10Button.updatePosition(width/2 - top10Button.width/2, height/2 + top10Button.height/2);


    // Initialize input boxes
    usernameBox = new InputBox("Images/username_box.png", 0, 0);
    usernameBox.updatePosition(width/2 - usernameBox.width/2, height/2 - usernameBox.height);

    passwordBox = new InputBox("Images/password_box.png", 0, 0);
    passwordBox.updatePosition(width/2 - passwordBox.width/2, height/2);

    // Initialize shots
    for (int i = 0; i < playerShots.length; i++) {
    playerShots[i] = new Shot(); 
    opponentShots[i] = new Shot();
    }
    for (int i = 0; i < blueItems.length; i++) {
        blueItems[i] = new Item(0,0,255);
        redItems[i] = new Item(255,0,0);
        greenItems[i] = new Item(0,255,0); 
        orangeItems[i] = new Item(255,165,0); 
    }
}

void draw() {
    switch (currentState) {
        case MENU:
            image(menuBackground, 0, 0);
            loginButton.draw();
            registerButton.draw();
            deleteButton.draw();
            backButton.draw();
            break;
        case REGISTER:
            image(menuBackground, 0, 0);
            backButton.draw();
            usernameBox.draw();
            passwordBox.draw();
            continueButton.draw();
            break;
        case LOGIN:
            image(menuBackground, 0, 0);
            backButton.draw();
            usernameBox.draw();
            passwordBox.draw();
            continueButton.draw();            
            break;
        case DELETE_ACCOUNT:
            image(menuBackground, 0, 0);
            backButton.draw();
            usernameBox.draw();
            passwordBox.draw();
            continueButton.draw();
            break;
        case LOGGED:
            image(menuBackground, 0, 0);
            playButton.draw();
            backButton.draw();
            top10Button.draw();
            break;
        case LOBBY:
            image(menuBackground, 0, 0);
            fill(255);
            textSize(20);
            text("Waiting...", 480, 300);
            String response = this.cm.receiveMessage();
            if(response.equals("Match started")){
                currentState = State.PLAYING;
                battleTheme.play();
            }
            break;
        case PLAYING:       
            image(matchBackground, 0, 0);
            
            if (matchThreadStarted == false){
                matchThreadStarted = true;
                println("Starting parser thread...");
                thread("parser");
            }

            player.renderPlayer();
            opponent.renderPlayer();

            fill(255);
            textSize(20);
            text(player.getName() + ": " + player.getPoints() + " Points", 20, 30);
            text("Time: " + CurrentTime, 490, 30);
            text(opponent.getName() + ": " + opponent.getPoints() + " Points", 800, 30);

            for (int i = 0; i < playerShots.length; i++) {
                playerShots[i].renderShot();
                opponentShots[i].renderShot();
            }
    
            for (int i = 0; i < blueItems.length; i++) {
                blueItems[i].spawn();
                redItems[i].spawn();
                greenItems[i].spawn();
                orangeItems[i].spawn();
            }
            
            break;
        case MATCH_OVER:
            image(matchBackground, 0, 0);
            matchThreadStarted = false;
            textSize(50);
            fill(255);
            text(MatchResult, width/2 - textWidth(MatchResult)/2, height/2 - 50);
            playAgainButton.draw();
            backButton.draw();
            break;
        case TOP_10:
            image(menuBackground, 0, 0);
            backButton.draw();
            textSize(25);
            fill(255);
            text("Top 10 Players", width/2 - textWidth("Top 10 Players")/2, 150);
            text("Username       |Level|Sequence", 350, 170);
            text("|___________________________|", 340, 170);
            int y = 190;
            String[] parts = top10.split(","); // Top10,numplayers,username1,nivel1,sequencia1,username2...
            int numPlayers = Integer.parseInt(parts[1]);
            for (int i = 2; i < 2 + numPlayers * 3; i += 3) {
                String name = parts[i];
                int level = Integer.parseInt(parts[i + 1]);
                int sequence = Integer.parseInt(parts[i + 2]);
                text(name, 350, y);
                text("|" + level, 500, y);
                text("|" + sequence, 550, y);
                text("|___________________________|", 340, y);
                y += 20;
            }
            
            break;
    }
}

void mouseMoved() {
    if (currentState == State.MENU) {
        if (loginButton.isMouseOver()) {
            loginButton.changeToHover();
        } else {
            loginButton.changeToDefault();
        }
        if (registerButton.isMouseOver()) {
            registerButton.changeToHover();
        } else {
            registerButton.changeToDefault();
        }
        if (deleteButton.isMouseOver()) {
            deleteButton.changeToHover();
        } else {
            deleteButton.changeToDefault();
        }
        if (backButton.isMouseOver()) {
            backButton.changeToHover();
        } else {
            backButton.changeToDefault();
        }
    }
    if(currentState == State.REGISTER || currentState == State.LOGIN || currentState == State.DELETE_ACCOUNT) {
        if (continueButton.isMouseOver()) {
            continueButton.changeToHover();
        } else {
            continueButton.changeToDefault();
        }
        if (backButton.isMouseOver()) {
            backButton.changeToHover();
        } else {
            backButton.changeToDefault();
        }
    }
    if(currentState == State.LOGGED) {
        if (playButton.isMouseOver()) {
            playButton.changeToHover();
        } else {
            playButton.changeToDefault();
        }
        if (backButton.isMouseOver()) {
            backButton.changeToHover();
        } else {
            backButton.changeToDefault();
        }
        if (top10Button.isMouseOver()) {
            top10Button.changeToHover();
        } else {
            top10Button.changeToDefault();
        }
    }
    if(currentState == State.MATCH_OVER) {
        if (playAgainButton.isMouseOver()) {
            playAgainButton.changeToHover();
        } else {
            playAgainButton.changeToDefault();
        }
        if (backButton.isMouseOver()) {
            backButton.changeToHover();
        } else {
            backButton.changeToDefault();
        }
    }
    if(currentState == State.TOP_10) {
        if (backButton.isMouseOver()) {
            backButton.changeToHover();
        } else {
            backButton.changeToDefault();
        }
    }
}

void mousePressed() {
    if (currentState == State.MENU) {
        if (loginButton.isMouseOver() && mouseButton == LEFT) {
            currentState = State.LOGIN;
            loginButton.changeToDefault();

        } else if (registerButton.isMouseOver() && mouseButton == LEFT) {
            currentState = State.REGISTER;
            registerButton.changeToDefault();

        } else if (deleteButton.isMouseOver() && mouseButton == LEFT) {
            currentState = State.DELETE_ACCOUNT;
            deleteButton.changeToDefault();

        } else if (backButton.isMouseOver() && mouseButton == LEFT) {
            exit(); // Close the application
        }
    }
    else if(currentState == State.REGISTER || currentState == State.LOGIN || currentState == State.DELETE_ACCOUNT) {
        if (backButton.isMouseOver() && mouseButton == LEFT) {
            currentState = State.MENU;
            usernameBox.clearText();
            usernameBox.deselect();
            passwordBox.clearText();
            passwordBox.deselect();

        } else if (usernameBox.isMouseOver() && mouseButton == LEFT) {
            usernameBox.select();
            passwordBox.deselect();

        } else if (passwordBox.isMouseOver() && mouseButton == LEFT) {
            passwordBox.select();
            usernameBox.deselect();

        } else if(currentState == State.LOGIN && continueButton.isMouseOver() && mouseButton == LEFT) {
            
            cm.loginUser(usernameBox.getText(), passwordBox.getText());
            String response = this.cm.receiveMessage();
            println("Response: " + response);

            if (response.equals("Login successful")){
                player.setName(usernameBox.getText());
                currentState = State.LOGGED;
                continueButton.changeToDefault();
            }
            
            usernameBox.clearText();
            passwordBox.clearText();
            usernameBox.deselect();
            passwordBox.deselect();

        } else if(currentState == State.REGISTER && continueButton.isMouseOver() && mouseButton == LEFT) {

            cm.registerUser(usernameBox.getText(), passwordBox.getText());
            String response = this.cm.receiveMessage();
            println("Response: " + response);

            if (response.equals("Registration successful")){
                player.setName(usernameBox.getText());
                currentState = State.LOGGED;
                continueButton.changeToDefault();
            }
            
            usernameBox.clearText();
            passwordBox.clearText();
            usernameBox.deselect();
            passwordBox.deselect();
        } else if(currentState == State.DELETE_ACCOUNT && continueButton.isMouseOver() && mouseButton == LEFT) {
            
            cm.deleteUser(usernameBox.getText(), passwordBox.getText());
            String response = this.cm.receiveMessage();
            println("Response: " + response);

            if (response.equals("User deleted successfully")){
                currentState = State.MENU;
                continueButton.changeToDefault();
            }
            
            usernameBox.clearText();
            passwordBox.clearText();
            usernameBox.deselect();
            passwordBox.deselect();
        }
    }
    else if(currentState == State.LOGGED) {
        if (playButton.isMouseOver() && mouseButton == LEFT) {
            
            this.cm.joinLobby(player.getName());
            String response = this.cm.receiveMessage();
            if(response.equals("Join lobby successful")){
                currentState = State.LOBBY;
                playButton.changeToDefault();
            }

        } else if (backButton.isMouseOver() && mouseButton == LEFT) {
            currentState = State.MENU;
            
        } else if (top10Button.isMouseOver() && mouseButton == LEFT) {
            this.cm.getTop10();
            currentState = State.TOP_10;
            top10Button.changeToDefault();
            top10 = this.cm.receiveMessage();
        }
    }
    else if(currentState == State.PLAYING) {
        if (mouseButton == LEFT) {
            this.cm.sendShot(mouseX, mouseY);
        }
    }

    else if(currentState == State.MATCH_OVER) {
        if (playAgainButton.isMouseOver() && mouseButton == LEFT) {
            
            this.cm.joinLobby(player.getName());
            String response = this.cm.receiveMessage();
            if(response.equals("Join lobby successful")){
                playAgainButton.changeToDefault();
                currentState = State.LOBBY;
            }

        } else if (backButton.isMouseOver() && mouseButton == LEFT) {
            currentState = State.LOGGED;   
        }
    }

    else if(currentState == State.TOP_10) {
        if (backButton.isMouseOver() && mouseButton == LEFT) {
            currentState = State.LOGGED;
        }
    }
    
}

void parser(){
    // This function is called in a separate thread to parse messages from the server
    println("Parser thread started...");
    boolean game_going = true;
    while (game_going) {
        String message = this.cm.receiveMessage();
        println("Message: " + message);
        String[] parts = message.split(",");
        if (parts[0].equals("Players")){ // "Players,username1,x1,y1,points1,username2,x2,y2,points2"
            String name1 = parts[1];
            float x1 = Float.parseFloat(parts[2]);
            float y1 = Float.parseFloat(parts[3]);
            int points1 = Integer.parseInt(parts[4]);
            String name2 = parts[5];
            float x2 = Float.parseFloat(parts[6]);
            float y2 = Float.parseFloat(parts[7]);
            int points2 = Integer.parseInt(parts[8]);

            if (name1.equals(player.getName())){
                player.updatePlayer(name1, x1, y1, points1);
                opponent.updatePlayer(name2, x2, y2, points2);
            } else {
                opponent.updatePlayer(name1, x1, y1, points1);
                player.updatePlayer(name2, x2, y2, points2);
            }
        } else if(parts[0].equals("ShotsPlayer")){ // "ShotsPlayer,num de shots ex:2,x1,y1,x2,y2"
            int numShots = Integer.parseInt(parts[1]);
            int c = 0;
            for (int i = 2; i < 2 + numShots * 2; i += 2, c += 1) {
                float x = Float.parseFloat(parts[i]);
                float y = Float.parseFloat(parts[i + 1]);
                playerShots[c].updateShot(x, y);
                playerShots[c].activateShot();
            }
            while (c < playerShots.length) { // Deactivate remaining shots
                playerShots[c].deactivateShot();
                c++;
            }
        } else if(parts[0].equals("ShotsOpponent")){ // "ShotsOpponent,num de shots ex:2,x1,y1,x2,y2"
            int numShots = Integer.parseInt(parts[1]);
            int c = 0;
            for (int i = 2; i < 2 + numShots * 2; i += 2, c += 1) {
                float x = Float.parseFloat(parts[i]);
                float y = Float.parseFloat(parts[i + 1]);
                opponentShots[c].updateShot(x, y);
                opponentShots[c].activateShot();
            }
            while (c < opponentShots.length) { // Deactivate remaining shots
                opponentShots[c].deactivateShot();
                c++;
            }
        } else if(parts[0].equals("Time")){ // "Time,tempo_atual"
            CurrentTime = parts[1];
        } else if(parts[0].equals("Blue")){ // "Blue,x1,y1,x2,y2"
            int numItems = Integer.parseInt(parts[1]);
            int c = 0;
            for (int i = 2; i < 2 + numItems * 2; i += 2, c += 1) {
                float x = Float.parseFloat(parts[i]);
                float y = Float.parseFloat(parts[i + 1]);
                blueItems[c].setPosition(x, y);
                blueItems[c].activateItem();
            }
            while (c < blueItems.length) { // Deactivate remaining items
                blueItems[c].deactivateItem();
                c++;
            }

        } else if(parts[0].equals("Red")){ // "Red,x1,y1,x2,y2"
            int numItems = Integer.parseInt(parts[1]);
            int c = 0;
            for (int i = 2; i < 2 + numItems * 2; i += 2, c += 1) {
                float x = Float.parseFloat(parts[i]);
                float y = Float.parseFloat(parts[i + 1]);
                redItems[c].setPosition(x, y);
                redItems[c].activateItem();
            }
            while (c < redItems.length) { // Deactivate remaining items
                redItems[c].deactivateItem();
                c++;
            }
        } else if(parts[0].equals("Green")){ // "Green,x1,y1,x2,y2"
            int numItems = Integer.parseInt(parts[1]);
            int c = 0;
            for (int i = 2; i < 2 + numItems * 2; i += 2, c += 1) {
                float x = Float.parseFloat(parts[i]);
                float y = Float.parseFloat(parts[i + 1]);
                greenItems[c].setPosition(x, y);
                greenItems[c].activateItem();
            }
            while (c < greenItems.length) { // Deactivate remaining items
                greenItems[c].deactivateItem();
                c++;
            }
        } else if(parts[0].equals("Orange")){ // "Orange,x1,y1,x2,y2"
            int numItems = Integer.parseInt(parts[1]);
            int c = 0;
            for (int i = 2; i < 2 + numItems * 2; i += 2, c += 1) {
                float x = Float.parseFloat(parts[i]);
                float y = Float.parseFloat(parts[i + 1]);
                orangeItems[c].setPosition(x, y);
                orangeItems[c].activateItem();
            }
            while (c < orangeItems.length) { // Deactivate remaining items
                orangeItems[c].deactivateItem();
                c++;
            }
        } else if(message.equals("GameWon")){
            MatchResult = "You won!";
            game_going = false;
            currentState = State.MATCH_OVER;
        } else if(message.equals("GameLost")){
            MatchResult = "You lost!";
            game_going = false;
            currentState = State.MATCH_OVER;
        } else if(message.equals("GameDraw")){
            MatchResult = "It's a draw!";
            game_going = false;
            currentState = State.MATCH_OVER;
        }
    }
}


void keyPressed() {
    if (currentState == State.REGISTER || currentState == State.LOGIN || currentState == State.DELETE_ACCOUNT) {
        if (usernameBox.isSelected()) {
            usernameBox.receiveKey(key);
            usernameBox.draw(); // Redraw the input box to show the username
        } else if (passwordBox.isSelected()) {
            passwordBox.receiveKey(key);
            passwordBox.draw(); // Redraw the input box to show the password
        }
    } else if (currentState == State.PLAYING) {
        if (key != previousKey) { // Ignore repeated key presses
            this.cm.sendKeyPress(key); 
            previousKey = key;
        }
    }
}

void keyReleased() {
    if (currentState == State.PLAYING) {
        this.cm.sendKeyRelease(key);
        previousKey = ' '; // Reset previous key when released
    }
}
