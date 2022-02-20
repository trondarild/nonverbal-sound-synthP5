import com.jsyn.unitgen.SawtoothOscillatorBL;
import com.jsyn.unitgen.SineOscillator;
import com.jsyn.unitgen.TriangleOscillator;
import com.jsyn.unitgen.FunctionOscillator;
import com.jsyn.unitgen.PinkNoise;
import com.jsyn.ports.UnitInputPort;
import com.jsyn.data.Function;
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
    UnitOscillator cut;
    UnitOscillator ggl;
    PassThrough mixer;
    SpectralFilter filter;
    LineOut lineOut;
    PinkNoise pinknoise;
    

    final int SAMPLE_RATE = 44100;

    float[] sine_lt = {0.80,0.80,0.80,0.79,0.79,0.79,0.79,0.79,0.79,0.78,0.78,0.78,0.77,0.76,0.76,0.76,0.76,0.75,0.75,0.74,0.73,0.73,0.72,0.72,0.71000004,0.7,0.7,0.7,0.69,0.69,0.68,0.69,0.69,0.69,0.68,0.68,0.68,0.66999996,0.66999996,0.65999997,0.65999997,0.65999997,0.65,0.65,0.65,0.65,0.64,0.64,0.63,0.62,0.57,0.56,0.53999996,0.52,0.48000002,0.45999998,0.45,0.43,0.42000002,0.39999998,0.3,0.29000002,0.27999997,0.26999998,0.26,0.24000001,0.23000002,0.22000003,0.20999998,0.19999999,0.19999999,0.19999999,0.19,0.19,0.19,0.19,0.19,0.18,0.18,0.17000002,0.16000003,0.14999998,0.13999999,0.13,0.120000005,0.110000014,0.100000024,0.089999974,0.089999974,0.089999974,0.089999974,0.07999998,0.06999999,0.06999999,0.06999999,0.06999999,0.06999999,0.06999999,0.060000002,0.060000002};
    float[] saw_lt = {0.0,0.0,0.110000014,0.100000024,0.110000014,0.120000005,0.13999999,0.14999998,0.22000003,0.23000002,0.24000001,0.27999997,0.29000002,0.3,0.31,0.32,0.32,0.32999998,0.33999997,0.35000002,0.36,0.38,0.41000003,0.43,0.45999998,0.47000003,0.48000002,0.52,0.53999996,0.56,0.58000004,0.61,0.63,0.65,0.66999996,0.66999996,0.69,0.71000004,0.71000004,0.72,0.72,0.73,0.73,0.73,0.74,0.74,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.76,0.76,0.76,0.76,0.76,0.76,0.75,0.74,0.74,0.73,0.73,0.72,0.71000004,0.71000004,0.71000004,0.7,0.69,0.63,0.62,0.47000003,0.45,0.43,0.42000002,0.42000002,0.37,0.35000002,0.3,0.27999997,0.26999998,0.25,0.23000002,0.22000003,0.20999998,0.20999998,0.19999999,0.19,0.17000002,0.13,0.120000005,0.110000014,0.100000024,0.100000024,0.100000024,0.089999974,0.089999974,0.07999998,0.06999999};
    float[] noise_lt = {0.0,0.0,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.12000003,0.23000002,0.24000001,0.27999997,0.27999997,0.29000002,0.29000002,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.31,0.31,0.31,0.31,0.31,0.31,0.3,0.31,0.31,0.31,0.32,0.32,0.32999998,0.32999998,0.32999998,0.33999997,0.33999997,0.33999997,0.33999997,0.33999997,0.35000002,0.36,0.38,0.39999998,0.39999998,0.41000003,0.45999998,0.48000002,0.5,0.51,0.52,0.53,0.56,0.58000004,0.59000003,0.62,0.63,0.64,0.65,0.66999996,0.68,0.72,0.72,0.73,0.74,0.77,0.79,0.81,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.82,0.81,0.55,0.53999996,0.52,0.65000002,0.65999998,0.6632,0.6631,0.6631,0.673,};
    float[] notes = {261.63,
                    277.18,
                    293.66,
                    311.13,
                    329.63,
                    349.23,
                    369.99,
                    392.00,
                    415.30,
                    440.00,
                    466.16,
                    493.88};

    QuasonTimbre() {
        init();
    }

    QuasonTimbre(String name){
        this.name = name;
        init();
    }

    void init() {
        noise_lt = multiply(0.5, noise_lt);

        synth = JSyn.createSynthesizer();
        synth.setRealTime(true);

        //synth.add(center = new PassThrough());
        synth.add(sin = new SineOscillator());
        //synth.add(cut = new CuteOscillator());
        synth.add(cut = new CuteOscillator());
        synth.add(tri = new TriangleOscillator());
        synth.add(saw = new SawtoothOscillatorBL());
        synth.add(ggl = new GoogleWaveOscillator());
        synth.add(pinknoise = new PinkNoise());
        synth.add(mixer = new PassThrough());

        
        // synth.add(filter = new SpectralFilter(NUM_FFTS, SIZE_LOG_2));
        // Add a stereo audio output unit.
        synth.add(lineOut = new LineOut());

        //center.output.connect(saw.frequency);
        sin.output.connect(mixer.input);
        //tri.output.connect(mixer.input);
        cut.output.connect(mixer.input);
        saw.output.connect(mixer.input);
        //ggl.output.connect(mixer.input);
        //pinknoise.output.connect(mixer.input);
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
        float f = lookup_discrete(f0, notes);
        sin.frequency.set(f);
        cut.frequency.set(f);
        tri.frequency.set(f);
        saw.frequency.set(f);
        ggl.frequency.set(f);
        // TODO use lookup tables with gain functions 
        // from timbre here
        sin.amplitude.set(lookup(timbre, sine_lt) * ampl);
        cut.amplitude.set(lookup(timbre, saw_lt) * ampl);
        tri.amplitude.set(lookup(timbre, saw_lt) * ampl);
        saw.amplitude.set(lookup(timbre, noise_lt) * ampl);
        ggl.amplitude.set(lookup(timbre, noise_lt) * ampl);
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

    

    float lookup(float val, float[] table) {
        int ix = min(int(100*val), table.length - 1);
        return table[ix];
    }

    float lookup_discrete(float val, float[] table){
        if(val < table[0]) return table[0];
        else if(val > table[table.length-1]) return table[table.length-1];
        for (int i = 0; i < table.length-1; ++i) {
            if(val >= table[i] && val < table[i+1]) return table[i];
            
        }
        return 0;
    }
}

class GoogleWaveOscillator extends UnitOscillator {
    public UnitInputPort variance;
    private double phaseIncrement = 0.1;
    private double previousY;
    private double randomAmplitude = 0.0;

    public GoogleWaveOscillator() {
        addPort(variance = new UnitInputPort("Variance", 0.1));
    }

    @Override
    public void generate(int start, int limit) {
        // Get signal arrays from ports.
        double[] freqs = frequency.getValues();
        double[] outputs = output.getValues();
        double currentPhase = phase.getValue();
        double y;

        for (int i = start; i < limit; i++) {
            if (currentPhase > 0.0) {
                y = Math.sqrt(4.0 * (currentPhase * (1.0 - currentPhase)));
            } else {
                double p = -currentPhase;
                y = -Math.sqrt(4.0 * (p * (1.0 - p)));
            }

            if ((previousY * y) <= 0.0) {
                // Calculate randomly offset phaseIncrement.
                double v = variance.getValues()[0];
                double range = ((Math.random() - 0.5) * 4.0 * v);
                double scale = Math.pow(2.0, range);
                phaseIncrement = convertFrequencyToPhaseIncrement(freqs[i]) * scale;

                // Calculate random amplitude.
                scale = 1.0 + ((Math.random() - 0.5) * 1.5 * v);
                randomAmplitude = amplitude.getValues()[0] * scale;
            }

            outputs[i] = y * randomAmplitude;
            previousY = y;

            currentPhase = incrementWrapPhase(currentPhase, phaseIncrement);
        }
        phase.setValue(currentPhase);
    }
}

class CuteOscillator extends UnitOscillator {

    CuteOscillator() {}

    @Override
    public void generate(int start, int limit) {
        double[] frequencies = frequency.getValues(); // TODO
        double[] outputs = output.getValues();
        double[] amplitudes = amplitude.getValues();
         // Variables have a single value.
        double currentPhase = phase.getValue();
        for (int i = start; i < limit; i++) {
            
            double phaseIncrement = convertFrequencyToPhaseIncrement(frequencies[i]);
            currentPhase = incrementWrapPhase(currentPhase, phaseIncrement);
            double value = cute_wave(currentPhase);
            outputs[i] = value * amplitudes[i];

        }
        // Value needs to be saved for next time.
        phase.setValue(currentPhase);
    }

    /*
    public void generate(int start, int limit) {
        double[] frequencies = frequency.getValues();
        double[] amplitudes = amplitude.getValues();
        double[] outputs = output.getValues();

        Function functionObject = function.get();

        // Variables have a single value.
        double currentPhase = phase.getValue();

        for (int i = start; i < limit; i++) {
            // Generate sawtooth phasor to provide phase for function lookup.
            double phaseIncrement = convertFrequencyToPhaseIncrement(frequencies[i]);
            currentPhase = incrementWrapPhase(currentPhase, phaseIncrement);
            double value = functionObject.evaluate(currentPhase);
            outputs[i] = value * amplitudes[i];
        }

        // Value needs to be saved for next time.
        phase.setValue(currentPhase);
    }
    */

    
    double cute_wave(double t) {
        double retval = 0;
        for (int i = 0; i < 6; ++i) {
            retval += pow(-1, i) * 0.2 * cos(i * (float) t);
        }
        return retval;
    }
}
