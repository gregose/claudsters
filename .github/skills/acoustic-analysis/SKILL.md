---
name: acoustic-analysis
description: Speaker engineering calculator for the SpeedsterAI enclosure. Use this skill whenever the user asks about port tuning, Helmholtz resonance, box volume effects, baffle step frequency, diffraction thresholds, or the acoustic impact of any parameter change. Also trigger when the user asks "what happens to tuning if...", "how does this affect the sound", "what's the port frequency", or any question about speaker physics, acoustics, or how enclosure dimensions relate to sound quality. Use for any quantitative acoustic question about this speaker design.
---

# Acoustic Analysis — SpeedsterAI Speaker Engineering

This skill computes acoustic properties of the SpeedsterAI enclosure and predicts the impact of parameter changes on sound quality. All formulas use SI units internally (meters, Hz, m/s) but accept and report mm for consistency with the SCAD model.

## Constants

- Speed of sound: **c = 344 m/s** (at ~21°C room temperature)
- Air density: **ρ = 1.18 kg/m³**

## Port Tuning (Helmholtz Resonance)

The port tuning frequency determines the low-end extension of the speaker. Carmody's target is ~55 Hz.

### Basic Formula

```
f_b = (c / 2π) × √(S_p / (V_b × L_eff))
```

Where:
- `S_p` = port cross-section area (m²) = π/4 × d²
- `V_b` = box net air volume (m³)
- `L_eff` = effective port length including end corrections (m)

### End Corrections

A port tube has acoustic "virtual length" beyond its physical ends due to the air mass that moves at each opening:

- **Flanged end** (inside the box): add `0.85 × r` where r = port radius
- **Free end** (outside/flush with back): add `0.6 × r`
- **Flared end**: reduces end correction — the flare acts as an impedance transformer

For SpeedsterAI:
- Physical length: 114.3mm
- Entry flare (15mm quarter-circle bell): reduces the flanged end correction. The flared section consumes 15mm of straight bore, and the effective acoustic length of the flared section is shorter than 15mm of straight tube.
- Exit flare (45° chamfer in 10mm wall): small end correction reduction
- Approximate effective length: `L_phys + 0.85r(entry_correction) + 0.6r(exit_correction)`

### Current Values

With port Ø34.925mm × 114.3mm in 5.68L net volume:
- Port area: 957.6 mm² (9.576 × 10⁻⁴ m²)
- Port radius: 17.46 mm
- Effective length (with corrections): ~125-130mm
- **Nominal tuning: ~55-60 Hz** (matches Carmody's target within practical tolerance)

### Impact of Volume Changes

Port tuning scales with `1/√V_b`. For small changes:
- +1L volume → tuning drops ~5 Hz
- −1L volume → tuning rises ~6 Hz
- Each 1mm of depth change ≈ 0.033L ≈ 0.3 Hz shift

## Baffle Step Frequency

When sound wavelength becomes comparable to baffle width, the radiation pattern transitions from omnidirectional (4π) to half-space (2π), causing a ~6 dB step in the on-axis response.

### Formula

```
f_step = c / (π × W_baffle)
```

Where `W_baffle` is the narrowest baffle dimension (usually width) in meters.

### Current Values

- Baffle width: 180mm → f_step ≈ **608 Hz**
- Baffle height: 264mm → f_step ≈ **415 Hz** (height-based, less audible)
- Original Carmody (152mm width): f_step ≈ **720 Hz**

The wider baffle shifts the step down by ~112 Hz compared to the original. Carmody's crossover compensates for baffle step in the frequency response shaping.

## Diffraction Threshold

The front edge roundover reduces diffraction (sharp-edge scattering) above a frequency determined by the roundover radius:

### Formula

```
f_diffraction = c / (2π × r_roundover)
```

### Current Values

- Roundover inset: 20mm → effective above **~2737 Hz**
- Previous (24mm): effective above **~2281 Hz**
- Original MDF (no roundover): no diffraction control at all

The crossover frequency for the tweeter is typically 3-4 kHz, so the 20mm roundover provides meaningful diffraction control throughout most of the tweeter's operating range.

## Volume Estimation

### Taper Formula

The enclosure uses a quadratic power taper (power=2.0):

```
t = z / enclosure_depth
t_curved = t^taper_power

w(z) = baffle_width × (1 - t_curved) + back_width × t_curved
h(z) = baffle_height × (1 - t_curved) + back_height × t_curved
```

For inner cavity, subtract 2×wall from w and h, and apply roundover_inset_at(z).

### Simpson's Rule (Quick Estimate)

```
V = (L/6) × (A_front + 4×A_mid + A_back)
```

Where L = cavity length (depth - 2×wall), and A = cross-section area at front, mid, back.

The SCAD file's Simpson's rule uses 3 sample points, which overestimates by ~0.08L because it doesn't capture the roundover zone. For precise volume, export `inner_cavity()` as STL and measure in the slicer.

### Volume Budget

| Item | Volume |
|------|--------|
| Gross cavity | 5.86 L (STL verified) |
| Port + bell | -0.16 L |
| Pillars | -0.02 L |
| Net air | 5.68 L |
| Crossover | -0.33 L |
| Effective | ~5.35 L |

## Predicting Impact of Changes

When the user asks "what if I change X", compute:

1. **Volume change**: Use the taper formula to estimate the new gross cavity volume
2. **Port tuning shift**: Apply `f_new = f_old × √(V_old / V_new)`
3. **Baffle step shift**: Apply `f_step = 344000 / (π × new_width_mm)`
4. **Diffraction threshold**: Apply `f_diff = 344000 / (2π × new_roundover_mm)`

### Volume Sensitivity

For depth changes: each 1mm ≈ mid-section area / 1e6 ≈ 0.033L
For width changes: each 1mm baffle width ≈ 0.08L (more sensitive due to height multiplier)
For height changes: each 1mm baffle height ≈ 0.05L

## Standing Waves

The curved-back wedge shape eliminates parallel internal surfaces, which is a major advantage over the rectangular MDF box. In a rectangular box, standing waves occur at:

```
f_standing = c / (2 × L_dimension)
```

For the original ~152mm deep box: f = 344000/(2×132) ≈ 1303 Hz (a problematic midrange coloration). The SpeedsterAI wedge shape has no parallel pairs, so no sharp standing wave modes — energy spreads across a broader frequency range.

## Quick Reference Formulas

| Property | Formula | Current Value |
|----------|---------|---------------|
| Port tuning | c/(2π) × √(Sp/(Vb×Leff)) | ~55-60 Hz |
| Baffle step (width) | c/(π×W) | ~608 Hz |
| Baffle step (height) | c/(π×H) | ~415 Hz |
| Diffraction threshold | c/(2π×r) | ~2737 Hz |
| Volume per mm depth | A_mid/1e6 | ~0.033 L/mm |
| Tuning shift per liter | ~5 Hz/L (at 5.5L) | — |
