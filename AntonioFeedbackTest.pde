// be sure to have trailing slash on path
final static String inputPath = "/Users/patrick/Desktop/inPNG/";

// be sure that the outPath directory is allready created
final static String outPath = "/Users/patrick/Desktop/outPNG/";

final static int iterations = 18;
final static float scale = 1.03;
final static float threshold = 0.5;

// set this to 0 if you want pixely-sharp edges
final static float thresholdSmooth = 0.01;

// only used to display image before saving it
final static int previewWidth = 1280;
final static int previewHeight = 720;

PShader program;

String[] files;
int fileCounter = 0;

PGraphics[] FBOs;
int fboPointer = 0;

void setup() {
 size(previewWidth, previewHeight, P3D);
 imageMode(CENTER);
  
 File dir =  new File(inputPath);
 files = dir.list();
 
 FBOs = new PGraphics[2];
 program = loadShader("tresh-invert.glsl");
 program.set("thresholdSmooth", thresholdSmooth);
 program.set("threshold", threshold);
}

void prepareFBOs(int w, int h) {
 boolean buildFBOs = true;
 
 // rebuild FBOs only if dimensions have changed
 if(FBOs[0] != null) {
  buildFBOs = buildFBOs && (FBOs[0].width == w);
  buildFBOs = buildFBOs && (FBOs[0].height == h);
 }
 if(buildFBOs) {
   for(int i = 0; i < 2; i++) {
     // initialize
   FBOs[i] = createGraphics(w, h, P3D);
   FBOs[i].beginDraw();
   FBOs[i].endDraw();
   }
 }
 
 // clear
 FBOs[0].clear();
 FBOs[1].clear();
}

void draw() {
  // background(0);
  if(fileCounter < files.length) {
    
    String file = files[fileCounter];
    
    // if it's not a PNG
    if(!file.toUpperCase().endsWith("PNG")) {
      fileCounter++;
      return;
    }
    
    println("Processing file: \"" + file + "\"");
    
    PImage img = loadImage(inputPath + file);
    prepareFBOs(img.width, img.height);

    for(int i = 0; i < iterations; i++) {
      PGraphics src = FBOs[fboPointer];
      PGraphics dst = FBOs[(fboPointer + 1) % 2];
      // clear Destination Framebuffer
      dst.clear();
      
      dst.beginDraw();
      dst.imageMode(CENTER);
      // draw scaled copy through shader
      dst.shader(program);

      dst.image(src, img.width/2, img.height/2, int(img.width*scale), int(img.height*scale));
      // draw original on top
      dst.resetShader();
      dst.image(img, img.width/2, img.height/2);
      dst.endDraw();
      
      fboPointer = (fboPointer + 1) % 2;
    }
    
    // display preview image
    image(FBOs[fboPointer], previewWidth/2, previewHeight/2, previewWidth, previewHeight); 
    FBOs[fboPointer].save(outPath + file);
    
    fileCounter++; 
  }
}
