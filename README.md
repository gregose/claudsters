# SpeedsterAI — 3D Printed Speedster Speaker Enclosure

A 3D-printable [OpenSCAD](https://openscad.org/) enclosure for Paul Carmody's [Speedster](https://sites.google.com/site/undefinition/bookshelf-speakers/speedster) bookshelf speakers — designed from scratch with AI, optimized for FDM printing, and engineered to match Carmody's original acoustic spec.

| | |
|---|---|
| ![3/4 Front](renders/three_quarter_front.png) | ![3/4 Back](renders/three_quarter_back.png) |
| ![Front](renders/front.png) | ![Back](renders/back.png) |

## Why This Project

**Designed with AI from day one.** The entire enclosure was developed iteratively with an AI agent ([GitHub Copilot CLI](https://github.com/features/copilot)) working directly in OpenSCAD code. The workflow: describe a feature or problem → the agent writes or modifies the parametric model → export STLs → review in the slicer → iterate. Over 19 sessions, this loop produced the geometry, caught component collisions (tweeter-port overlap, crossover-woofer interference), built a [validation suite](docs/development.md#validating-the-design) for faster iteration without regressions, and documented every decision for future work. The full design history — including dead ends and reverted approaches — is preserved in [`docs/copilot.md`](docs/copilot.md). The agent runs in a [sandboxed devcontainer](docs/development.md#development-container) with only project files and a scope-limited token, so it has the tools it needs without host access.

**Every feature is designed for FDM.** The curved enclosure shape looks organic, but every surface was constrained for printability. The front roundover follows a [cubic Hermite spline](docs/design.md#front-edge-roundover) tuned to exactly 45° maximum overhang. Port flares, crossover bosses, and pillar braces all print without supports. A [tolerance test print](docs/printing.md#tolerance-test-print) calibrates every fit-critical dimension to your specific printer before committing to the full build.

**Acoustic fidelity to Carmody's design.** Same drivers, same crossover, same port tuning — the enclosure is the only thing that changed. Internal volume is [verified at 5.68L net](docs/analysis.md) (Carmody spec: 5.5L). The port dimensions are unchanged. What the original *couldn't* do: a 20mm baffle roundover for diffraction control, curved walls to break up standing waves, and port entry/exit flares to reduce chuffing. A [validation suite](docs/development.md#validating-the-design) runs at every build to verify all clearances and component fits.

| Exploded Front | Exploded Back |
|----------------|---------------|
| ![Exploded Front](renders/exploded_front.png) | ![Exploded Back](renders/exploded_back.png) |

| Side | Top |
|------|-----|
| ![Side](renders/side.png) | ![Top](renders/top.png) |

## Specifications

| | Original (Carmody) | SpeedsterAI |
|---|---|---|
| Internal volume | 5.5 L | 5.68 L net / ~5.35 L effective |
| Port | 1.375" dia × 4.5" long | Same + entry bell / exit chamfer |
| Woofer | Tang Band W4-1720 | Same (heat-set inserts) |
| Tweeter | Fountek NeoCD1.0 | Same (heat-set inserts) |
| Wall | 1/2" MDF | 10mm PETG (5–6 perimeters) |
| Shape | Rectangular box | Curved-back wedge |
| Baffle roundover | None | 20mm Hermite spline |
| Bracing | None | 8× pillar pairs with interlocks |

## Design Highlights

- **Curved-back wedge** — quadratic taper from 180×264mm baffle to 118×211mm back over 205mm depth
- **Tongue-and-groove split** — self-aligning airtight seal at the split plane, no gasket trimming
- **8 bolted pillar pairs** — wall reinforcement + shear-resistant alignment via interlock boss/recess
- **Internal crossover mounting** — HP and LP boards on opposite walls with heat-set insert bosses
- **Component envelope validation** — 20 analytical assertions + 21 geometric collision checks run at every build

See [docs/design.md](docs/design.md) for the full engineering breakdown.

| Component Fit Front | Component Fit Back |
|---------------------|-------------------|
| ![Component Fit Front](renders/component_fit_front.png) | ![Component Fit Back](renders/component_fit_back.png) |

## Get the STLs

- [Front half](models/speedster-ai-front.stl) — print baffle-face down
- [Back half](models/speedster-ai-back.stl) — print flat back-face down

Designed for the Bambu Lab H2D but any printer with at least a **180 × 264 × 125mm** build volume will work. PETG, 0.2mm layers, 5–6 perimeters.

## Quick Start

```bash
./render.sh          # Generate PNG renders (Blender Cycles, photorealistic)
./render.sh --fast   # Generate PNG renders (OpenSCAD, faster)
./export.sh          # Export print-ready STLs
./validate.sh        # Run full validation suite (41 checks)
```

Open `speedster-ai.scad` in [OpenSCAD](https://openscad.org/) to explore the parametric model. All dimensions are parameters at the top of the file.

## Documentation

| Doc | Contents |
|-----|----------|
| [Printing & Assembly](docs/printing.md) | Print settings, tolerance calibration, step-by-step assembly, full BOM |
| [Design Details](docs/design.md) | Engineering rationale for every feature — port flares, roundover math, pillar system |
| [Development Guide](docs/development.md) | SCAD usage, render/export/validate pipelines, devcontainer setup |
| [Design Analysis](docs/analysis.md) | Verification data — volume measurements, clearance margins, collision results |
| [AI Design History](docs/copilot.md) | Complete 19-session design log — every decision, iteration, and dead end |

## File Structure

```
speedster-ai/
├── speedster-ai.scad         # Parametric OpenSCAD enclosure model
├── component-envelopes.scad  # Component clearance envelopes + validation assertions
├── tolerance-test.scad       # Printer tolerance calibration print
├── export.sh                 # STL export pipeline
├── render.sh                 # Render pipeline (10 PNG views, Blender or --fast OpenSCAD)
├── validate.sh               # Validation pipeline (assertions + collision checks)
├── validate.py               # Geometric collision detection (trimesh + manifold3d)
├── copilot.sh                # Launch Copilot CLI in the devcontainer
├── models/                   # Exported STL files
├── renders/                  # Generated PNG renders
├── references/               # Component datasheets
└── docs/                     # Detailed documentation
    ├── printing.md           # Print settings, assembly, BOM
    ├── design.md             # Engineering design details
    ├── development.md        # Dev guide, pipelines, devcontainer
    ├── analysis.md           # Design verification data
    └── copilot.md            # AI agent design context
```

## License

Enclosure design files are provided for personal/hobby use. The Speedster speaker design is by Paul Carmody. Crossover schematic and driver selection are his work.
