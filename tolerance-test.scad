// ============================================================
// SpeedsterAI — Tolerance Test Print
// ============================================================
//
// Test plates for validating print tolerances before the full
// enclosure print. Each feature group is a single connected bar
// with 7 variants (±0.3mm in 0.1mm steps around nominal).
//
// Bars are grouped by required print orientation:
//   Face-down (A1+A2+A5): blind holes on bed, tests ceiling bridging
//   Through-holes (A4): standard flat
//   Horizontal (B1): upright, bore openings face you
//   Mating (C1-C3): separate pieces for physical fit testing
//
// Load the STL in slicer, separate objects, orient each group.
//
// Print settings: same as enclosure (PETG, 0.2mm layers,
// 5-6 perimeters, 50-80% gyroid infill).
//
// Usage:
//   openscad tolerance-test.scad -o models/tolerance-test.stl
//
// ============================================================

// ========================
// PARAMETERS
// ========================

// Import print-tuned dimensions from the main enclosure model.
// Override render_mode to suppress enclosure geometry output.
include <speedster-ai.scad>
render_mode = -1;
validation_export = 0;
$fn = 64;

num_steps = 7;
step_size = 0.1;
half_steps = (num_steps - 1) / 2;  // 3 for 7 steps

// Center values derived from speedster-ai.scad print_* variables.
// The test generates variants ±0.3mm around these values.
// After finding the best fit, update the print_* variables in speedster-ai.scad
// to the value printed on the best-fitting variant.
nom_m4_heatset    = print_m4_heatset_dia;
nom_m3_heatset    = print_m3_heatset_dia;
nom_bp_hole       = print_bp_hole_dia;
nom_bp_keyway_w   = print_bp_keyway_w;
nom_bp_keyway_ext = bp_keyway_total - print_bp_hole_dia;  // slot_ext past circle edge (matches enclosure)
nom_counterbore   = print_counterbore_dia;
nom_bolt_through  = print_bolt_dia;
nom_m3_horiz      = print_m3_heatset_z;
nom_tongue_w      = tongue_width;          // fixed tongue width from enclosure
nom_tongue_h      = tongue_height;         // fixed tongue height from enclosure
nom_groove_w      = print_groove_w;
nom_groove_d      = tongue_height + seal_depth;  // groove must fit tongue + seal
nom_interlock_dia = pillar_interlock_dia;  // fixed boss diameter from enclosure
nom_interlock_clr = print_interlock_clr;

// Feature depths (derived from enclosure, minimized for fast printing)
depth_m4_insert   = woofer_insert_depth;   // 8mm from enclosure
depth_m3_insert   = tweeter_insert_depth;  // 6mm from enclosure
depth_counterbore = 6;                     // representative counterbore depth
depth_bp          = 8;                     // enough to test through-hole

// Block construction
hole_wall  = 4;       // Min material around holes
bar_gap    = 6;       // Gap between bars on same plate
text_depth = 0.6;     // Engrave depth

// ========================
// HELPERS
// ========================

function step_val(nominal, i) = nominal + (i - half_steps) * step_size;
function max_dia(nominal) = nominal + half_steps * step_size;
function cell_size(nominal) = max_dia(nominal) + 2 * hole_wall;

// Engraved text on top surface (X/Y plane at height z)
module engrave_top(txt, x, y, z, size=3.5) {
    translate([x, y, z - text_depth])
        linear_extrude(height = text_depth + 0.1)
            text(txt, size=size, halign="center", valign="center",
                 font="Liberation Mono:style=Bold");
}

// Engraved text on front face (X/Z plane at y=0, reading right-side-up)
module engrave_front(txt, x, z, size=3.5) {
    translate([x, text_depth, z])
        rotate([90, 0, 0])
            linear_extrude(height = text_depth + 0.1)
                text(txt, size=size, halign="center", valign="center",
                     font="Liberation Mono:style=Bold");
}

// Engraved text on back face (X/Z plane at y=d, reading left-to-right, bottom toward z=0)
module engrave_back(txt, x, z, d, size=3.5) {
    translate([x, d - text_depth, z])
        rotate([-90, 180, 0])
            linear_extrude(height = text_depth + 0.1)
                text(txt, size=size, halign="center", valign="center",
                     font="Liberation Mono:style=Bold");
}

// Nominal variant gets asterisk suffix in its label
function label_str(nominal, i) =
    str(step_val(nominal, i), i == half_steps ? "*" : "");

// ========================
// A1: M4 Heat-Set Insert (face-down blind hole)
// ========================
// Hole opens at z=0 (bed). Ceiling at z=depth tests bridging.
module bar_m4_heatset() {
    cell = cell_size(nom_m4_heatset);
    w = num_steps * cell;
    d = cell;
    h = depth_m4_insert + 2;

    difference() {
        cube([w, d, h]);
        for (i = [0:num_steps-1]) {
            cx = i * cell + cell/2;
            translate([cx, d/2, -0.1])
                cylinder(d=step_val(nom_m4_heatset, i),
                         h=depth_m4_insert + 0.1);
        }
        // Group label on front face, diameter labels on back face
        engrave_front("A1: M4 heatset", w/2, h/2, size=2.5);
        for (i = [0:num_steps-1])
            engrave_back(label_str(nom_m4_heatset, i),
                         i * cell + cell/2, h/2, d, size=2.5);
    }
}

// ========================
// A2: M3 Heat-Set Insert (face-down blind hole)
// ========================
module bar_m3_heatset() {
    cell = cell_size(nom_m3_heatset);
    w = num_steps * cell;
    d = cell;
    h = depth_m3_insert + 2;

    difference() {
        cube([w, d, h]);
        for (i = [0:num_steps-1]) {
            cx = i * cell + cell/2;
            translate([cx, d/2, -0.1])
                cylinder(d=step_val(nom_m3_heatset, i),
                         h=depth_m3_insert + 0.1);
        }
        engrave_front("A2: M3 heatset", w/2, h/2, size=2.5);
        for (i = [0:num_steps-1])
            engrave_back(label_str(nom_m3_heatset, i),
                         i * cell + cell/2, h/2, d, size=2.5);
    }
}

// ========================
// A5: Bolt Counterbore (face-down blind hole + bolt shank)
// ========================
// Counterbore opens at z=0 (bed). At z=depth_counterbore the bore
// narrows to bolt diameter — tests the landing shelf overhang.
// Both counterbore and through-hole diameters vary by the same offset.
module bar_counterbore() {
    cell = cell_size(nom_counterbore);
    w = num_steps * cell;
    d = cell;
    h = depth_counterbore + 4;

    difference() {
        cube([w, d, h]);
        for (i = [0:num_steps-1]) {
            cx = i * cell + cell/2;
            offset_i = (i - half_steps) * step_size;
            translate([cx, d/2, -0.1])
                cylinder(d=step_val(nom_counterbore, i),
                         h=depth_counterbore + 0.1);
            translate([cx, d/2, depth_counterbore - 0.01])
                cylinder(d=nom_bolt_through + offset_i,
                         h=h - depth_counterbore + 0.1);
        }
        engrave_front("A5: M4 cbore", w/2, h/2, size=2.5);
        for (i = [0:num_steps-1]) {
            offset_i = (i - half_steps) * step_size;
            // Counterbore diameter on back face
            engrave_back(label_str(nom_counterbore, i),
                         i * cell + cell/2, h/2 + 1.5, d, size=2.5);
            // Through-hole diameter on back face (below counterbore label)
            engrave_back(str("t", nom_bolt_through + offset_i),
                         i * cell + cell/2, h/2 - 1.5, d, size=2.0);
        }
    }
}

// ========================
// A4: Binding Post Keyhole (hole + anti-rotation keyway)
// ========================
module bar_binding_post() {
    d_max = max_dia(nom_bp_hole);
    cell_x = d_max + 2*hole_wall;
    cell_y = d_max + nom_bp_keyway_ext + 2*hole_wall;
    w = num_steps * cell_x;
    d = cell_y;
    h = depth_bp;
    hole_cy = hole_wall + nom_bp_keyway_ext + d_max/2;

    difference() {
        cube([w, d, h]);
        for (i = [0:num_steps-1]) {
            dia = step_val(nom_bp_hole, i);
            kw = step_val(nom_bp_keyway_w, i);
            kw_ext = nom_bp_keyway_ext;  // fixed: bp_keyway_total - nom_bp_hole (not diameter-dependent)
            cx = i * cell_x + cell_x/2;
            translate([cx, hole_cy, -0.1])
                linear_extrude(height = h + 0.2) {
                    circle(d=dia);
                    translate([-kw/2, -dia/2 - kw_ext])
                        square([kw, kw_ext + dia/2]);
                }
        }
        engrave_front("A4: bind post", w/2, h/2, size=2.5);
        for (i = [0:num_steps-1]) {
            // Hole diameter on back face (top line)
            engrave_back(label_str(nom_bp_hole, i),
                         i * cell_x + cell_x/2, h/2 + 1.5, d, size=2.5);
            // Keyway width on back face (bottom line)
            engrave_back(str("k", step_val(nom_bp_keyway_w, i)),
                         i * cell_x + cell_x/2, h/2 - 1.5, d, size=2.0);
        }
    }
}

// ========================
// B1: M3 Heat-Set (horizontal — crossover boss orientation)
// ========================
// Bore enters from Y=0 face horizontally. Labels on top surface
// (may overlap bore area in Z — that's fine, bores are internal).
module bar_m3_horizontal() {
    cell = cell_size(nom_m3_horiz);
    bore_max = max_dia(nom_m3_horiz);
    w = num_steps * cell;
    bore_d = depth_m3_insert + 4;
    d = bore_d;
    h = bore_max + 2*3;

    difference() {
        cube([w, d, h]);
        for (i = [0:num_steps-1]) {
            cx = i * cell + cell/2;
            translate([cx, -0.1, h/2])
                rotate([-90, 0, 0])
                    cylinder(d=step_val(nom_m3_horiz, i),
                             h=depth_m3_insert + 0.1);
        }
        // Labels on top (overlapping bore zone in Z is OK)
        engrave_top("B1: M3 horiz", w/2, d/2, h, size=2.5);
        for (i = [0:num_steps-1])
            engrave_top(label_str(nom_m3_horiz, i),
                       i * cell + cell/2, d - 2.5, h, size=2);
    }
}

// ========================
// C1: Tongue reference piece (mating part)
// ========================
tg_strip_len = 30;  // Test strip length (Y direction)
tg_block_w = 12;    // Block width per groove variant
tg_base_h = 4;      // Base height under tongue/groove (minimized)

module piece_tongue() {
    difference() {
        union() {
            cube([tg_block_w, tg_strip_len, tg_base_h]);
            translate([(tg_block_w - nom_tongue_w)/2, 0, tg_base_h])
                cube([nom_tongue_w, tg_strip_len, nom_tongue_h]);
        }
        engrave_front("TNG", tg_block_w/2, tg_base_h/2, size=2);
    }
}

// ========================
// C2: Groove strip (7 channel widths, connected by base)
// ========================
module piece_grooves() {
    gap = 2;
    base_h = 2;
    top_z = tg_base_h + nom_tongue_h + 2;
    total_w = num_steps * (tg_block_w + gap) - gap;

    difference() {
        union() {
            // Connecting base
            cube([total_w, tg_strip_len, base_h]);

            for (i = [0:num_steps-1]) {
                gw = step_val(nom_groove_w, i);
                tx = i * (tg_block_w + gap);

                difference() {
                    translate([tx, 0, 0])
                        cube([tg_block_w, tg_strip_len, top_z]);
                    // Groove channel runs full length, open at both ends
                    translate([tx + (tg_block_w - gw)/2, -0.1, top_z - nom_groove_d])
                        cube([gw, tg_strip_len + 0.2, nom_groove_d + 0.1]);
                }
            }
        }
        // Diameter labels on front face, below groove cutout
        for (i = [0:num_steps-1])
            engrave_front(label_str(nom_groove_w, i),
                         i * (tg_block_w + gap) + tg_block_w/2,
                         (top_z - nom_groove_d)/2, size=2.5);
        // Group label on back face
        engrave_back("C2: groove", total_w/2, (top_z - nom_groove_d)/2,
                    tg_strip_len, size=2.5);
    }
}

// ========================
// C4: Seal depth strip (7 groove depths, fixed 3.4mm width)
// ========================
// Tests seal compression with the rubber cord. Tongue piece (C1) mates
// with each groove variant. Groove width is locked at nom_groove_w;
// only the seal_depth (space below tongue) varies.
nom_seal_depth = seal_depth;  // center value from enclosure

module piece_seal_depths() {
    gap = 2;
    base_h = 2;
    fixed_gw = nom_groove_w;  // locked groove width (3.4mm nominal)
    top_z = tg_base_h + nom_tongue_h + 2;
    total_w = num_steps * (tg_block_w + gap) - gap;

    difference() {
        union() {
            // Connecting base
            cube([total_w, tg_strip_len, base_h]);

            for (i = [0:num_steps-1]) {
                sd = step_val(nom_seal_depth, i);
                gd = nom_tongue_h + sd;  // total groove depth = tongue + seal
                tx = i * (tg_block_w + gap);

                difference() {
                    translate([tx, 0, 0])
                        cube([tg_block_w, tg_strip_len, top_z]);
                    // Groove channel: fixed width, varying depth
                    translate([tx + (tg_block_w - fixed_gw)/2, -0.1, top_z - gd])
                        cube([fixed_gw, tg_strip_len + 0.2, gd + 0.1]);
                }
            }
        }
        // Seal depth labels on front face
        for (i = [0:num_steps-1])
            engrave_front(label_str(nom_seal_depth, i),
                         i * (tg_block_w + gap) + tg_block_w/2,
                         (top_z - nom_tongue_h - nom_seal_depth)/2, size=2.5);
        // Group label on back face
        engrave_back("C4: seal depth", total_w/2,
                    (top_z - nom_tongue_h - nom_seal_depth)/2,
                    tg_strip_len, size=2.5);
    }
}


// ========================
interlock_h = 2;  // Boss/recess height (matches real interlock)
interlock_steps = 4;  // Clearance variants: 0.1, 0.2, 0.3, 0.4mm/side

module piece_interlock_boss() {
    bs = nom_interlock_dia + 2*hole_wall;
    bh = 4;
    difference() {
        union() {
            cube([bs, bs, bh]);
            translate([bs/2, bs/2, bh])
                cylinder(d=nom_interlock_dia, h=interlock_h);
        }
        engrave_front("BOSS", bs/2, bh/2, size=2);
    }
}

module piece_interlock_recess() {
    bs = nom_interlock_dia + 2*hole_wall;
    bh = 4;
    gap = 2;
    base_h = 2;
    total_w = interlock_steps * (bs + gap) - gap;

    difference() {
        union() {
            // Connecting base
            cube([total_w, bs, base_h]);

            for (i = [0:interlock_steps-1]) {
                clr = 0.1 + i * step_size;
                tx = i * (bs + gap);

                difference() {
                    translate([tx, 0, 0])
                        cube([bs, bs, bh + interlock_h]);
                    translate([tx + bs/2, bs/2, bh])
                        cylinder(d=nom_interlock_dia + 2*clr,
                                 h=interlock_h + 0.1);
                }
            }
        }
        // Clearance labels on front face
        for (i = [0:interlock_steps-1]) {
            clr = 0.1 + i * step_size;
            tx = i * (bs + gap);
            nom_clr = abs(clr - nom_interlock_clr) < 0.01;
            engrave_front(str(clr, nom_clr ? "*" : ""),
                         tx + bs/2, bh/2, size=2);
        }
        // Group label on back face
        engrave_back("C3: recess", total_w/2, bh/2, bs, size=2);
    }
}

// ========================
// PLATE ASSEMBLIES
// ========================

// Compute actual bar depths for layout spacing
_fd_a1_d = cell_size(nom_m4_heatset);
_fd_a2_d = cell_size(nom_m3_heatset);
_fd_a5_d = cell_size(nom_counterbore);
_fd_total = _fd_a1_d + bar_gap + _fd_a2_d + bar_gap + _fd_a5_d;

_th_a4_d = max_dia(nom_bp_hole) + nom_bp_keyway_ext + 2*hole_wall;
_th_total = _th_a4_d;

_hz_d = depth_m3_insert + 4;

_mt_tg = tg_strip_len;
_mt_il = nom_interlock_dia + 2*hole_wall;
_mt_total = _mt_tg + 8 + _mt_il;

module plate_facedown() {
    bar_m4_heatset();
    translate([0, _fd_a1_d + bar_gap, 0])
        bar_m3_heatset();
    translate([0, _fd_a1_d + bar_gap + _fd_a2_d + bar_gap, 0])
        bar_counterbore();
}

module plate_throughhole() {
    bar_binding_post();
}

module plate_horizontal() {
    bar_m3_horizontal();
}

module plate_mating() {
    piece_tongue();
    translate([tg_block_w + 8, 0, 0])
        piece_grooves();
    // Seal depth strip below groove strip (share the same tongue piece)
    groove_strip_w = num_steps * (tg_block_w + 2) - 2;
    translate([tg_block_w + 8 + groove_strip_w + 8, 0, 0])
        piece_seal_depths();

    il_bs = nom_interlock_dia + 2*hole_wall;
    translate([0, _mt_tg + 8, 0])
        piece_interlock_boss();
    translate([il_bs + 8, _mt_tg + 8, 0])
        piece_interlock_recess();
}

// ========================
// COMBINED OUTPUT
// ========================
// All plates arranged with correct spacing. Load in slicer,
// separate objects, and orient each plate as needed.

plate_facedown();

_y2 = _fd_total + bar_gap;
translate([0, _y2, 0]) plate_throughhole();

_y3 = _y2 + _th_total + bar_gap;
translate([0, _y3, 0]) plate_horizontal();

_y4 = _y3 + _hz_d + bar_gap;
translate([0, _y4, 0]) plate_mating();

// ========================
// PRINT & TEST INSTRUCTIONS
// ========================
//
// STEP 1: SLICER SETUP
// --------------------
// Load tolerance-test.stl in your slicer (e.g., Bambu Studio).
// The STL contains multiple separate objects. Separate them and
// orient each group for its intended print orientation:
//
//   A1 + A2 + A5 bars (face-down group):
//     Flip 180° so hole openings face the build plate.
//     This tests ceiling bridging — matching how heatset pockets
//     and counterbores print in the real enclosure (front half
//     baffle-down). The printer must bridge across each hole at
//     the ceiling height.
//
//   A4 bar (binding post):
//     Print flat as-is, no rotation needed. Through-holes are
//     vertical matching the back-wall orientation.
//
//   B1 bar (horizontal heatset):
//     Print as-is with bore openings facing outward (Y=0 face up
//     or to the side). Tests Z-axis bridging at the top of
//     horizontal holes, matching crossover boss orientation.
//
//   Tongue, Groove strip, Interlock boss, Interlock recess:
//     Print flat as-is. These are separate mating pieces.
//
// STEP 2: PRINT SETTINGS
// ----------------------
// Use identical settings to the final enclosure print:
//   Material:     PETG (same brand/color as enclosure)
//   Layer height: 0.2mm
//   Perimeters:   5-6 (matches 10mm wall fill)
//   Infill:       50-80% gyroid
//   Temperature:  Same as your enclosure profile
//
// STEP 3: TEST EACH FEATURE
// -------------------------
// Each bar has 7 variants labeled with their diameter/width.
// The nominal (current design value) is marked with an asterisk (*).
// Test each variant with the actual hardware:
//
//   A1 (M4 heatset, 5.3-5.9mm):
//     Press an M4 heat-set insert into each hole using a soldering
//     iron. The ideal bore: insert pulls in straight with light
//     pressure, sits flush, doesn't wobble. Too tight = insert
//     won't seat; too loose = insert spins or pulls out.
//
//   A2 (M3 heatset, 4.2-4.8mm):
//     Same test with M3 heat-set inserts. Used for tweeter mounting.
//
//   A5 (M4 counterbore, 7.7-8.3mm cbore / 4.2-4.8mm through-hole):
//     Both the counterbore and through-hole diameters vary by the
//     same offset. The back label shows cbore dia + "t" through-hole dia.
//     Drop an M4 bolt head-first into each counterbore. The head
//     should seat flat on the landing shelf with minimal play.
//     Thread the bolt shank through the narrow hole above — it
//     should pass freely. The landing shelf tests the bridging
//     quality (transition from wide counterbore to narrow bolt hole).
//
//   A4 (binding post, 11.4-12.0mm):
//     Insert a Dayton BPP-SNB binding post shaft through each
//     keyhole. The shaft should pass through the round hole, and
//     the anti-rotation tab should engage the keyway slot. Test
//     that the post cannot rotate when the keyway is engaged.
//
//   B1 (M3 horizontal, 4.2-4.8mm):
//     Press M3 heat-set inserts into horizontal bores. These print
//     with bridging at the top of each hole (different behavior
//     from vertical holes). Note if the bore top is rough or
//     undersized from bridging sag.
//
//   Tongue + Groove (C1/C2):
//     Slide the tongue piece into each groove channel from the open
//     end. The nominal groove (3.6*, giving 0.3mm clearance/side)
//     should allow the tongue to slide in smoothly without excessive
//     play. Too tight = tongue won't enter; too loose = rattles.
//
//   Interlock boss + recess (C3):
//     Press the boss piece into each recess variant. The nominal
//     clearance is 0.3*/side. Test for snug slip-fit — the boss
//     should self-center with light hand pressure.
//
// STEP 4: RECORD RESULTS
// ----------------------
// For each feature, note which variant fits best. Compute the
// offset from the nominal value:
//
//   offset = best_fit_diameter - nominal_diameter
//
// Example: if the 5.7mm bore fits your M4 inserts best, and
// the nominal is 5.6mm, the offset is +0.1mm.
//
// STEP 5: APPLY OFFSETS TO ENCLOSURE
// ----------------------------------
// Open speedster-ai.scad and set the tol_* variables at the top:
//
//   tol_heatset_m4_xy = 0.1;   // if 5.7mm fit best (5.6 + 0.1)
//   tol_heatset_m3_xy = 0;     // if 4.5mm was already good
//   tol_heatset_m3_z  = 0.1;   // if horizontal bores need +0.1
//   tol_counterbore   = 0;     // applies to both counterbore & bolt hole
//   tol_binding_post  = 0;     // applies to both hole dia & keyway
//   tol_tongue_groove = -0.1;  // if tighter groove (less clearance) was better
//   tol_interlock     = 0;     // if 0.3mm clearance was correct
//
// These offsets are added to every tolerance-dependent dimension
// in the model. Re-export STLs after setting them:
//   ./export.sh
//
// NOTES
// -----
// - Print the test AND the enclosure on the same printer with
//   the same filament spool. Tolerances vary between printers,
//   materials, and even filament batches.
// - If results are borderline between two variants, choose the
//   looser fit — heat-set inserts melt their way in and the
//   enclosure has more thermal mass than these small test blocks.
// - Re-run this test if you change print settings (layer height,
//   perimeters, temperature) or switch filament brands.
