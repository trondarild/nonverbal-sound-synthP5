import com.jsyn.unitgen.SawtoothOscillatorBL;
import com.jsyn.unitgen.SineOscillator;
import com.jsyn.unitgen.TriangleOscillator;
import com.jsyn.unitgen.PinkNoise;
class QuasonTimbre {
    /** Synth based on description in 
        Luengo et al 2016

        2022-02-19:
            * add sinusoid oscillator
            * add "cute" osc.
            * add sawtooth osc.
            * add noise osc
    */

    String name = "QuasonTimbre";
    String info;

    float f0 = 440; //
    float ampl = 0.3; // amplitude
    float timbre = 0.3; // 0..1 - mixture of oscillators from sine to noise

    Synthesizer synth;
    PassThrough center;
    UnitOscillator saw; // sawtooth
    UnitOscillator sin;
    UnitOscillator tri;
    PassThrough mixer;
    SpectralFilter filter;
    LineOut lineOut;
    PinkNoise pinknoise;
    

    final int SAMPLE_RATE = 44100;

    float[] sine_lt = {0.80,0.80,0.80,0.79,0.79,0.79,0.79,0.79,0.79,0.78,0.78,0.78,0.77,0.76,0.76,0.76,0.76,0.75,0.75,0.74,0.73,0.73,0.72,0.72,0.71000004,0.7,0.7,0.7,0.69,0.69,0.68,0.69,0.69,0.69,0.68,0.68,0.68,0.66999996,0.66999996,0.65999997,0.65999997,0.65999997,0.65,0.65,0.65,0.65,0.64,0.64,0.63,0.62,0.57,0.56,0.53999996,0.52,0.48000002,0.45999998,0.45,0.43,0.42000002,0.39999998,0.3,0.29000002,0.27999997,0.26999998,0.26,0.24000001,0.23000002,0.22000003,0.20999998,0.19999999,0.19999999,0.19999999,0.19,0.19,0.19,0.19,0.19,0.18,0.18,0.17000002,0.16000003,0.14999998,0.13999999,0.13,0.120000005,0.110000014,0.100000024,0.089999974,0.089999974,0.089999974,0.089999974,0.07999998,0.06999999,0.06999999,0.06999999,0.06999999,0.06999999,0.06999999,0.060000002,0.060000002};
    float[] saw_lt = {0.0,0.0,0.110000014,0.100000024,0.110000014,0.120000005,0.13999999,0.14999998,0.22000003,0.23000002,0.24000001,0.27999997,0.29000002,0.3,0.31,0.32,0.32,0.32999998,0.33999997,0.35000002,0.36,0.38,0.41000003,0.43,0.45999998,0.47000003,0.48000002,0.52,0.53999996,0.56,0.58000004,0.61,0.63,0.65,0.66999996,0.66999996,0.69,0.71000004,0.71000004,0.72,0.72,0.73,0.73,0.73,0.74,0.74,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.76,0.76,0.76,0.76,0.76,0.76,0.75,0.74,0.74,0.73,0.73,0.72,0.71000004,0.71000004,0.71000004,0.7,0.69,0.63,0.62,0.47000003,0.45,0.43,0.42000002,0.42000002,0.37,0.35000002,0.3,0.27999997,0.26999998,0.25,0.23000002,0.22000003,0.20999998,0.20999998,0.19999999,0.19,0.17000002,0.13,0.120000005,0.110000014,0.100000024,0.100000024,0.100000024,0.089999974,0.089999974,0.07999998,0.06999999};
    float[] noise_lt = {0.0,0.0,0.17000002,0.16000003,0.17000002,0.18,0.18,0.19,0.19999999,0.19999999,0.19999999,0.19999999,0.20999998,0.22000003,0.23000002,0.24000001,0.27999997,0.27999997,0.29000002,0.29000002,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.31,0.31,0.31,0.31,0.31,0.31,0.3,0.31,0.31,0.31,0.32,0.32,0.32999998,0.32999998,0.32999998,0.33999997,0.33999997,0.33999997,0.33999997,0.33999997,0.35000002,0.36,0.38,0.39999998,0.39999998,0.41000003,0.45999998,0.48000002,0.5,0.51,0.52,0.53,0.56,0.58000004,0.59000003,0.62,0.63,0.64,0.65,0.66999996,0.68,0.72,0.72,0.73,0.74,0.77,0.79,0.81,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.81,0.55,0.53999996,0.52,0.35000002,0.32999998,0.32,0.31,0.31,0.3,};

    QuasonTimbre() {
        init();
    }

    QuasonTimbre(String name){
        this.name = name;
        init();
    }

    void init() {
        noise_lt = multiply(0.1, noise_lt);

        synth = JSyn.createSynthesizer();
        synth.setRealTime(true);

        //synth.add(center = new PassThrough());
        synth.add(sin = new SineOscillator());
        synth.add(tri = new TriangleOscillator());
        synth.add(saw = new SawtoothOscillatorBL());
        synth.add(pinknoise = new PinkNoise());
        synth.add(mixer = new PassThrough());

        // synth.add( osc = new SineOscillator() );

        // synth.add(filter = new SpectralFilter(NUM_FFTS, SIZE_LOG_2));
        // Add a stereo audio output unit.
        synth.add(lineOut = new LineOut());

        //center.output.connect(saw.frequency);
        sin.output.connect(mixer.input);
        tri.output.connect(mixer.input);
        //saw.output.connect(mixer.input);
        pinknoise.output.connect(mixer.input);
        //mixer.output.connect(filter.input);
        mixer.output.connect(0, lineOut.input, 0);
        mixer.output.connect(0, lineOut.input, 1);

        synth.start(SAMPLE_RATE);
        lineOut.start();

    }

    void frequency(float f) {
        f0 = f;
    }

    void amplitude(float a) {
        ampl = a;
    }

    void timbre(float tm) {
        timbre = tm;
    }

    void stop() {
        synth.stop();
    }

    float[] output() {
        float[] retval = zeros(1);
        return retval;
    }

    String info() {
        return info;
    }

    void tick() {
        sin.frequency.set(f0);
        tri.frequency.set(f0);
        saw.frequency.set(f0);
        // TODO use lookup tables with gain functions 
        // from timbre here
        sin.amplitude.set(lookup(timbre, sine_lt) * ampl);
        tri.amplitude.set(lookup(timbre, saw_lt) * ampl);
        saw.amplitude.set(lookup(timbre, saw_lt) * ampl);
        pinknoise.amplitude.set(lookup(timbre, noise_lt) * ampl);
        // try {
        //     double time = synth.getCurrentTime();
        //     // Sleep for a few seconds.
        //     synth.sleepUntil(time + 10.0);
        // } catch (InterruptedException e) {
        //     e.printStackTrace();
        // }
        
    }
    
    void draw() {

    }

    float cute_wave(float t, float f0) {
        float retval = 0;
        for (int i = 0; i < 6; ++i) {
            retval += pow(-1, i) * 0.2 * cos(i * f0 * t);
        }
        return retval;
    }

    float lookup(float val, float[] table) {
        int ix = min(int(100*val), table.length - 1);
        return table[ix];
    }
}
