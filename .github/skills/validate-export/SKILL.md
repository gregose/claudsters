---
name: validate-export
description: Runs the SpeedsterAI validation and export pipeline after design changes. Use this skill whenever the user says "validate", "export", "check the design", "run validation", "update STLs", "generate renders", "export STLs", or after ANY geometry change to speedster-ai.scad or component-envelopes.scad. Also trigger when validation fails and the user needs help interpreting assertion errors or geometric collision results. This skill MUST be used after every design change — the user reviews changes in their slicer via exported STLs, not in OpenSCAD.
---

# Validate & Export — SpeedsterAI Pipeline Runner

After every design change to the SpeedsterAI enclosure, three scripts must run in sequence. This is the most critical post-change workflow — skipping it means the user can't review changes and may not catch validation failures.

## Why This Matters

The user reviews design changes by importing STLs into their slicer (Bambu Studio), not by opening OpenSCAD. If you modify `speedster-ai.scad` but don't run `./export.sh`, the user is still looking at stale STLs. Always export after changes.

## The Pipeline

Run these in order. Each step depends on the previous one succeeding:

### Step 1: Validate (`./validate.sh`)

```bash
./validate.sh
```

This runs two phases:

**Phase 1 — OpenSCAD Assertions (20 checks, ~4s)**
Evaluates `validate_clearances()` in `component-envelopes.scad`. Checks:
- Woofer flange fits flat baffle face (width and height)
- Woofer/tweeter body within cavity at deepest z-point
- Tweeter body ends before port tube starts
- Crossover PCBs clear woofer body (spatial separation)
- Crossover component zone clears port tube
- Binding post intrusion within crossover z-range
- Split plane clears roundover zone
- Driver-to-driver gap positive
- Left/right crossover boards don't overlap
- PCB corners within tapered cavity walls (4 corner checks)
- Both halves fit Bambu H2D print envelope (350×320×325mm)

**Phase 2 — Geometric Collision Detection (21 checks, ~30-60s)**
Runs `validate.py` which exports each component envelope as STL via OpenSCAD, then uses trimesh + manifold3d for:
- 6 cavity containment checks (component - cavity = empty, 3 skipped for pass-through components)
- 15 pair-wise collision checks (all component combinations)

Use `./validate.sh --skip-geometric` for fast assertion-only mode (~4s).

#### Interpreting Failures

**Assertion failures** print the exact constraint that failed with dimension values. Common causes:
- "Woofer flange exceeds flat baffle width" → `baffle_roundover` too large or `baffle_width` too small
- "Tweeter body overlaps port tube start" → increase `enclosure_depth` (pushes port start z deeper)
- "PCB corner outside cavity wall" → `back_corner_r` too large, or depth/height insufficient
- "Front half exceeds H2D Z height" → `split_z` + woofer flange thickness > 325mm

**Geometric failures** report collision volume in mm³:
- Containment failures: component protrudes past cavity wall — check if the component envelope dimensions are correct or if the enclosure is too small
- Collision failures: two components overlap — check their z/y/x ranges for spatial conflicts

### Step 2: Export STLs (`./export.sh`)

```bash
./export.sh
```

Exports two STLs to `models/`:
- `speedster-ai-front.stl` — Front half, oriented baffle-down for printing
- `speedster-ai-back.stl` — Back half, rotated 180° so flat back face is on build plate

Takes ~3-5 minutes for full CGAL rendering. Reports geometry status (vertices, facets, genus, error status).

If export reports errors, check the OpenSCAD console output for non-manifold warnings. Common causes are coplanar face violations (see openscad-edit skill).

### Step 3: Render PNGs (`./render.sh`)

```bash
./render.sh
```

Generates 9 standard PNG renders (1920×1080) to `renders/`:
- 5 assembled views: front, back, side, 3/4 front, 3/4 back
- 2 exploded views: front, back
- 2 component fit views: front, back (transparent shell + colored envelopes)

Takes ~15-25s total (all 9 run in parallel, ~3s each with `--preview` mode).

## Quick Reference

| Task | Command | Time |
|------|---------|------|
| Full validation | `./validate.sh` | ~35-65s |
| Assertions only | `./validate.sh --skip-geometric` | ~4s |
| Export STLs | `./export.sh` | ~3-5min |
| Render PNGs | `./render.sh` | ~15-25s |
| Full pipeline | `./validate.sh && ./export.sh && ./render.sh` | ~4-6min |

## When to Run What

| Situation | validate | export | render |
|-----------|----------|--------|--------|
| Parameter change | ✓ Full | ✓ Always | ✓ Yes |
| Module rewrite | ✓ Full | ✓ Always | ✓ Yes |
| Envelope change only | ✓ Full | Optional | Optional |
| Quick sanity check | Assertions only | Skip | Skip |
| Before git commit | ✓ Full | ✓ Always | ✓ Yes |

## Error Recovery

If validation passes but export fails:
1. Check for non-manifold geometry: the model may render in preview but fail in full CGAL mode
2. Look for `WARNING: Object may not be a valid 2-manifold` in export output
3. Common fix: check for coplanar faces between added geometry and cavity hull boundaries

If export succeeds but STL looks wrong in slicer:
1. Check for hull boundary alignment issues (horizontal shelf artifacts)
2. Verify `inner_cavity()` uses the same slice count and z-formula as `outer_shape()`
3. Look for thin walls or zero-thickness geometry at taper extremes
