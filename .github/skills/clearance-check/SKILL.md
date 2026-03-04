---
name: clearance-check
description: Pre-change collision predictor for the SpeedsterAI enclosure. Use this skill whenever the user asks "will this fit", "check clearance", "what if I change X to Y", "does the crossover clear the port", "is there enough room for", or any question about whether components will collide or fit within the enclosure after a parameter change. Also use before making geometry changes to predict whether they'll cause validation failures. Trigger for any spatial reasoning about component placement, cavity dimensions, wall thickness at specific positions, or taper cross-sections. Use this skill BEFORE modifying SCAD files to avoid trial-and-error iteration.
---

# Clearance Check — SpeedsterAI Collision Predictor

This skill computes component clearances analytically, predicting whether a proposed parameter change will cause collisions before you modify any SCAD files. This is faster than the full geometric validation pipeline (~0 seconds vs ~60 seconds) and helps avoid trial-and-error iteration.

## How the Enclosure Tapers

The enclosure is a wedge that tapers from a wide baffle to a narrow back using a quadratic power curve:

```
t = z / enclosure_depth           # normalized depth (0 at front, 1 at back)
t_curved = t^2.0                   # quadratic taper

w(z) = 180 × (1 - t_curved) + 118 × t_curved    # width at depth z
h(z) = 264 × (1 - t_curved) + 211 × t_curved    # height at depth z

# Inner cavity (subtract walls and roundover):
inner_w(z) = w(z) - 2×10 - 2×roundover_inset_at(z)
inner_h(z) = h(z) - 2×10 - 2×roundover_inset_at(z)
```

The inner half-dimensions are:
```
inner_half_w(z) = (w(z) - 2×wall) / 2
inner_half_h(z) = (h(z) - 2×wall) / 2
```

### Corner Rounding

The inner corners are rounded with radius `r(z) = max(0, r_outer(z) - wall)` where `r_outer` interpolates between `baffle_corner_r` (15) and `back_corner_r` (17). In the corner zone (|y| > half_h - corner_r), the wall curves inward:

```
wall_x_at(z, y) =
  if |y| ≤ half_h - r:  inner_half_w(z)          # flat wall zone
  else:  (half_w - r) + √(r² - (|y| - half_h + r)²)   # corner arc
```

This matters most at the bottom-back corners where the crossover PCBs are positioned.

## Component Envelopes (Current Positions)

### Woofer — Tang Band W4-1720
- Center: (0, -45, 0)
- Flange: Ø125.8mm at z=0 (surface mounted)
- Body: Ø96mm basket from z=10 to z=17, Ø91.8mm motor from z=17 to z=89.5
- **Critical clearance**: flange must fit within flat baffle face (baffle_width - 2×roundover)

### Tweeter — Fountek NeoCD1.0
- Center: (0, +55, 0)
- Faceplate: Ø100.3mm, flush mounted in 4mm recess
- Rear body: 55×66mm box from z=4 to z=70
- **Critical clearance**: body must end before port starts (z=70 < split_z=80.7)

### Port Tube
- Center: (0, +52, split_z to depth-wall)
- Outer diameter: 39.9mm (straight), entry bell up to 69.9mm at z=split_z
- **Critical clearances**: tweeter body (z-separation), L3 inductor (y-separation)

### Crossover PCBs (×2, on side walls)
- Z range: 90 to 182mm
- Y range: -100 to +26mm
- Face position: ±49.6mm from center (x-axis)
- Components extend 40-50mm inward from face
- **Critical clearances**: woofer motor (z-overlap at z=89.5-90), port tube (y-clearance at top), cavity wall (corner containment at bottom-back)

### Binding Posts (×2)
- Center: (±15, -45, inner_back_z)
- Internal protrusion: 34mm from inner back wall
- Shaft: Ø11.3mm
- **Critical clearance**: tips at z=161mm, crossover starts at z=90

## Pre-Change Clearance Checks

When the user proposes a parameter change, compute these clearances with the new values:

### Depth Change (enclosure_depth)
```python
new_split_z = new_depth - 10 - 114.3          # auto port alignment
tweeter_port_gap = new_split_z - 70            # must be > 0, ideally > 5mm
xover_back_gap = (new_depth - 10) - (90 + 92)  # inner wall - PCB back edge
# Volume: use Simpson's rule with new depth
```

### Width/Height Change (baffle_width, baffle_height, back_width, back_height)
```python
flat_face = new_baffle_w - 2 * roundover
woofer_flange_margin = flat_face - 125.8       # must be > 0

# Check PCB corner containment at (z=182, y=-100):
t = 182 / new_depth
tc = t ** 2.0
w_at_182 = new_baffle_w * (1-tc) + new_back_w * tc
h_at_182 = new_baffle_h * (1-tc) + new_back_h * tc
inner_hw = (w_at_182 - 20) / 2
inner_hh = (h_at_182 - 20) / 2
# PCB bottom: |y|=100 must be < inner_hh
# PCB face_x ≈ 49.6 must be < inner_wall_x_at(182, -100)
```

### Port Position Change (port_y_offset)
```python
port_r = (34.925 + 2*2.5) / 2  # 19.96mm outer radius
port_bottom_y = new_y - port_r
inductor_top_y = 26 + 3  # approx from xover_y_top + small margin
inductor_clearance = port_bottom_y - inductor_top_y  # must be > 0

# Entry bell at split_z: Ø69.9mm
bell_r = 34.93  # bell radius at mouth
tweeter_body_edge = 55 - 33  # tweeter center - half body height = y=22
bell_top = new_y + bell_r
# bell_top should not reach tweeter body
```

### Crossover Position Change (xover_z_start, xover_y_top)
```python
woofer_clearance = new_z_start - 89.5          # must be > 0
pcb_z_back = new_z_start + 92
back_wall_gap = (depth - 10) - pcb_z_back      # must be > 0

pcb_y_bottom = new_y_top - 126
# Check corner containment at (pcb_z_back, pcb_y_bottom):
# inner_half_h_at(pcb_z_back) must be > |pcb_y_bottom|
# inner_wall_x_at(pcb_z_back, pcb_y_bottom) must be > face_x
```

### Roundover Change (baffle_roundover, roundover_depth)
```python
ratio = new_roundover_depth / new_roundover    # must be >= 1.0
flat_face_w = baffle_width - 2 * new_roundover
woofer_margin = flat_face_w - 125.8            # must be > 0
flat_face_h = baffle_height - 2 * new_roundover
woofer_h_margin = flat_face_h - 125.8          # must be > 0

# Check split_z still clears roundover zone:
split_roundover_gap = split_z - new_roundover_depth  # must be > 0
```

## Clearance Summary Table (Current Design)

| Clearance | Gap | Margin |
|-----------|-----|--------|
| Woofer flange ↔ flat face (width) | 4.1mm/side | Comfortable |
| Woofer flange ↔ flat face (height) | 4.1mm/side | Comfortable |
| Tweeter body ↔ port start (z) | 10.7mm | Good |
| Driver gap (woofer top ↔ tweeter bottom) | 7.75mm | OK |
| Port bottom ↔ inductor top (y) | ~3mm | Tight |
| Crossover z_start ↔ woofer depth | 0.5mm | Very tight |
| PCB back edge ↔ inner back wall | 13mm | Good |
| PCB bottom-back corner ↔ cavity wall | >0mm | Check with corner-aware calc |
| Left/right crossover overlap | ~18mm center gap | Good |
| Binding post tip ↔ crossover start | 71mm | Plenty |
| Split plane ↔ roundover zone | 47.7mm | Plenty |
| Both halves ↔ H2D print envelope | >40mm margin | Plenty |

## Tight Clearances (Watch List)

These are the clearances most likely to be violated by parameter changes:

1. **Crossover z_start vs woofer depth** (0.5mm) — almost any depth reduction or z_start reduction breaks this
2. **Port bottom vs inductor top** (~3mm) — sensitive to port_y_offset changes
3. **Tweeter body vs port start** (10.7mm) — reduced by decreasing depth
4. **PCB bottom-back corner containment** — sensitive to back_corner_r, back_height, depth
5. **Woofer flange vs flat face** (4.1mm/side) — sensitive to roundover changes
