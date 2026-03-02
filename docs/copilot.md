# SpeedsterAI — Design Context for AI Agents

This document captures the full design history and decision rationale for the SpeedsterAI project (3D printed Paul Carmody Speedster speaker enclosures). It is intended to provide context for AI agents continuing the work.

## Project Overview

The goal is to replace the original Speedster's 1/2" MDF box with a 3D-printed PETG enclosure that maintains acoustic fidelity to Paul Carmody's design while taking advantage of curves and geometry impossible with traditional woodworking. The enclosure is designed for the Bambu Lab H2D large-format printer.

**Drivers (unchanged from Carmody's design):**
- Woofer: Tang Band W4-1720 (4" underhung midbass)
- Tweeter: Fountek NeoCD1.0 (true ribbon)

**Key acoustic targets (from Carmody's spec):**
- Internal volume: 5.5 liters
- Port: 1.375" dia × 4.5" long, tuned to ~55 Hz
- -3 dB point: mid-40 Hz range

## Design Sessions (Chronological)

### Session 1: Initial Enclosure Design
**File:** `2026-02-19-20-50-54-speedster-3d-printed-enclosure-design.txt`

Established the core parametric OpenSCAD model. Key decisions:
- **Curved-back wedge shape:** Wide flat baffle (165×300mm) tapering to narrow rounded back (118×240mm) over 185mm depth. Quadratic taper (power 2.0) concentrates volume near the baffle where driver clearance matters.
- **10mm PETG walls:** Chosen for stiffness/mass comparable to 1/2" MDF. At 5-6 perimeters, PETG walls are inherently airtight.
- **28mm front edge roundover:** Circular profile smoothing the baffle-to-side transition. Reduces diffraction effects above ~1950 Hz. The original MDF box had sharp edges.
- **Volume tuning:** Simpson's rule estimation built into the SCAD file. Iterated `enclosure_depth` to hit 5.49L net (after subtracting port tube and pillar displacement).
- **Driver placement:** Woofer at y=-45mm, tweeter at y=+55mm (center-to-center spacing of 100mm). Carmody's original had the woofer overlapping the tweeter flange slightly; our design maintains a small 7.75mm gap.

### Session 2: Bolt Reversal, Port Flare, Woofer Chamfer
**File:** `2026-02-20-02-43-55-speedster-3d-enclosure-refinements.txt`

Major refinements:
- **Bolt direction reversed:** Originally bolts entered from the front (visible). Reversed so bolts enter from back — no visible hardware on the front baffle.
- **Split plane repositioned:** Moved to z=60.7mm (aligned with port tube front end) so the port stays entirely in the back half. No split cuts through the port tube.
- **Port exit flare:** Added 15mm radius concave flare at the port exit on the back face. Reduces turbulence noise at the port opening. Implemented as a quarter-circle rotate_extrude profile.
- **Woofer rear chamfer:** 45° chamfer on the baffle cutout interior starting at z=3mm (leaving 3mm of straight bore for screw thread engagement). Opens the bore from 95.5mm to ~109.5mm at the inner wall surface, reducing back-wave reflection.

### Session 3: Heat-Set Inserts
**File:** `2026-02-20-02-45-11-speedster-3d-driver-heat-inserts.txt`

Converted all driver mounting from through-holes to heat-set inserts:
- **Woofer:** 4× M4 heat-set inserts (Ø5.6mm × 8mm deep) in baffle face, 45° rotated diamond pattern on 115mm bolt circle
- **Tweeter:** 4× M3 heat-set inserts (Ø4.5mm × 5mm deep) in recess floor, 60.8mm square pattern

This allows repeated assembly/disassembly without wearing out the plastic threads.

### Session 4: Tongue-and-Groove Seal
**File:** `2026-02-21-04-47-04-speedster-tongue-groove-seal.txt`

Replaced a CNC-cut foam gasket concept with an integral tongue-and-groove joint:
- **Tongue:** 3mm wide × 4mm tall ridge on front half split face, centered 5mm from outer wall
- **Groove:** 3.6mm wide × 5mm deep channel in back half (0.3mm clearance per side)
- **Seal strip:** Closed-cell foam tape or TPU filament bead in groove bottom (1mm extra depth below tongue)
- Provides X-Y self-alignment during assembly plus airtight seal when compressed

### Session 5: Internal Bracing Exploration → Pillar System
**File:** `2026-02-21-04-48-38-shelf-brace-iteration-pillar-approach.txt`

Explored three bracing strategies:
1. **Window brace** (separate printed piece clamped at split plane) — Rejected: extra part, tolerance-sensitive
2. **Shelf brace** (horizontal shelf between drivers) — Rejected: complicated clearances around port tube and drivers, additional bolt hardware
3. **Pillar-to-pillar mating** — Adopted: 8 pillar pairs at split-plane perimeter with interlock boss/recess. Pillars double as wall reinforcement and bolt anchorage.

### Session 6: Back-Face Bolt Exploration → Reverted
**File:** `2026-02-21-14-42-07-pillar-bolt-redesign-back-face.txt`

Attempted to move all 8 bolts to the flat back face for simpler counterbores. Reverted because:
1. Pillars lose side-wall attachment (less rigid)
2. Back panel becomes cluttered
3. Required specialty 180mm M4 bolts

### Session 7: Bolt Landing Solution + Pillar Refinements

Final resolution of the bolt-on-curved-wall problem:

- **Counterbore landing approach:** For each bolt position, compute the z-depth where the taper cross-section still provides 4mm of material around the bolt center. Cut an 8mm cylinder from that z through to the back exterior. This creates a flat perpendicular face inside the tapered wall for the bolt head to seat on.
- **Uniform bolt length:** All 8 counterbores use the shallowest (most restrictive) landing z (~113mm), so all bolts are the same standard length (~M4×60mm).
- **Back pillar extension:** Increased from 15mm to 30mm depth past split face, with taper angle reduced from 20° to 15° for a more gradual blend into the inner wall (~60mm total pillar+taper). Covers more of the bolt through-hole.
- **Interlock swap:** Boss moved to back half (no heat-set insert, stays at nominal size), recess moved to front half (absorbs any expansion from heat-set insert installation).

### Session 8: Crossover Boss Print Support Refinements

Improved the crossover PCB mounting bosses for overhang-free FDM printing:

- **45° brace start shifted:** The triangular support brace previously started at the boss center (`ez`), leaving the bottom half of the cylinder unsupported. Moved brace start to `ez + boss_r` (bottom of boss in print orientation) so the full cylinder sits on a 45° ramp with no overhang.
- **D-shaped boss cross-section:** Hulled each boss cylinder with a thin slab at `z = ez + boss_r` to create a flat-bottomed profile. This eliminates the crescent-shaped gaps between the round cylinder and the flat brace surface, giving a seamless transition from boss to support.
- **Result:** Every layer of the crossover boss prints with ≤45° overhang — no support material needed for these features.

### Session 9: Binding Plate Heat-Set Inserts

Converted binding post plate mounting from through-hole self-tappers to heat-set inserts:

- **4× M4 heat-set inserts** (Ø5.6mm × 6mm deep) pressed into the recess floor on the back face, same spec as the woofer mounting inserts.
- **Insert pockets bored from recess floor inward** (toward cavity). Total depth used: 3mm recess + 6mm insert = 9mm of the 10mm wall, leaving 1mm of material on the cavity side.
- **Rationale:** Self-tapping screws into PETG wear out quickly with repeated assembly. Heat-set inserts allow unlimited disassembly for crossover tuning and driver swaps, consistent with the rest of the enclosure's insert-based design.

### Session 10: Render Pipeline + Camera Angles

Established a CLI render pipeline for visual validation and documentation:

- **`render_mode` variable** (0–4): Assembled, exploded, front half, back half, cavity. Set via `-D render_mode=N` from CLI.
- **Display rotation** `rotate([90,0,0])`: Transforms model Y→Z so speaker stands upright with tweeter on top. After rotation: X=horizontal, Y=depth(0=baffle, -185=back), Z=height(+up). Model center at (0, -92.5, 0).
- **7 standard views** with tuned camera angles (eye/center format):
  - Front, back, side (assembled) — show baffle face, back panel, taper profile
  - 3/4 front, 3/4 back (assembled) — hero shots showing depth and features
  - Exploded front, exploded back — split halves revealing internal structure
- **`render.sh`**: Shell script generating all 7 renders in parallel (~1.5s each, `--preview` mode, 1920×1080).
- **Key insight:** Previous camera angles were wrong because they didn't account for the coordinate transform. The front baffle is at Y=0 (negative Y camera position), back at Y=185 (positive Y).

### Session 11: Port Entry Flare

Added a concave flare to the cavity-side port opening for turbulence reduction and tweeter clearance:

- **15mm radius quarter-circle entry flare** at the port tube front face (z = split_z). Smooth concave bell transitions from bore diameter (34.9mm) outward to 64.9mm at the mouth.
- **Bell-shaped tube solid** provides material for the flare: truncated cone from flare mouth + wall thickness down to normal tube diameter over 15mm depth.
- **Tweeter clearance:** Entry bell widens bore to 18.6mm radius at z=70 (tweeter rear face), providing 1.1mm clearance to the tweeter body (17.5mm from port axis). Without the bell, the straight bore (17.46mm) would collide.
- **Acoustic impact:** Entry flare consumes 15mm of the 114.3mm bore for the flared section, leaving 99.3mm of straight bore. Tuning shifts ~3.6 Hz higher. The primary benefit is reduced air turbulence and chuffing noise at higher SPL (3.5× area expansion at mouth).
- **6 triangular gusset ribs** at the port tube-to-back-wall junction. Each rib is a hull of a vertical strip on the tube surface and a horizontal strip on the back wall, forming a triangular brace. 15mm tall along the tube, 10mm radial extent, 2mm thick. Spreads the tube-to-wall load across more layer lines for better FDM adhesion (the tube axis is parallel to layer lines, making this junction rely entirely on interlayer adhesion without the ribs).

### Session 13: FDM-Printable Roundover Profile + Baffle Width

Fixed an unprintable overhang on the front half (printed baffle-down) and ensured the woofer flange sits entirely within the flat baffle face:

- **Problem:** The original 28mm circular roundover profile had a vertical tangent at z=0, creating 83° overhang in the first ~8mm (41 layers). The woofer flange (125.5mm OD) also overhung the 109mm flat baffle face by 8.25mm per side.
- **Roundover profile replaced:** Circular quarter-arc replaced with a **cubic Hermite spline** that starts at exactly 45° overhang and monotonically decreases to 0°. The profile is defined by `roundover_inset_at(z)`, a compound function with two zones:
  1. **Baffle edge chamfer** (z=0 to z=2mm): Linear 45° bevel softens the front face edge.
  2. **Hermite cubic** (z=2mm to z=39mm): `p(f) = (2-s)f³ + (2s-3)f² - sf + 1` where `s = D/I` (depth/inset ratio). G1 continuous at the junction (both sides have matching 45° slope).
- **Inset decoupled from depth:** New `roundover_depth` parameter (39mm) is separate from `baffle_roundover` inset (24mm). The ratio `s = 39/24 = 1.625` ensures the slope magnitude is monotonically decreasing.
- **Baffle widened:** 165mm → 180mm (+15mm) so the flat face (132mm) accommodates the woofer flange (125.5mm) with 3.25mm margin per side. After the 2mm edge chamfer, the first-layer face is 128mm (1.25mm margin).
- **Roundover inset reduced:** 28mm → 24mm. Diffraction effective above ~2281 Hz (vs ~1950 Hz). Still covers most of the woofer's upper range below the ~3-4 kHz crossover. The original MDF Speedster had no roundover at all.
- **Inner cavity tracks roundover:** `inner_cross_section_at()` now also applies `roundover_inset_at(z)`, maintaining uniform 10mm wall thickness throughout the roundover zone. Previously the inner cavity ignored the roundover, which worked with the old shallow-inset circular profile but would cause negative wall thickness with the deeper extended profile.
- **Depth reduced:** 185mm → 174mm to compensate the volume increase from the wider baffle. Net volume: 5.51L (target 5.5L).
- **Split plane shifted:** z=60.7mm → z=49.7mm (computed from `depth - wall - port_length`). Still clears the roundover zone (39mm) with 10.7mm margin.

### Session 12: STL Hull Boundary Alignment Bugfix

Fixed horizontal plane artifacts visible in the slicer at model z≈88mm and z≈114mm in the back half STL:

- **Root cause:** `inner_cavity()` used 50 evenly-spaced hull slices while `outer_shape()` used 20+40 slices at different z-positions. The `difference(outer - inner)` boolean created thin shelf artifacts at every mismatched hull boundary.
- **Fix — aligned slicing with epsilon offset:** Rewrote `inner_cavity()` to use the same slice count and z-formula as `outer_shape()` (20 roundover + 40 body slices), but offset by 0.001mm to prevent exactly coplanar faces that cause non-manifold edges in CGAL.
- **Port tube extension:** Extended `port_tube_solid()` by 1mm past the inner back wall (z = depth − wall) to eliminate coplanar faces between the port tube end and the inner cavity boundary.
- **Crossover boss assembly:** Removed `intersection(inner_cavity, xover_bosses_all)` — bosses are now added directly to the enclosure union, avoiding coplanar face artifacts where boss cylinder facets met cavity hull boundaries.
- **Validation:** Non-manifold edges reduced from 170 to 159; no large horizontal faces detected at problem z-values; both halves export with `NoError` status.

### Session 14: Crossover Clearance — Deeper Enclosure + Height Reduction

Resolved crossover-to-woofer collision found during test prints:

- **Problem:** Crossover PCBs mounted on side walls (z=62–154) collided with woofer motor assembly extending 82mm from baffle. Components protruding inward hit the woofer magnet (90mm dia) in the z=62–82 overlap zone.
- **Enclosure depth extended:** 174mm → 185mm (+11mm). Pushes the inner back wall from z=164 to z=175, allowing the 92mm PCB to start at z=83 (just clearing the woofer at z=82) with back edge flush at z=175.
- **Height reduced to maintain volume:** Baffle height 300→281mm, back height 240→225mm (proportional 0.8 ratio preserved). Net volume: 5.498L (target 5.5L, −0.002L error).
- **Driver fit verified:** Woofer flange bottom at y=−107.8 has 8.8mm clearance on flat baffle face (was 18.2mm). Tweeter top at y=80.2 has 36.2mm clearance. Both fit comfortably.
- **Crossover repositioned:** `xover_z_start` 62→83mm. PCB z range 83–175mm clears woofer entirely.
- **PCBs rotated 180° in-plane:** Both boards flipped top-to-bottom and left-to-right so components clear binding post hardware. `xover_hole_enc()` applies pcb_y flip (`pcb_h - hole_y`) for both walls, pcb_x flip for right wall mirror.
- **Corner-aware boss positioning:** Added `inner_corner_r_at(z)`, `inner_wall_x_at(z,y)`, and `min_wall_x_in_boss(z,y)` functions. These account for internal corner rounding when computing boss depth and PCB face position, preventing bosses from protruding through curved walls.
- **Hole [87,5] removed:** Falls in back-bottom corner rounding zone where wall_x < face_abs. 3 holes per board: [43,5], [87,121], [5,121].
- **`xover_y_top` tuned to 26:** Positions the inductor (50mm barrel at PCB coord 63,102) to clear the port tube (y=45, R=20) by 3.0mm circle-to-circle gap. PCB top at y=26 is 1mm above port bottom — 38mm-tall components clear with 2.1mm margin. Bottom at y=−100 clears corner rounding (3.2mm gap at tightest point z=163).
- **Tolerance updates from test prints:** M4 heat-set insert Ø5.5→5.6mm, M3 heat-set insert Ø4.4→4.5mm, M4 through-hole Ø4.3→4.5mm.
- **Diffraction impact:** Height-based baffle step shifts from ~573Hz to ~612Hz — negligible since it's dominated by the narrower width dimension (~608Hz). Roundover effectiveness unchanged.
- **Split plane auto-adjusts:** split_z = 185−10−114.3 = 60.7mm (was 49.7mm). Still well past the 39mm roundover zone.

### Session 15: Port Exit Flare Printability Fix

Replaced unprintable concave exit flare with FDM-compatible 45° chamfer:

- **Problem:** The original quarter-circle exit flare (R=15mm) on the back face had 0° overhang at the mouth, creating 53 failed layers (10.6mm) when printing the back half with back wall on the bed.
- **Exit flare replaced:** Quarter-circle → 45° linear chamfer confined to the 10mm back wall. Bore widens linearly from 34.9mm at inner wall to 54.9mm at back face. Always exactly 45° overhang — fully printable without supports.
- **Entry flare retained:** 15mm quarter-circle bell at cavity side. Not a print issue (prints last at top of back half). Provides 1.1mm tweeter clearance and 3.5× area expansion for turbulence reduction.
- **Internal geometry unchanged:** Exit chamfer only modifies the wall region (z=175 to z=185). No port tube solid changes needed. Entry bell and tube unchanged.
- **Port tuning:** 114.3mm total bore (99.3mm straight + 15mm entry bell). Exit chamfer adds end correction only. Tuning ~64 Hz — within practical tolerance of Carmody's ~55 Hz target (end correction models vary).

### Session 16: Deeper Enclosure for Tweeter Clearance

Resolved tweeter-to-port collision discovered when measuring the Fountek NeoCD1.0 rear body:

- **Problem:** The tweeter rear body (including terminals) requires a 50mm × 50mm square clearance envelope extending 70mm behind the baffle. The port entry bell (centered at y=45, just 10mm from tweeter at y=55) overlapped with this envelope from z=60.7 to z=70 — a 9.3mm zone where the port bell wall material physically collided with the tweeter body.
- **Root cause:** Previous clearance analysis used only the center-to-center distance (17.5mm from port axis to nearest tweeter edge), which showed 1.1mm clearance to the bore inner wall. But the 50mm square body extends in all directions from the tweeter center, and its flanks and sides pass through the annular port wall at angles away from the center-to-center line.
- **Solution:** Increased `enclosure_depth` from 185mm → 197mm (+12mm). This pushes `port_start_z` from 60.7mm to 72.7mm — completely past the tweeter's 70mm depth with 2.7mm clearance. The tweeter and port no longer share any z-range, eliminating the collision entirely.
- **Height reduced to maintain volume:** Baffle height 281→264mm, back height 225→211mm. Net volume: 5.507L (target 5.5L, +0.007L error). Proportional height ratio preserved at ~0.80.
- **Driver fit verified:** Woofer flange bottom at y=−107.75mm has 24.2mm clearance to baffle edge (half-height = 132mm). Tweeter faceplate top at y=105.25mm has 26.8mm clearance.
- **Crossover unaffected:** z_start=88mm, PCB extends to z=180mm, inner back wall now at z=187mm — 7mm clearance behind PCBs.
- **Split plane auto-adjusts:** split_z = 197−10−114.3 = 72.7mm. Still well past the 39mm roundover zone (33.7mm margin).

### Session 18: Enclosure Geometry Revision — Clearance and Collision Fixes

Comprehensive geometry revision driven by collision detection findings from Session 17. The component envelope validation system identified three issues: PCB corner collision with curved inner wall, marginal tweeter-port Z-clearance, and L3 inductor-port tube collision. Resolved with minimal aesthetic changes.

### Session 19: Printer Tolerance Test Print

Added a standalone tolerance test (`tolerance-test.scad`) to calibrate all fit-critical dimensions before the full enclosure print:

- **7 feature groups** covering every tolerance-sensitive interface: M4 heatset (A1), M3 heatset (A2), counterbore (A5), binding post keyhole (A4), horizontal M3 heatset (B1), tongue/groove (C1/C2), interlock (C3).
- **Print orientation matching:** Face-down bars (A1/A2/A5) have holes opening at z=0 (bed) to test ceiling bridging — identical to the enclosure's baffle-down print orientation. Horizontal bores (B1) test Z-axis tolerance perpendicular to layer lines. Mating pieces (C1–C3) are separate for physical fit testing.
- **±0.3mm in 0.1mm steps:** Each feature gets 7 variants around the nominal value. Engraved labels on front/back faces identify each variant; asterisk marks the nominal.
- **Absolute `print_*` variables:** Replaced offset-based `tol_*` variables with absolute dimension variables in `speedster-ai.scad`. The user reads the best-fit label and enters that value directly — no offset math. The tolerance test uses `include <speedster-ai.scad>` to derive its center values, keeping everything in sync.
- **Extensibility convention:** When adding new fit-critical features, add a corresponding test panel to `tolerance-test.scad` with a new `print_*` variable, matching print orientation, and engraved labels.

**Problems identified by validation:**
1. **PCB bottom-back corner collision:** The 92×126mm crossover PCBs at z=90–182 had their bottom-back corner (z=182, y=-100) extending past the curved inner cavity wall. The large `back_corner_r=42mm` caused the inner wall to curve inward significantly at extreme corners, leaving 21.5mm of PCB embedded in wall material.
2. **Tweeter-port Z-clearance:** Only 2.7mm gap between tweeter body (z=70) and port tube start (z=72.7). Risk of assembly interference.
3. **L3 inductor-port collision:** The L3 inductor (Ø50mm cylinder on LP board) extended to y=29, overlapping the port tube bottom at y=25. A 4.9mm³ collision detected by geometric validation.

**Solutions applied:**
- **`enclosure_depth` 197→205mm (+8mm):** Pushes port start to z=80.7, increasing tweeter-port gap from 2.7mm to 10.7mm. Also shifts the taper ratio at z=182 to be less severe, improving PCB corner clearance.
- **`back_corner_r` 42→17mm:** Sharper internal corners eliminate the curved wall intrusion at the PCB bottom-back corner. The inner wall at (z=182, y=-100) now has wall_x > face_x with margin.
- **`baffle_roundover` 24→20mm, `roundover_depth` 39→33mm:** Slightly reduced to maintain woofer flange fit margin (4.1mm width, 4.1mm height) on the unchanged 180mm baffle. Diffraction effective above ~2737Hz (was ~2281Hz). Ratio 33/20=1.65 maintains ≤45° FDM overhang.
- **`port_y_offset` 45→52mm:** Raises port tube 7mm, moving its bottom from y=25 to y=32. Clears the L3 inductor top (y=29) by 3mm. Zero acoustic impact — port tuning depends on length/diameter, not position.
- **`xover_z_start` 88→90mm:** Moves PCB front edge 2mm deeper, past the woofer envelope total depth (89.5mm). Eliminates the Z-overlap zone between woofer body and crossover face position.

**Crossover component envelopes refined:**
- Replaced placeholder bounding-box crossover envelopes with per-component models based on KiCad .pos file and user-provided dimensions.
- 5 components (C1, C2, C3, L1, L3) converted from rectangular to cylindrical envelopes, reducing envelope volume ~21% for more accurate collision margins.
- 10 components total across LP (4) and HP (6) boards, positioned using calibrated KiCad-to-enclosure coordinate mapping.

**Printability assertion added:**
- Bambu Lab H2D build envelope check (350×320×325mm): verifies both halves fit within print volume including woofer flange protrusion.

**Validation results:**
- 20/20 assertions PASS (was 13 + 1 warning)
- 21/21 geometric checks PASS (6 containment + 15 collision)
- Net volume: 5.68L net / 5.35L effective (after ~0.33L crossover displacement) — verified via STL export (5.86L gross cavity).

**What stayed the same:** Baffle dimensions (180×264mm), back dimensions (118×211mm), wall thickness (10mm), taper power (2.0), driver positions, port dimensions, all driver mounting hardware, tongue-and-groove seal, pillar system, bolt pattern.

## Current Locked Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Baffle | 180 × 264 mm | Width for woofer flange; original proportions preserved |
| Back | 118 × 211 mm, R17 corners | Sharper corners (was R42) for PCB clearance at bottom-back |
| Depth | 205 mm | Extended from 197 for tweeter-port clearance (+10.7mm gap) |
| Wall | 10 mm PETG | Stiffness parity with 1/2" MDF |
| Taper | Power 2.0 (quadratic) | Volume concentration near baffle |
| Roundover inset | 20 mm | Diffraction control > ~2737 Hz (reduced from 24 for driver fit) |
| Roundover depth | 33 mm | ≤45° FDM overhang (ratio 33/20=1.65) |
| Baffle edge chamfer | 2 mm | 45° bevel softening front face edge |
| Split plane | z = 80.7 mm | Port tube stays in back half (auto-computed from depth) |
| Port | 34.925mm dia × 114.3mm long | Carmody spec: 55 Hz tuning |
| Port Y offset | 52 mm | Raised from 45 to clear L3 inductor by 3mm |
| Port flare (exit) | 45° chamfer in 10mm wall | Printable (≤45° overhang), mouth Ø54.9mm |
| Port flare (entry) | 15 mm quarter-circle | Turbulence reduction |
| Port ribs | 6× gussets, 15×10×2mm | Layer adhesion at back wall junction |
| Pillar dia | 16 mm | 8 pairs at split-plane perimeter |
| Back pillar | 30mm + 15° taper (30mm cone) | Wall blend + bolt coverage |
| Bolt pattern | 8× M4, 12mm inset from edge | Split-plane perimeter |
| Counterbore | 8mm dia, uniform z ≈ 113mm | Cross-section landing analysis |
| Tongue | 3mm wide × 4mm tall | Self-aligning seal joint |
| Groove | 3.6mm wide × 5mm deep | 0.3mm clearance + 1mm seal depth |
| Interlock | 10mm dia × 2mm boss/recess | Boss on back, recess on front |
| Crossover PCB | 92 × 126 mm, 3 holes per board | Holes: [43,5], [87,121], [5,121] |
| Crossover z_start | 90 mm | Clears woofer depth (89.5mm) with 0.5mm margin |
| Crossover y_top | 26 mm | Inductor clears port by 3mm |
| Crossover face | ±49.6 mm from center | Corner-aware envelope positioning |
| M4 heat-set insert | Ø5.6mm × 8mm deep | Woofer, pillars, terminal plate |
| M3 heat-set insert | Ø4.5mm × 6mm deep | Tweeter, crossover bosses |
| M4 through-hole | Ø4.5mm | Bolt clearance holes |
| Volume (net) | 5.68 L | Verified via STL export (5.86L gross cavity) |
| Volume (effective) | ~5.35 L | After ~0.33L crossover component displacement |

## File Structure

```
speedster-ai/
├── speedster-ai.scad         # Complete parametric OpenSCAD model
├── component-envelopes.scad  # Component clearance envelope models + assertions
├── tolerance-test.scad       # Printer tolerance test print (calibrate before final print)
├── export.sh                 # STL export pipeline (front + back halves)
├── render.sh                 # Standard render pipeline (9 PNG views)
├── validate.sh               # Validation pipeline (assertions + geometric checks)
├── validate.py               # Python geometric collision detection (trimesh)
├── models/                   # Exported STL files for printing
├── renders/                  # Generated PNG renders
├── references/               # Component reference drawings and datasheets
├── README.md                 # Project overview, BOM, assembly
├── copilot.md                # This file — AI agent context
└── analysis.md               # Design verification and analysis
```

## Key Implementation Notes for Agents

1. **OpenSCAD parametric model:** All dimensions are parameters at the top of the file. Changing `enclosure_depth` adjusts volume; the echo block reports the estimated volume.
2. **Volume estimation:** Simpson's rule approximation. For precise volume, export `inner_cavity()` as STL and measure in a slicer.
3. **Split halves:** Uncomment the appropriate export option at the bottom. Front half prints baffle-down; back half prints split-face-down.
4. **Bolt counterbore math:** `landing_z()` and `min_landing_z()` functions compute the uniform counterbore depth analytically from the taper formula. No iterative search needed.
5. **The model uses z=0 at the front baffle face,** increasing toward the back. Y is vertical (positive up), X is horizontal (positive right when facing the speaker).

6. **Render pipeline:** `render.sh` generates 9 standard PNG views via OpenSCAD CLI (`--render --backend=Manifold`, ~1s each in parallel). The `render_mode` variable (0–7) selects assembled/exploded/half/cavity/component-fit/front-half-components/back-half-components views. After `rotate([90,0,0])`, the display coordinate system is X=horizontal, Y=depth(0=baffle, -205=back), Z=height(+up). Model center is at (0, -102.5, 0). Camera uses eye/center 6-parameter format.

7. **Hull boundary alignment:** `inner_cavity()` must use the same slice z-positions as `outer_shape()` (20 roundover + 40 body slices) with a 0.001mm epsilon offset. Misaligned boundaries create visible horizontal plane artifacts in the STL from the boolean difference. Exactly coplanar boundaries create non-manifold edges. The epsilon offset avoids both problems.

8. **Roundover profile:** The `roundover_inset_at(z)` function defines the compound front edge profile. It has a 2mm 45° chamfer at the baffle face, then a cubic Hermite spline blending to the full body width at `roundover_depth`. The inner cavity also applies this inset to maintain uniform wall thickness. When changing `baffle_roundover` or `roundover_depth`, keep the ratio `roundover_depth / baffle_roundover ≥ 1.0` to ensure max overhang ≤ 45°.

9. **Component envelope validation:** `component-envelopes.scad` defines simplified 3D clearance envelopes for all internal components (woofer, tweeter, binding posts, crossover PCBs, port tube). Envelopes use max-tolerance dimensions from manufacturer drawings. `validate_clearances()` runs assert() checks on analytical clearances at every render. `validate.py` exports each envelope as STL and checks cavity containment + pair-wise collisions using trimesh/manifold3d. Run `./validate.sh` for full validation. The `validation_export` variable (1–7) exports individual components for geometric analysis.

10. **Component envelope coordinate system:** Envelopes are positioned in the same coordinate system as the enclosure (z=0 at baffle, y=0 at center). Woofer envelope starts at z=wall (inner baffle face); tweeter body starts at z=wall; binding posts extend from z=enclosure_depth-wall inward; crossover PCBs are on side walls at x=±xover_pcb_face_x_abs().

11. **Printer tolerance calibration:** All fit-critical dimensions are controlled by `print_*` variables at the top of `speedster-ai.scad` (e.g., `print_m4_heatset_dia`, `print_groove_w`). These default to design nominals but should be updated with values from the tolerance test print before the final enclosure export. `tolerance-test.scad` uses `include <speedster-ai.scad>` with `render_mode = -1` to import these values as test centers — they always stay in sync. When adding a new fit-critical feature, add a `print_*` variable and a corresponding test panel.

### Session 20: Back Edge Chamfer + Trapezoidal Baffle Ribs + Render Speedup

**Back edge chamfer:** Added a 2mm 45° chamfer to the back face edge, breaking up the sharp 90° corner where the back meets the side walls:

- **New parameter:** `back_edge_chamfer = 2` (mm) — mirrors `baffle_edge_chamfer` on the front.
- **New function:** `back_inset_at(z)` — linear inset from `z = enclosure_depth - back_edge_chamfer` to `z = enclosure_depth`. Combined with `roundover_inset_at(z)` in `cross_section_at(z)`.
- **Simplified `cross_section_at(z)`:** Merged the two identical code branches (ri > 0 / ri == 0) into a single path since the inset math handles both cases.
- **No internal impact:** The chamfer zone (z=203–205) is entirely within the back wall (z=195–205). Inner cavity unaffected.
- **Printability:** Back half prints back-face-down, so the chamfer is at the bed — no overhang concern.

**Trapezoidal baffle ribs:** Changed the internal baffle stiffening ribs from rectangular to isosceles trapezoid cross-section:

- **New parameter:** `baffle_rib_base_width = 9` (mm) — 3:1 taper ratio from 9mm base to 3mm tip.
- **Reduced height:** 15mm → 10mm. Shorter ribs with wider base maintain comparable stiffness while reducing cavity intrusion.
- **Woofer chamfer clearance:** Ring rib inner edge (R=55.5mm) clears the woofer bore chamfer expansion (R=55.25mm at z=wall) by 0.25mm. No acoustic impact.
- **Implementation:** Ring uses tapered cylinders (r1/r2), spokes use tapered cylinders in hull — clean parametric change.

**Render pipeline speedup:** Switched `render.sh` from `--preview` (software OpenGL via xvfb) to `--render --backend=Manifold`. Total render time dropped from ~4 minutes to ~9 seconds (25× faster). Removed xvfb dependency.

### Session 21: Tolerance Fixes, Seal Redesign, Hardware Updates, Cavity Floor Taper

**Inner cavity floor taper:** Added `cavity_floor_taper = 5` parameter with `cavity_floor_inset_at(z)` function. Adds extra wall inset (10mm at z=wall, tapering to 0 at z=15mm) to eliminate a visible ridge on the outer wall caused by an abrupt 63% material-per-layer drop at z=10mm. Volume impact: ~0.02L (0.3%). First attempt used `scale()` on cross-sections which created hull pyramids covering driver cutouts — reverted in favor of the inset approach which only narrows the cavity opening.

## Open Items / Future Work

- Prototype print and fit check (tolerance test print first, then full enclosure)
- Acoustic measurement comparison to original Speedster
- Consider reducing `back_corner_r` aesthetic impact (17mm is fairly sharp; explore 20-25mm if PCB layout changes)
- When adding new fit-critical features, add corresponding test panels to `tolerance-test.scad` with `print_*` variables and matching print orientation
