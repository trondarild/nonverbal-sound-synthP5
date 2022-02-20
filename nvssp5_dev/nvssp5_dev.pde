//
//

import processing.sound.*;
AudioSample sample;

QuasonTimbre qt;
float noiseval = 0.1;
void setup() {
  size(640, 360);
  background(255);

  // HearSpectralFilter hsf = new HearSpectralFilter();
  // try {
  //   hsf.test();
  // } catch (IOException e) {
  //     // TODO Auto-generated catch block
  //     e.printStackTrace();
  // }
  qt = new QuasonTimbre();
}      

void draw(){
  noiseval += 0.025;
  //qt.frequency(mouseY + 0.1* noise(noiseval));
  qt.frequency(map(mouseY, 0, 360, qt.notes[0], qt.notes[qt.notes.length-1]));
  qt.timbre(map( mouseX, 0, 640, 0, 1));

  qt.tick();
  background(51);
  fill(200);
  circle(width/2, height/2, 100);

}
