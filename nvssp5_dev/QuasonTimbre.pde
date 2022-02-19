class QuasonTimbre {
    /** Synth based on description in 
        Luengo et al 2016

    */

    float f0 = 440; //
    float ampl = 0;
    QuasonTimbre() {

    }

    void frequency(float f) {
        f0 = f;
    }

    void amplitude(float a) {
        ampl = a;
    }

    void tick() {

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

}