#!/bin/bash
# SpeedsterAI — Render Pipeline
# Generates PNG renders via Blender Cycles (default) or OpenSCAD (fast mode).
#
# Usage: ./render.sh [--fast] [output_dir]
#   output_dir defaults to ./renders/
#   --fast     Use OpenSCAD rendering (no Blender required, much faster)
#
# Environment variables:
#   RENDER_SAMPLES  — Cycles samples per view (default: 32)
#   RENDER_JOBS     — Max concurrent Blender processes (default: 2)
#
# Coordinate system after display rotation (rotate([90,0,0])):
#   X = horizontal (left-right)
#   Y = depth (0=baffle, -205=back)
#   Z = height (vertical, positive up, center ~0)
#   Model center: (0, -102.5, 0)

set -e

# ── Parse arguments ─────────────────────────────────────────────────────
FAST_MODE=false
OUTDIR=""
for arg in "$@"; do
    case "$arg" in
        --fast) FAST_MODE=true ;;
        *)      OUTDIR="$arg" ;;
    esac
done
OUTDIR="${OUTDIR:-renders}"

SCAD="speedster-ai.scad"
SIZE="1920,1080"
CENTER="0,-102.5,0"
FRONT_STL="models/speedster-ai-front.stl"
BACK_STL="models/speedster-ai-back.stl"
BLENDER_SCRIPT="blender_render.py"
SAMPLES=${RENDER_SAMPLES:-32}
MAX_JOBS=${RENDER_JOBS:-2}
EXPLODE=60

# Component envelope colors (linear sRGB, matching OpenSCAD render_mode=5)
COLOR_WOOFER="0.8,0.1,0.1"        # Red
COLOR_TWEETER="0.12,0.39,0.88"    # DodgerBlue
COLOR_BINDING="0.2,0.8,0.1"       # Lime
COLOR_XOVER_HP="0.9,0.5,0.1"      # Orange
COLOR_XOVER_LP="0.85,0.65,0.0"    # Gold
COLOR_PORT="0.0,0.7,0.8"          # Cyan

# Auto-detect OpenSCAD
if [ -z "$OPENSCAD" ]; then
    if command -v openscad &>/dev/null; then
        OPENSCAD="openscad"
    elif [ -x "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" ]; then
        OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
    else
        echo "Error: OpenSCAD not found. Install it or set OPENSCAD env var." >&2
        exit 1
    fi
fi

if [ ! -f "$SCAD" ]; then
    echo "Error: $SCAD not found. Run from project root." >&2
    exit 1
fi

if [ "$FAST_MODE" = false ]; then
    if ! command -v blender &>/dev/null; then
        echo "Error: Blender not found. Install with: apt-get install blender (or use --fast)" >&2
        exit 1
    fi
    for f in "$FRONT_STL" "$BACK_STL" "$BLENDER_SCRIPT"; do
        if [ ! -f "$f" ]; then
            echo "Error: $f not found. Run from project root (export STLs first)." >&2
            exit 1
        fi
    done
fi

mkdir -p "$OUTDIR" tmp

# ── Fast mode: OpenSCAD rendering (no Blender) ─────────────────────────
if [ "$FAST_MODE" = true ]; then
    echo "Fast mode: rendering 9 views via OpenSCAD..."

    # Assembled views (render_mode=0, default)
    $OPENSCAD "$SCAD" --render --backend=Manifold --camera=0,800,0,$CENTER       --imgsize=$SIZE -o "$OUTDIR/front.png"               2>/dev/null &
    $OPENSCAD "$SCAD" --render --backend=Manifold --camera=0,-800,0,$CENTER      --imgsize=$SIZE -o "$OUTDIR/back.png"                2>/dev/null &
    $OPENSCAD "$SCAD" --render --backend=Manifold --camera=0,-102.5,800,$CENTER  --imgsize=$SIZE -o "$OUTDIR/top.png"                 2>/dev/null &
    $OPENSCAD "$SCAD" --render --backend=Manifold --camera=900,-50,80,$CENTER    --imgsize=$SIZE -o "$OUTDIR/side.png"                2>/dev/null &
    $OPENSCAD "$SCAD" --render --backend=Manifold --camera=450,550,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/three_quarter_front.png" 2>/dev/null &
    $OPENSCAD "$SCAD" --render --backend=Manifold --camera=-450,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/three_quarter_back.png"  2>/dev/null &

    # Exploded views (render_mode=1)
    $OPENSCAD "$SCAD" --render --backend=Manifold -D render_mode=1 --camera=500,600,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/exploded_front.png" 2>/dev/null &
    $OPENSCAD "$SCAD" --render --backend=Manifold -D render_mode=1 --camera=-500,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/exploded_back.png"  2>/dev/null &

    # Component fit view (render_mode=5)
    $OPENSCAD "$SCAD" --render --backend=Manifold -D render_mode=5 --camera=500,600,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/component_fit_front.png" 2>/dev/null &
    $OPENSCAD "$SCAD" --render --backend=Manifold -D render_mode=5 --camera=-450,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/component_fit_back.png"  2>/dev/null &

    wait
    echo "Done. Renders saved to $OUTDIR/"
    ls -lh "$OUTDIR"/*.png
    exit 0
fi

# ── Blender Cycles mode (default, photorealistic) ──────────────────────

# ── Export component envelope STLs (for component fit views) ────────────

COMP_DIR="tmp/components"
mkdir -p "$COMP_DIR"

export_component() {
    local idx=$1 name=$2
    local outfile="$COMP_DIR/${name}.stl"
    if [ ! -f "$outfile" ] || [ "$SCAD" -nt "$outfile" ]; then
        $OPENSCAD "$SCAD" --render --backend=Manifold \
            -D "validation_export=$idx" \
            -o "$outfile" 2>/dev/null
    fi
}

echo "Exporting component envelopes..."
export_component 2 woofer &
export_component 3 tweeter &
export_component 4 binding_posts &
export_component 5 crossover_hp &
export_component 6 crossover_lp &
# port tube (validation_export=7) is part of the back shell STL;
# skip it in component fit views — it's only needed for collision detection.
wait
echo "Component STLs ready."

# Helper: Blender Cycles render (photorealistic, dual-color PETG)
blender_render() {
    local output="$1" camera="$2"
    shift 2
    blender --background --python "$BLENDER_SCRIPT" -- \
        --stl "$FRONT_STL" "$BACK_STL" \
        --output "$output" \
        --camera "$camera" \
        --center "$CENTER" \
        --resolution "$SIZE" \
        --samples "$SAMPLES" \
        "$@" 2>/dev/null
}

# Component fit render: translucent shell + colored component envelopes
component_fit_render() {
    local output="$1" camera="$2"
    blender_render "$output" "$camera" \
        --shell-alpha 0.10 \
        --component "$COMP_DIR/woofer.stl"       "$COLOR_WOOFER" \
        --component "$COMP_DIR/tweeter.stl"      "$COLOR_TWEETER" \
        --component "$COMP_DIR/binding_posts.stl" "$COLOR_BINDING" \
        --component "$COMP_DIR/crossover_hp.stl" "$COLOR_XOVER_HP" \
        --component "$COMP_DIR/crossover_lp.stl" "$COLOR_XOVER_LP"
}

echo "Rendering 10 standard views (max $MAX_JOBS Blender jobs, ${SAMPLES} samples)..."

# Throttle: run at most MAX_JOBS Blender processes concurrently.
# Each Cycles render saturates all CPU cores, so more parallelism = slower overall.
job_count=0
throttle() {
    job_count=$((job_count + 1))
    if [ "$job_count" -ge "$MAX_JOBS" ]; then
        wait -n 2>/dev/null || wait  # wait for any one job to finish
        job_count=$((job_count - 1))
    fi
}

# ── Blender Cycles: assembled views (6) ────────────────────────────────
blender_render "$OUTDIR/front.png"               "0,800,0"        & throttle
blender_render "$OUTDIR/back.png"                "0,-800,0"       & throttle
blender_render "$OUTDIR/top.png"                 "0,-102.5,800"   & throttle
blender_render "$OUTDIR/side.png"                "900,-50,80"     & throttle
blender_render "$OUTDIR/three_quarter_front.png" "450,550,300"    & throttle
blender_render "$OUTDIR/three_quarter_back.png"  "-450,-700,300"  & throttle

# ── Blender Cycles: exploded views (2) ─────────────────────────────────
blender_render "$OUTDIR/exploded_front.png" "500,600,300"    --explode "$EXPLODE" & throttle
blender_render "$OUTDIR/exploded_back.png"  "-500,-700,300"  --explode "$EXPLODE" & throttle

# ── Blender Cycles: component fit views (2) — translucent shell + components
component_fit_render "$OUTDIR/component_fit_front.png" "500,600,300"    & throttle
component_fit_render "$OUTDIR/component_fit_back.png"  "-450,-700,300"  & throttle

wait
echo "Done. Renders saved to $OUTDIR/"
ls -lh "$OUTDIR"/*.png
