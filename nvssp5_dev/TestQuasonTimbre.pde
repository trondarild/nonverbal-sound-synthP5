class TestQuasonTimbre {
    QuasonTimbre synth = new QuasonTimbre();

    TestQuasonTimbre() {

    }

    void tick() {
        // set freq, ampl, timbre
        synth.tick();
    }

    void draw() {
        synth.draw();
    }
}