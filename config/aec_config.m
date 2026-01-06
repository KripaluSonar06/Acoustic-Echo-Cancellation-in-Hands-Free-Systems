function cfg = aec_config()
% AEC configuration parameters for PBFDAF, DTD, and NLP subsystems

cfg.SAMPLE_RATE = 16000;
cfg.BLOCK_SIZE  = 256;
cfg.FFT_SIZE    = 512;
cfg.NUM_PARTITIONS = 16;

cfg.STEP_SIZE = 0.15;
cfg.EPSILON   = 1e-10;

cfg.DTD_COHERENCE_THRESHOLD = 0.3;
cfg.DTD_SMOOTHING_FACTOR    = 0.9;

cfg.NLP_AGGRESSIVENESS = 1.0;
cfg.NLP_MIN_GAIN_DB   = -25.0;
cfg.NLP_MIN_GAIN_LINEAR = 10^(cfg.NLP_MIN_GAIN_DB / 20);
cfg.NLP_MIN_GAIN = 0.15;


end
