//
//
import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; 

import processing.sound.*;
AudioSample sample;

QuasonTimbre qt;
float noiseval = 0.1;
float maxampl = 0.6;
float ampl = 0.3;
float freq = 440;
float timbr = 0;
float noisevar = 0.0;
float noiseampl = 0;
MidiBus myBus; 
int midiDevice  = 0;


void setup() {
  size(640, 360);
  background(255);

  MidiBus.list(); 
  myBus = new MidiBus(this, midiDevice, 1); 

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
  noiseval += noisevar;
  //qt.frequency(mouseY + 0.1* noise(noiseval));
  qt.amplitude(mousePressed ? maxampl * ampl : 0);
  //qt.frequency(map(mouseY, 0, 360, qt.notes[0], qt.notes[qt.notes.length-1]));
  qt.frequency(freq + 100*noiseampl * noise(noiseval));
  //qt.timbre(map( mouseX, 0, 640, 0, 1));
  qt.timbre(timbr);

  qt.tick();
  background(51);
  fill(200);
  circle(width/2, height/2, 100);

}

void midiMessage(MidiMessage message, long timestamp, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);

  // test.handleMidi(note, vel);
  // println("got midi: note: " + note);
  float scale = 1/128.0;
  if(note==81){
    freq = 50+scale*vel*2000;
    //ampl = scale*vel;
  }
  if(note==82){
    timbr = scale*vel;
  }
  if(note==83){
    ampl = scale*vel;
  }
  if(note==1) {
    noisevar = scale*vel;
  }
  if(note==2) {
    noiseampl = scale*vel;
  }
  
    

}
