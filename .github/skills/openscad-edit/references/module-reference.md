# OpenSCAD Module & Function Reference

## Core Shape Modules

### `cross_section_at(z)`
2D outer cross-section at depth z. Interpolates between baffle and back dimensions using `pow(z/depth, taper_power)`. Applies roundover inset in the first `roundover_depth` mm.

### `inner_cross_section_at(z)`
2D inner cross-section (outer minus wall thickness minus roundover inset). Used by `inner_cavity()`.

### `outer_shape()`
3D hull of adjacent 2D cross-section slices:
- 20 slices from z=0 to z=roundover_depth (fine resolution for curved roundover)
- 40 slices from z=roundover_depth to z=enclosure_depth (body taper)

### `inner_cavity()`
Same as `outer_shape()` but using `inner_cross_section_at()` with 0.001mm epsilon offset on z-positions. Clamped to z=wall through z=enclosure_depth-wall.

## Roundover Function

### `roundover_inset_at(z)` → float
Returns the inset amount (mm) at depth z. Compound profile:
- z < baffle_edge_chamfer: `baffle_roundover + chamfer - z` (linear 45°)
- z < roundover_depth: Cubic Hermite spline `baffle_roundover * p(f)` where `f = (z-c)/(D-c)`, `s = (D-c)/I`
- z >= roundover_depth: 0

## Cavity Dimension Functions

### `inner_half_w_at(z)` → float
Inner cavity half-width at depth z: `(w_outer - 2*wall) / 2`

### `inner_half_h_at(z)` → float
Inner cavity half-height at depth z: `(h_outer - 2*wall) / 2`

### `inner_corner_r_at(z)` → float
Inner corner radius at depth z: `max(0, r_outer - wall)`

### `inner_wall_x_at(z, y)` → float
Actual inner wall x-position at (z, y), accounting for corner rounding:
- In flat zone (|y| ≤ half_h - corner_r): returns `inner_half_w_at(z)`
- In corner zone: returns reduced x from the rounded corner arc

### `min_wall_x_in_boss(z, y)` → float
Samples 9 points (center + 8 cardinal/diagonal) of a boss cylinder at (z, y) and returns the minimum `inner_wall_x_at()`. Ensures boss doesn't protrude through curved walls.

## Bolt & Counterbore Functions

### `landing_z(px, py, clearance)` → float
Computes the z-depth where the taper cross-section provides `clearance` mm around point (px, py). Uses the taper formula analytically — no iterative search.

### `min_landing_z()` → float
Returns the shallowest (most restrictive) `landing_z` across all 8 bolt positions, giving uniform bolt length.

## Crossover Functions

### `xover_hole_enc(hole, sign)` → [enc_z, enc_y]
Converts PCB hole coordinates to enclosure coordinates. Both boards are rotated 180° in-plane. Left wall (sign=-1) uses pcb_x as-is; right wall (sign=+1) mirrors pcb_x.

### `xover_pcb_face_x_abs()` → float (positive)
PCB face x-position magnitude. Computed from the narrowest corner-aware wall x across all holes minus minimum boss depth.

## Driver Cutout Modules

### `woofer_cutout()`
Bore + 45° rear chamfer (rotate_extrude) + 4× M4 heat-set insert pockets (diamond pattern on 115mm circle).

### `tweeter_cutout()`
Flush recess (100.5mm dia, 4mm deep) + compound through-hole (25×67 + 56×47 rectangles) + 4× M3 insert pockets.

## Port Modules

### `port_tube_solid()`
Material for port walls. Main tube + entry bell cone. Extended 1mm past inner back wall.

### `port_bore()`
Subtracted bore: straight bore + quarter-circle entry flare + 45° exit chamfer with R=10 fillet.

### `port_ribs()`
6 triangular gusset ribs at tube-to-back-wall junction.

## Assembly Modules

### `full_enclosure()`
Complete assembled enclosure: shell + port + pillars + bosses + ribs, minus all cutouts.

### `front_half()` / `back_half()`
Split at `split_z`. Front includes tongue + interlock recesses. Back includes groove + counterbores + interlock bosses.

## Rendering Variables

### `render_mode` (0-7)
0=assembled, 1=exploded, 2=front, 3=back, 4=cavity, 5=component-fit, 6=front+components, 7=back+components

### `validation_export` (0-7)
0=normal, 1=cavity, 2=woofer, 3=tweeter, 4=binding posts, 5=crossover HP, 6=crossover LP, 7=port

## Validation (component-envelopes.scad)

### `validate_clearances()`
20 assert() checks run at every render: driver fit, cavity clearances, port separation, PCB containment, print envelope compliance.
