# 🎧 Acoustic Echo Cancellation using PBFDAF (DSP-Based)

A **classical Digital Signal Processing (DSP)** implementation of an **Acoustic Echo Cancellation (AEC)** system using **Partitioned Block Frequency Domain Adaptive Filtering (PBFDAF)** with **NLMS adaptation**, **double-talk detection**, and **frequency-domain residual echo suppression**.

This project is implemented **without machine learning or pretrained models**, focusing purely on adaptive signal processing principles and real-time feasibility.

---

## 📌 Key Features

* ✅ Partitioned Block Frequency Domain Adaptive Filter (PBFDAF)
* ✅ NLMS-based adaptive weight update
* ✅ Overlap-Save FFT block processing
* ✅ Coherence-based Double-Talk Detection (DTD)
* ✅ Energy-based DTD (fallback)
* ✅ Frequency-domain Non-Linear Post-Processing (NLP)
* ✅ Temporal gain smoothing to reduce musical noise
* ✅ Quantitative evaluation using ERLE (Echo Return Loss Enhancement)
* ✅ MATLAB implementation suitable for real-time and embedded extension

---

## 🧠 System Overview

The microphone signal contains:

* Far-end echo from the loudspeaker
* Near-end speech
* Background noise

The AEC system adaptively estimates the acoustic echo path and subtracts the estimated echo from the microphone signal, while safely handling **double-talk** scenarios and suppressing **residual echo artifacts**.

---

## 📁 Project Structure

```
AEC_Project/
│
├── main.m                     # Main AEC pipeline
├── aec_config.m               # Configuration parameters
│
├── core/
│   ├── OverlapSave.m          # Overlap-save buffering
│   ├── PBFDAF.m               # Partitioned frequency-domain filter
│   └── pbfda_nlms_update.m    # NLMS weight update
│
├── dtd/
│   ├── CoherenceDTD.m         # Coherence-based double-talk detector
│   └── EnergyDTD.m            # Energy-based double-talk detector
│
├── nlp/
│   ├── residual_nlp.m         # Residual echo suppression (NLP)
│   └── GainSmoother.m         # Temporal gain smoothing
│
├── metrics/
│   └── compute_erle.m         # ERLE computation
│
├── simulation/
│   ├── generate_test_signals.m# Test signal generation
│   ├── pre_emphasis.m         # Pre-emphasis filter
│   └── speech_farend.wav      # Far-end reference audio (16 kHz)
│
└── report/
    └── aec_report.tex         # 5-page DSP report (LaTeX)
```

---

## ⚙️ Requirements

* MATLAB R2020a or later (earlier versions may also work)
* No additional toolboxes required (base MATLAB functions only)

---

## ▶️ How to Run

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/AEC-PBFDAF.git
   cd AEC-PBFDAF
   ```

2. Open MATLAB and add project folders to path:

   ```matlab
   addpath(genpath(pwd))
   ```

3. Run the main script:

   ```matlab
   main
   ```

4. The script will:

   * Generate test signals
   * Perform acoustic echo cancellation
   * Apply double-talk detection and NLP
   * Print ERLE and performance statistics

---

## 📊 Performance Metric

Echo suppression performance is evaluated using **Echo Return Loss Enhancement (ERLE)**:

[
\text{ERLE (dB)} = 10 \log_{10}\left( \frac{E[y^2(n)]}{E[e^2(n)]} \right)
]

ERLE is computed only during **steady-state**, excluding:

* Initial convergence phase
* Silent far-end segments

---

## 📄 Report

A detailed **5-page technical report** is provided in `report/aec_report.tex`, covering:

* Signal model
* System architecture
* Adaptive filtering theory
* Double-talk detection
* Residual echo suppression
* Experimental evaluation

---

## 🚫 What This Project Does *Not* Use

* ❌ Machine learning models
* ❌ Neural networks
* ❌ Pretrained AI libraries
* ❌ Black-box DSP components

This is a **fully interpretable, classical DSP solution**.

---

## 🚀 Future Extensions

* Real-time implementation on ESP32 or DSP hardware
* Adaptive step-size scheduling
* Perceptual post-filters
* Live microphone + speaker demo

---

## 📜 License

This project is released for **educational and research purposes**.
You are free to modify and extend it with proper attribution.

---

## 🙌 Acknowledgements

Inspired by classical acoustic echo cancellation literature and adaptive filtering techniques used in hands-free communication systems.

---

