import java.awt.Font;

float rotX = 0, rotY = 0, rotZ = 0;
float posX = 0, posY = 0, posZ = 0;
float zoom = 1.0;
boolean autoRoll = false;

boolean showTexture = true;
boolean enableLighting = true;
PFont font;

float lightX = 100, lightY = -100, lightZ = 100;
color lightColor = color(255, 255, 255);

int lastMouseX, lastMouseY;
boolean isDragging = false;

String text = "SALMAN";
float textDepth = 50;
float textSize = 100;

color[][] colorSchemes = {
  // Gold Luxury
  {color(255, 215, 0), color(184, 134, 11), color(120, 85, 0)},
  // Royal Blue
  {color(65, 105, 225), color(30, 60, 150), color(15, 30, 80)},
  // Emerald Green
  {color(46, 204, 113), color(22, 160, 85), color(12, 100, 50)},
  // Rose Gold
  {color(233, 150, 122), color(205, 92, 92), color(139, 69, 19)},
  // Purple Gradient
  {color(147, 112, 219), color(102, 51, 153), color(68, 34, 102)},
  // Cyan Elegant
  {color(0, 206, 209), color(0, 139, 139), color(0, 100, 100)},
  // Sunset Orange
  {color(255, 140, 0), color(255, 99, 71), color(178, 34, 34)},
  // Silver Metallic
  {color(192, 192, 192), color(128, 128, 128), color(105, 105, 105)},
  // Deep Teal
  {color(72, 201, 176), color(26, 188, 156), color(22, 160, 133)},
  // Magenta Fusion
  {color(199, 21, 133), color(142, 68, 173), color(155, 89, 182)}
};

int currentColorScheme = 0;
float colorTransition = 0;
boolean animateColors = false;

void setup() {
  size(1200, 800, P3D);

  try {
    font = createFont("michelin-bold.ttf", textSize);
    textFont(font);
  } catch (Exception e) {
    println("Using default font");
    textFont(createFont("Arial", textSize, true));
  }

  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void draw() {
  background(15, 20, 30);
  
  setupLighting();

  translate(width/2 + posX, height/2 + posY, posZ);
  scale(zoom);

  rotateX(rotX);
  rotateY(rotY);
  if (autoRoll) {
    rotateZ(millis() * 0.001 + rotZ);
  } else {
    rotateZ(rotZ);
  }

  if (animateColors) {
    colorTransition += 0.02;
    if (colorTransition >= 1.0) {
      colorTransition = 0;
      currentColorScheme = (currentColorScheme + 1) % colorSchemes.length;
    }
  }

  drawSmooth3DText();

  drawUI();
}

void setupLighting() {
  if (enableLighting) {
    ambientLight(25, 30, 40);

    directionalLight(red(lightColor), green(lightColor), blue(lightColor), 
                    lightX/150.0, lightY/150.0, lightZ/150.0);

    directionalLight(red(lightColor)*0.3, green(lightColor)*0.3, blue(lightColor)*0.3, 
                    -lightX/200.0, -lightY/200.0, -lightZ/200.0);

    specular(255);
    shininess(100);
  } else {
    noLights();
  }
}

void drawSmooth3DText() {
  textAlign(CENTER, CENTER);
  textSize(textSize);

  color[] colors = getCurrentColors();
  color frontColor = colors[0];
  color midColor = colors[1];
  color backColor = colors[2];
  
  strokeWeight(0.5);

  int layers = 50;
  
  for (int i = 0; i < layers; i++) {
    float t = (float)i / (layers - 1);
    float z = lerp(-textDepth/2, textDepth/2, t);
    
    pushMatrix();
    translate(0, 0, z);

    color layerColor;
    if (t < 0.5) {
      layerColor = lerpColor(backColor, midColor, t * 2);
    } else {
      layerColor = lerpColor(midColor, frontColor, (t - 0.5) * 2);
    }

    float scale = lerp(0.95, 1.0, t);
    scale(scale);

    float alpha = map(t, 0, 1, 180, 255);
    fill(red(layerColor), green(layerColor), blue(layerColor), alpha);
    
    if (showTexture) {
      stroke(red(layerColor)*0.7, green(layerColor)*0.7, blue(layerColor)*0.7, alpha*0.8);
    } else {
      noStroke();
    }
    
    text(text, 0, 0);
    popMatrix();
  }

  pushMatrix();
  translate(0, 0, textDepth/2 + 1);
  fill(frontColor);
  if (showTexture) {
    stroke(red(frontColor)*0.8, green(frontColor)*0.8, blue(frontColor)*0.8);
    strokeWeight(1);
  } else {
    noStroke();
  }
  text(text, 0, 0);
  popMatrix();

  pushMatrix();
  translate(0, 0, -textDepth/2 - 1);
  fill(backColor);
  if (showTexture) {
    stroke(red(backColor)*0.6, green(backColor)*0.6, blue(backColor)*0.6);
    strokeWeight(0.8);
  } else {
    noStroke();
  }
  text(text, 0, 0);
  popMatrix();
}

color[] getCurrentColors() {
  color[] currentColors = colorSchemes[currentColorScheme];
  
  if (animateColors && colorTransition > 0) {
    int nextScheme = (currentColorScheme + 1) % colorSchemes.length;
    color[] nextColors = colorSchemes[nextScheme];
    
    color[] blendedColors = new color[3];
    for (int i = 0; i < 3; i++) {
      blendedColors[i] = lerpColor(currentColors[i], nextColors[i], colorTransition);
    }
    return blendedColors;
  }
  
  return currentColors;
}

void drawUI() {
  camera();
  hint(DISABLE_DEPTH_TEST);

  fill(0, 0, 0, 100);
  noStroke();
  rect(0, 0, 350, height);

  fill(255, 255, 255, 220);
  textAlign(LEFT, TOP);
  textSize(11);
  
  String controls = 
    "═══ CONTROLS ═══\n" +
    "Mouse Drag: Rotate (Pitch/Yaw)\n" +
    "Mouse Wheel: Zoom In/Out\n" +
    "W/A/S/D: Move Object\n" +
    "Q/E: Forward/Backward\n" +
    "R: Toggle Auto Roll\n" +
    "T: Toggle Texture/Wireframe\n" +
    "L: Toggle Lighting\n" +
    "Arrow Keys: Move Light\n" +
    "C: Cycle Color Animation\n" +
    "1-9,0: Select Color Scheme\n" +
    "SPACE: Reset All\n\n" +
    
    "═══ STATUS ═══\n" +
    "Rotation: " + nf(degrees(rotX), 0, 1) + "°, " + nf(degrees(rotY), 0, 1) + "°\n" +
    "Position: " + nf(posX, 0, 0) + ", " + nf(posY, 0, 0) + ", " + nf(posZ, 0, 0) + "\n" +
    "Zoom: " + nf(zoom, 0, 2) + "x\n" +
    "Texture: " + (showTexture ? "ON" : "OFF") + "\n" +
    "Lighting: " + (enableLighting ? "ON" : "OFF") + "\n" +
    "Auto Roll: " + (autoRoll ? "ON" : "OFF") + "\n" +
    "Color Scheme: " + (currentColorScheme + 1) + "/10\n" +
    "Color Animation: " + (animateColors ? "ON" : "OFF");
    
  text(controls, 15, 15);

  drawColorPreview();
  
  hint(ENABLE_DEPTH_TEST);
  textSize(textSize);
}

void drawColorPreview() {
  float startX = 15;
  float startY = height - 60;
  float boxSize = 25;
  
  fill(255, 255, 255, 150);
  textSize(10);
  text("Color Schemes:", startX, startY - 15);
  
  for (int i = 0; i < min(10, colorSchemes.length); i++) {
    float x = startX + (i % 5) * (boxSize + 5);
    float y = startY + (i / 5) * (boxSize + 5);

    color[] scheme = colorSchemes[i];

    fill(scheme[2]);
    if (i == currentColorScheme) {
      strokeWeight(2);
      stroke(255, 255, 255);
    } else {
      strokeWeight(1);
      stroke(100);
    }
    rect(x, y, boxSize, boxSize);

    for (int j = 0; j < boxSize; j++) {
      float t = (float)j / boxSize;
      color c = lerpColor(scheme[2], scheme[0], t);
      stroke(c);
      line(x + j, y, x + j, y + boxSize);
    }

    fill(255);
    textAlign(CENTER, CENTER);
    text(str((i + 1) % 10), x + boxSize/2, y + boxSize/2);
  }
  
  textAlign(LEFT, TOP);
}

void mousePressed() {
  isDragging = true;
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseReleased() {
  isDragging = false;
}

void mouseDragged() {
  if (isDragging) {
    rotY += (mouseX - lastMouseX) * 0.01;
    rotX += (mouseY - lastMouseY) * 0.01;
    
    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }
}

void mouseWheel(MouseEvent event) {
  zoom += event.getCount() * -0.1;
  zoom = constrain(zoom, 0.2, 3.0);
}

void keyPressed() {
  switch (key) {
    case 'w':
    case 'W':
      posY -= 15;
      break;
    case 's':
    case 'S':
      posY += 15;
      break;
    case 'a':
    case 'A':
      posX -= 15;
      break;
    case 'd':
    case 'D':
      posX += 15;
      break;
    case 'q':
    case 'Q':
      posZ -= 15;
      break;
    case 'e':
    case 'E':
      posZ += 15;
      break;

    case 'r':
    case 'R':
      autoRoll = !autoRoll;
      break;
    case 't':
    case 'T':
      showTexture = !showTexture;
      break;
    case 'l':
    case 'L':
      enableLighting = !enableLighting;
      break;
    case 'c':
    case 'C':
      animateColors = !animateColors;
      if (!animateColors) colorTransition = 0;
      break;
      
    // Reset
    case ' ':
      resetTransforms();
      break;

    case '1': case '2': case '3': case '4': case '5':
    case '6': case '7': case '8': case '9':
      currentColorScheme = int(key) - 49; // Convert '1'-'9' to 0-8
      animateColors = false;
      colorTransition = 0;
      break;
    case '0':
      currentColorScheme = 9;
      animateColors = false;
      colorTransition = 0;
      break;
  }

  if (key == CODED) {
    switch (keyCode) {
      case UP:
        lightY -= 25;
        break;
      case DOWN:
        lightY += 25;
        break;
      case LEFT:
        lightX -= 25;
        break;
      case RIGHT:
        lightX += 25;
        break;
    }
  }
}

void resetTransforms() {
  rotX = rotY = rotZ = 0;
  posX = posY = posZ = 0;
  zoom = 1.0;
  lightX = 100;
  lightY = -100;
  lightZ = 100;
  autoRoll = false;
  animateColors = false;
  colorTransition = 0;
  currentColorScheme = 0;
}
