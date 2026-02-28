#!/bin/bash
# SpeedsterAI — Render Pipeline
# Generates 9 PNG renders: 7 via Blender Cycles (photorealistic),
# 2 component-fit views via OpenSCAD (needs ghost components).
#
# Usage: ./render.sh [output_dir]
#   output_dir defaults to ./renders/
#
# Coordinate system after display rotation (rotate([90,0,0])):
#   X = horizontal (left-right)
#   Y = depth (0=baffle, -205=back)
#   Z = height (vertical, positive up, center ~0)
#   Model center: (0, -102.5, 0)

set -e

SCAD="speedster-ai.scad"
OUTDIR="${1:-renders}"
SIZE="1920,1080"
CENTER="0,-102.5,0"
FRONT_STL="models/speedster-ai-front.stl"
BACK_STL="models/speedster-ai-back.stl"
BLENDER_SCRIPT="blender_render.py"
SAMPLES=64
EXPLODE=60

# Auto-detect OpenSCAD (needed for component fit views)
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

if ! command -v blender &>/dev/null; then
    echo "Error: Blender not found. Install with: apt-get install blender" >&2
    exit 1
fi

for f in "$SCAD" "$FRONT_STL" "$BACK_STL" "$BLENDER_SCRIPT"; do
    if [ ! -f "$f" ]; then
        echo "Error: $f not found. Run from project root (export STLs first)." >&2
        exit 1
    fi
done

mkdir -p "$OUTDIR"

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

echo "Rendering 9 standard views..."

# ── Blender Cycles: assembled views (5) ────────────────────────────────
blender_render "$OUTDIR/front.png"               "100,800,50"     &
blender_render "$OUTDIR/back.png"                "-100,-800,50"   &
blender_render "$OUTDIR/side.png"                "900,-50,80"     &
blender_render "$OUTDIR/three_quarter_front.png" "450,550,300"    &
blender_render "$OUTDIR/three_quarter_back.png"  "-450,-700,300"  &

# ── Blender Cycles: exploded views (2) ─────────────────────────────────
blender_render "$OUTDIR/exploded_front.png" "500,600,300"    --explode "$EXPLODE" &
blender_render "$OUTDIR/exploded_back.png"  "-500,-700,300"  --explode "$EXPLODE" &

# ── OpenSCAD: component fit views (2) — needs render_mode=5 ghost ──────
$OPENSCAD "$SCAD" --render --backend=Manifold -D render_mode=5 --camera=500,600,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/component_fit_front.png" 2>/dev/null &
$OPENSCAD "$SCAD" --render --backend=Manifold -D render_mode=5 --camera=-450,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/component_fit_back.png"  2>/dev/null &

wait
echo "Done. Renders saved to $OUTDIR/"
ls -lh "$OUTDIR"/*.png
