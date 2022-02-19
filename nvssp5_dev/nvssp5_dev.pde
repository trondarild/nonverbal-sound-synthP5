//
//

import processing.sound.*;
AudioSample sample;

void setup() {
  size(640, 360);
  background(255);

  // Create an array and manually write a single sine wave oscillation into it.
  int f0 = 550;
  int resolution = 2*f0; // must be at least Nyquist rate: 2*frequency
  float[] sinewave = new float[resolution];
  for (int i = 0; i < resolution; i++) {
    // sinewave[i] = sin(TWO_PI*i/resolution);
    sinewave[i] = cute_wave(TWO_PI*i/resolution, float(f0));
  }

  // Create the audiosample based on the data, set framerate to play 200 oscillations/second
  sample = new AudioSample(this, sinewave, resolution);

  // Play the sample in a loop (but don't make it too loud)
  sample.amp(0.4);
  sample.loop();
  
}      

void draw(){
  background(51);
  fill(200);
  circle(width/2, height/2, 100);

}

/*
\begin{equation} wave(t) = \sum _{n=0}^{6}(-1)^{n} 0.2 \cos (n f_{0} t) \end{equation}
*/
float cute_wave(float t, float f0) {
  float retval = 0;
  for (int i = 0; i < 6; ++i) {
    retval += pow(-1, i) * 0.2 * cos(i * f0 * t);
  }
  return retval;
}
