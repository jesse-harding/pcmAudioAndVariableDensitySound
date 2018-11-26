//this version will code different colors to different depths and will export pdf

//THIS CODE WILL EXPORT, ADJUST GAIN, DOWNSAMPLE, AND ALTER BIT DEPTH OF SAMPLES OF AN IMPORTED AUDIO FILE AND RETURN DATA TO AN ARRAY

//todo:
//  pre-filter audio to exclude high frequencies
//  do tests with speed and power on laser cutter
//  add control for printer dpi, desired size / "tape speed"
//  add selector for render type (optical (variable density, variable area), tactile (depthmap or vector), phonograph

import processing.sound.*;
import processing.pdf.*;

float rate = 1;
SoundFile file;
AudioSample sample;
int bitDepth= 4;
int audioDepth = int(pow(2, bitDepth));
float gain = 4; //set to 0 for maximum gain without clipping
PGraphics pg;
PImage pg2;
int printerDPI = 4; //to be edited based on printer and results
int printerSize = 12;

int inputSampleRate;
int outputSampleRate = 4410; //works best as factor of original samplerate (probably 44.1 kHz)
//add variable output sample rate for making a phonograph record (non needed for optical or talkie tape)

void setup() {
  noSmooth();
  size(100, 100);
  background(255);
  float maxFrame = 0;
  float minFrame = 0;
  float absMaxFrame = 0;
  strokeWeight(0.001);
  file = new SoundFile(this, "Test.aiff");
  inputSampleRate = file.sampleRate();
  float downsampleRatio = (float(inputSampleRate)/float(outputSampleRate));

  float[] inputFrameArray = new float[file.frames()];
  float[] outputFrameArray = new float[int(floor((float(outputSampleRate)/float(inputSampleRate))*file.frames()))];
  file.read(0, inputFrameArray, 0, file.frames());
  background(255);

  pg = createGraphics(outputFrameArray.length, 600, PDF, "test.pdf");
  //pg = createGraphics(printerDPI * printerSize, 100);

  for (int i = 0; i < outputFrameArray.length; i++) {
    if (int(floor(i * downsampleRatio)) < inputFrameArray.length && i < outputFrameArray.length) {
      outputFrameArray[i] = inputFrameArray[int(floor(i * downsampleRatio))];
      if (abs(outputFrameArray[i]) > absMaxFrame) {
        absMaxFrame = abs(outputFrameArray[i]);
      }
      if (outputFrameArray[i] > maxFrame) {
        maxFrame = outputFrameArray[i];
      }
      if (outputFrameArray[i] < minFrame) {
        minFrame = outputFrameArray[i];
      }
    }
  }
  pg.beginDraw();
  for (int i = 0; i < outputFrameArray.length; i++) {
    if (gain == 0) {
      outputFrameArray[i] = outputFrameArray[i]/absMaxFrame; //set to maximum gain without clipping
    } else {
      outputFrameArray[i] = outputFrameArray[i]*gain; //dynamic control for gain here
    }

    if (outputFrameArray[i] > 1) { //constrain to range for clipping
      outputFrameArray[i] = 1;
    }
    if (outputFrameArray[i] < -1) {
      outputFrameArray[i] = -1;
    }

    int tempVal = int(map(outputFrameArray[i], -1, 1, audioDepth-1, 0)); //convert range to bitdepth

    outputFrameArray[i] = map(tempVal, 0, audioDepth-1, -1, 1); //convert bitdepth to audio range

    //println(audioDepth-1);
    pg.stroke(int(map(tempVal, 0, audioDepth-1, 0, 255)), 128, 128); //draw variable density to screen
    pg.line(i, 0, i, pg.height);
  } 
  for (int i=0; i<audioDepth; i++){
    println(int(map(i, 0, audioDepth-1, 0, 255)));
  }
  //pg.(printerDPI * printerSize, 100);
  pg.dispose();
  pg.endDraw();
  //pg2 = pg.get(0, 0, pg.width, pg.height);
  //pg2.resize(printerDPI * printerSize, 100);
  //image(pg, 0, 0);
  //pg.save("export.tif");
  sample = new AudioSample(this, outputFrameArray, outputSampleRate); //generate preview audio
  sample.amp(1);
  sample.loop();
  //println(outputFrameArray.length);
}

void draw() {
}
