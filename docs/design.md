# Design Details

Detailed engineering notes on the SpeedsterAI enclosure design. For a project overview, see the [README](../README.md).

## Curved-Back Wedge Shape

Quadratic taper (power 2.0) from 180×264mm baffle to 118×211mm back over 205mm depth. Concentrates volume near the baffle where driver clearance matters most, then tapers aggressively toward the back. The curved side walls also break up internal standing waves that plague rectangular cabinets.

## Front Edge Roundover

20mm front edge roundover with a cubic Hermite spline profile, plus a 2mm 45° baffle edge chamfer. The profile is defined by `roundover_inset_at(z)` — a compound function with two zones:

1. **Baffle edge chamfer** (z=0 to z=2mm): Linear 45° bevel softens the front face edge.
2. **Hermite cubic** (z=2mm to z=33mm): Smooth G1-continuous curve blending to the full body width. The ratio `roundover_depth / baffle_roundover = 33/20 = 1.65` ensures the slope magnitude is monotonically decreasing, keeping max overhang at exactly 45° for FDM printability.

Reduces diffraction effects above ~2737 Hz. The original MDF box had sharp baffle edges — any roundover is an improvement.

## Back Edge Chamfer

2mm 45° bevel on the back face edge, mirroring the front baffle edge chamfer. Defined by `back_inset_at(z)` — a linear function from `z = enclosure_depth - back_edge_chamfer` (203mm) to `z = enclosure_depth` (205mm). Breaks up the sharp 90° corner where the back face meets the side walls.

Printable without supports: the back half prints back-face-down, so the chamfer is at the bed and the outer wall grows outward from it. The chamfer inset is combined with the front roundover inset in `cross_section_at(z)`, keeping the logic unified. Does not affect internal dimensions — the inner cavity stops at `z = enclosure_depth - wall` (195mm), well before the chamfer zone.

## Inner Cavity Floor Taper

Extra wall inset near the cavity floor (`cavity_floor_taper = 5`) that gradually opens the cavity over 5mm. At z=wall (10mm), the inner cross-section has an additional 10mm inset per side (effectively doubling wall thickness to ~32mm). This linearly tapers to zero by z=15mm, where normal wall thickness resumes.

**Problem:** Without the taper, the print transitions from fully solid to hollow in a single layer at z=10mm — a 63% drop in material per layer. The sudden pressure/thermal change causes a visible ridge on the outer wall.

**Solution:** `cavity_floor_inset_at(z)` adds a linear extra inset to `inner_cross_section_at()`, spreading the solid→hollow transition across ~25 layers (at 0.2mm). Volume impact is ~0.02L (0.3%) — negligible.

## Port System

**Port dimensions:** 34.925mm diameter × 114.3mm long (Carmody spec: 1.375" × 4.5"), tuned to ~55 Hz.

**Entry flare:** 15mm concave quarter-circle bell at the cavity-side opening. Provides 3.5× area expansion at the mouth for reduced turbulence and chuffing at higher SPL.

**Exit flare:** 45° linear chamfer confined to the 10mm back wall. Bore widens linearly from 34.9mm at the inner wall to 54.9mm at the back face. Always exactly 45° overhang — fully printable without supports. (The original concave quarter-circle exit was replaced because it had 0° overhang at the mouth.)

**Gusset ribs:** 6 triangular gussets at the port tube-to-back-wall junction (15mm tall, 10mm radial, 2mm thick). Spread the tube-to-wall load across more layer lines for better FDM adhesion — the tube axis is parallel to layer lines, making this junction rely entirely on interlayer adhesion without the ribs.

## Woofer Rear Chamfer

45° chamfer on the baffle cutout interior starting at z=3mm (leaving 3mm of straight bore for screw thread engagement). Opens the bore from 96.5mm to ~110.5mm at the inner wall surface, reducing back-wave reflections off the cutout edge.

## Internal Baffle Ribs

Spoke-to-pillar stiffening rib pattern on the inner baffle surface to reduce panel resonance. The flat baffle (180×264mm) is the largest unsupported panel; ribs break it into smaller zones with higher natural frequencies.

**Layout:** Concentric ring (R=60mm) around the woofer bore + 7 radial spokes from ring to pillar/bolt positions (top-center pillar skipped — spoke would cross the tweeter bore).

**Cross-section:** Isosceles trapezoid — 9mm base (at baffle surface) tapering to 3mm tip over 10mm height. The wider base maximizes stiffness where bending stress is highest, and the taper looks more refined than rectangular ribs. The ring rib inner edge (R=55.5mm) clears the woofer bore chamfer expansion (R=55.25mm) by 0.25mm.

**Printability:** Front half prints baffle-down, so ribs grow upward from the bed — no overhang. The taper angle (~17°) is well within FDM limits.

## Split Plane & Seal

Front/back split at z=80.7mm with integral tongue-and-groove seal joint. The split plane is aligned with the port tube front end so the port stays entirely in the back half.

- **Tongue:** 3mm wide × 4mm tall ridge on front half, centered 5mm from outer wall
- **Groove:** 3.6mm wide × 5mm deep channel in back half (0.3mm clearance per side)
- **Seal:** Closed-cell foam tape or TPU filament bead in groove bottom (1mm extra depth below tongue)

Provides X-Y self-alignment during assembly plus airtight seal when compressed.

## Pillar System

8 pillar pairs at the split-plane perimeter provide:
- **Wall reinforcement** — 16mm diameter pillars stiffen the side walls
- **Bolt anchorage** — M4 heat-set inserts in front half pillars accept bolts from back
- **Alignment** — interlock boss (back half) / recess (front half) at each pillar for shear-resistant registration

Back pillars extend 30mm past the split face with a 15° taper (30mm cone) blending into the inner wall. This covers the bolt through-hole and distributes load.

## Bolt Counterbore Landing

For each of the 8 bolt positions, the taper cross-section is analyzed to find the z-depth where the wall still provides 4mm of material around the bolt center. An 8mm cylinder is cut from that z to the back exterior, creating a flat perpendicular face for the bolt head. All 8 counterbores use the shallowest landing z (~113mm) so all bolts are the same standard length (~M4×60mm).

## Crossover Mounting

HP and LP crossover boards mount on opposite side walls via M3 heat-set inserts in printed bosses. Each boss has:
- **45° triangular brace** starting at the bottom of the boss for overhang-free FDM printing
- **D-shaped cross-section** — hull of cylinder + slab eliminates crescent gaps between round boss and flat brace
- **Corner-aware positioning** — `inner_wall_x_at(z,y)` accounts for internal corner rounding to prevent bosses protruding through curved walls

PCB z range: 90–182mm. Clears the woofer motor depth (89.5mm) with 0.5mm margin.

## Component Envelope Validation

A comprehensive test suite verifies all internal components fit without collisions:

**Phase 1 — Analytical assertions (22 checks):** Runs inside OpenSCAD at every render. Checks driver fit, cavity clearances, tweeter-port separation, crossover positioning, PCB corner containment, binding post fit, split plane validity, volume tolerance, and print envelope compliance.

**Phase 2 — Geometric collision detection (21 checks):** Python script (`validate.py`) exports each component envelope as STL, then uses trimesh + manifold3d to verify 6 cavity containment checks and 15 pair-wise collision checks across all internal components.

The component fit can be inspected visually with `render_mode=5` (transparent enclosure + color-coded component envelopes).

## Coordinate System

- **Z axis:** 0 at front baffle face, increasing toward back
- **Y axis:** Vertical, positive up. Woofer at y=−45, tweeter at y=+55
- **X axis:** Horizontal, positive right (facing speaker)
