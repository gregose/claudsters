---
name: openscad-edit
description: Expert at modifying the SpeedsterAI parametric OpenSCAD enclosure model (speedster-ai.scad and component-envelopes.scad). Use this skill whenever the user wants to change enclosure geometry, adjust dimensions, modify driver placement, tweak the roundover profile, reposition the port or crossover, add or change internal features, or make any parametric change to the 3D model. Also use when the user asks about how the model works, what a parameter does, or why geometry is shaped a certain way. Trigger for any mention of SCAD, OpenSCAD, enclosure dimensions, wall thickness, taper, depth, baffle, port, pillar, bolt, tongue-and-groove, crossover boss, or similar CAD geometry terms in the context of this speaker project.
---

# OpenSCAD Edit — SpeedsterAI Geometry Expert

You are an expert at modifying the SpeedsterAI parametric OpenSCAD model. This enclosure is a 3D-printed PETG curved-back wedge for Paul Carmody's Speedster speakers, designed for the Bambu Lab H2D printer.

## Coordinate System

The model uses **z=0 at the front baffle face**, increasing toward the back:
- **Z axis**: 0 = front baffle, `enclosure_depth` (205mm) = back face
- **Y axis**: vertical, positive up. Woofer at y=-45, tweeter at y=+55
- **X axis**: horizontal, positive right when facing the speaker
- **Cavity interior**: z=`wall` (10mm) to z=`enclosure_depth - wall` (195mm)

For display rendering, `rotate([90,0,0])` transforms Y→Z so the speaker stands upright.

## File Structure

- `speedster-ai.scad` — The complete parametric model (~1550 lines). All dimensions are parameters at the top.
- `component-envelopes.scad` — Component clearance envelopes + validation assertions. Included by the main file.

## Critical Rules

These rules exist because violating them causes hard-to-diagnose STL artifacts. They were discovered through painful iteration over multiple sessions.

### 1. Hull Boundary Alignment

The enclosure shell is built by hulling adjacent 2D cross-section slices. `outer_shape()` uses 20 roundover slices + 40 body slices. `inner_cavity()` **must use the same slice z-positions** with a 0.001mm epsilon offset.

**Why**: Misaligned hull boundaries create visible horizontal shelf artifacts in the STL from the boolean difference `outer - inner`. Exactly coplanar boundaries create non-manifold edges in CGAL. The epsilon offset avoids both problems.

If you add new slicing zones or change slice counts, update **both** `outer_shape()` and `inner_cavity()` identically.

### 2. Coplanar Face Avoidance

Never let a subtracted or added solid share an exact face with the cavity boundary:
- Port tube extends 1mm past the inner back wall (`z = depth - wall + 1`)
- Crossover bosses are added directly to the union (not intersected with `inner_cavity()`)

**Why**: Exact coplanar faces cause CGAL to produce non-manifold edges or disappearing faces.

### 3. Roundover Profile Math

The front edge uses a compound profile defined by `roundover_inset_at(z)`:
1. **Baffle edge chamfer** (z=0 to z=2mm): Linear 45° bevel
2. **Cubic Hermite spline** (z=2mm to z=`roundover_depth`): `p(f) = (2-s)f³ + (2s-3)f² - sf + 1`

The ratio `roundover_depth / baffle_roundover` must be ≥ 1.0 to keep max overhang ≤ 45°. The inner cavity also applies this inset to maintain uniform wall thickness.

### 4. FDM Printability Constraints

- **Front half prints baffle-down**: All features in 0 ≤ z ≤ split_z must have ≤45° overhang
- **Back half prints back-face-down**: Features grow from z=enclosure_depth toward z=split_z
- Crossover bosses need 45° triangular braces (in +Z direction) for support
- The port exit flare uses a 45° linear chamfer (not a quarter-circle) for this reason

## Parameter Dependencies

Changing certain parameters cascades to others. Here's what to check:

| If you change... | Also check / adjust... |
|---|---|
| `enclosure_depth` | `split_z` (auto-computed: `depth - wall - port_length`), volume, crossover z-range, counterbore landing |
| `baffle_width` or `baffle_height` | Woofer flange fit on flat face, volume, bolt positions |
| `back_width` or `back_height` | Volume, binding post fit, PCB corner containment |
| `baffle_roundover` or `roundover_depth` | Keep ratio ≥ 1.0, check woofer flange fit on flat face, inner cavity profile |
| `port_y_offset` | Tweeter clearance (port must not overlap tweeter z-range), crossover inductor clearance |
| `xover_z_start` or `xover_y_top` | Woofer depth clearance, port clearance, PCB corner containment in tapered cavity |
| `back_corner_r` | PCB corner containment (smaller r = more room), aesthetics |
| `wall` | Everything — volume, cavity dimensions, split_z, port position |

## Key Modules and Functions

Read the `references/module-reference.md` file for a complete listing. The most important ones:

- `cross_section_at(z)` — 2D outer cross-section at depth z, including roundover
- `inner_cross_section_at(z)` — 2D inner cross-section (uniform wall inset)
- `outer_shape()` / `inner_cavity()` — 3D hull solids built from sliced cross-sections
- `roundover_inset_at(z)` — Returns the roundover inset in mm at depth z
- `inner_half_w_at(z)` / `inner_half_h_at(z)` — Inner cavity half-dimensions at z
- `inner_wall_x_at(z, y)` — Actual inner wall x-position accounting for corner rounding
- `min_wall_x_in_boss(z, y)` — Minimum wall x within a boss cylinder envelope
- `landing_z(px, py, clearance)` — Computes bolt counterbore depth from taper formula
- `xover_pcb_face_x_abs()` — PCB face x-position from corner-aware boss calculation
- `xover_hole_enc(hole, sign)` — Converts PCB hole coordinates to enclosure coordinates

## Current Locked Parameters

Read the `references/locked-parameters.md` file for the complete table with values and rationale for each parameter.

## Making Changes — Workflow

1. **Identify which parameters to change** and check the dependency table above
2. **Predict clearance impacts** before editing (use the clearance-check skill if available)
3. **Edit parameters** at the top of `speedster-ai.scad` — prefer parameter changes over module rewrites
4. **If adding new geometry**, follow the hull alignment and coplanar face rules
5. **After editing**, always run `./validate.sh` to check assertions and geometric collisions
6. **Always run `./export.sh`** to regenerate STLs — the user reviews changes in their slicer, not in OpenSCAD
7. **Run `./render.sh`** to update PNG renders
8. **Update documentation** (claude.md, README.md, analysis.md) if parameters or geometry changed

## Common Tasks

### Changing enclosure depth
Adjust `enclosure_depth`. The `split_z` auto-computes. Check that crossover PCBs still fit (z_start + 92 < inner back wall) and volume is near 5.5L target. Height may need reducing to maintain volume.

### Adjusting roundover
Change `baffle_roundover` (inset) and/or `roundover_depth`. Maintain ratio ≥ 1.0. Check woofer flange still fits on flat face: `baffle_width - 2*baffle_roundover ≥ woofer_flange_dia`.

### Moving the port
Change `port_y_offset` and/or `port_x_offset`. Check tweeter body clearance (port must start after tweeter depth ends in z), crossover inductor clearance (port bottom y > inductor top y), and that the port bell fits within the cavity cross-section.

### Repositioning crossover PCBs
Change `xover_z_start` (must be > woofer total depth) and/or `xover_y_top` (affects port clearance and corner containment). The `xover_pcb_face_x_abs()` function auto-computes from the narrowest boss position.

### Adding internal features
Use `intersection(inner_cavity(), feature)` to clip features to the cavity. Exception: if the feature's cylinder facets would create coplanar faces with hull boundaries, add it directly to the union (as done with crossover bosses).
