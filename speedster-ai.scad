// ============================================================
// Paul Carmody's SpeedsterAI - 3D Printed Enclosure
// "Curved-Back Wedge" Design
// 
// Parametric OpenSCAD Design
// Printer: Bambu Lab H2D
// Material: PETG (single material, 10mm walls)
// Seal: Tongue-and-groove joint with foam tape or TPU strip
// 
// Drivers:
//   Woofer:  Tang Band W4-1720 (surface mounted)
//   Tweeter: Fountek NeoCD1.0 (flush mounted, round faceplate)
//
// Target specs:
//   Internal volume: 5.5 liters
//   Port: 1.375" dia x 4.5" long, tuned to ~55 Hz
//   
// Shape: Wide flat baffle tapering to narrow rounded back
// Assembly: Front/back split with tongue-and-groove seal + M4 bolts
//           8 pillar pairs with concentric interlocks at split plane
// ============================================================

// ========================
// COMPONENT ENVELOPES
// ========================
// Clearance envelope models for all internal components.
// Used for fit visualization (render_mode=5), collision assertions,
// and geometric validation (validate.py).
include <component-envelopes.scad>

// ========================
// PARAMETRIC VARIABLES
// ========================

// --- Print-tuned dimensions ---
// Set these to the best-fit values from your tolerance-test.scad print.
// Defaults are the design nominals. After printing the tolerance test,
// replace each value with the number printed on the variant that fits best.
print_m4_heatset_dia  = 5.7;   // A1: M4 heat-set insert bore diameter
print_m3_heatset_dia  = 4.7;   // A2: M3 heat-set insert bore diameter (X/Y plane)
print_m3_heatset_z    = 4.5;   // B1: M3 heat-set insert bore diameter (horizontal/Z axis)
print_counterbore_dia = 8.0;   // A5: bolt head counterbore diameter
print_bolt_dia        = 4.5;   // A5: M4 bolt through-hole diameter (scales with counterbore)
print_bp_hole_dia     = 11.7;  // A4: binding post panel hole diameter
print_bp_keyway_w     = 2.7;   // A4: binding post keyway slot width
print_groove_w        = 3.4;   // C2: groove channel width (fits 3mm seal cord + tongue)
print_interlock_clr   = 0.2;   // C3: interlock clearance per side

// --- Target ---
target_volume_liters = 5.5;

// --- Wall thickness ---
wall = 10;                // PETG wall thickness (mm)

// --- Baffle (front face) dimensions ---
baffle_width = 180;       // External width at front (mm)
baffle_height = 264;      // External height (mm)
baffle_corner_r = 15;     // Corner rounding on front face

// --- Front edge roundover ---
// Smooths baffle-to-side transition to reduce diffraction
// Larger = better diffraction behavior, blends into taper
baffle_roundover = 20;    // Front edge roundover inset (mm) — diffraction control > ~2737 Hz
roundover_depth = 33;     // Depth over which roundover blends to full body (mm)
                          // Decoupled from inset for FDM printability (max overhang ≤ 45°)
baffle_edge_chamfer = 2;  // Small 45° bevel on baffle face edge (mm) — softens front edge
back_edge_chamfer = 2;    // Small 45° bevel on back face edge (mm) — softens rear edge

// --- Back dimensions ---
// NOTE: back_width must accommodate binding posts (30mm spacing + margin)
back_width = 118;         // External width at rear (mm)
back_height = 211;        // External height at rear (mm)
back_corner_r = 17;       // Reduced from 42 for PCB clearance at bottom-back corner

// --- Depth ---
enclosure_depth = 205;    // Total external depth (mm) - extended for tweeter-port clearance and PCB fit

// --- Taper curve ---
// Controls the shape of the wedge taper
// Higher = more volume up front, sharper taper at back
// 1.0 = linear taper, 2.0 = quadratic, 1.5 = gentle curve
taper_power = 2.0;        // TUNED - quadratic taper for 5.5L target

// --- Port parameters ---
port_diameter = 34.925;   // 1.375 inches in mm
port_length = 114.3;      // 4.5 inches in mm
port_wall_thick = 2.5;    // Port tube wall thickness
port_x_offset = 0;        // Centered horizontally
port_y_offset = 52;       // Behind tweeter area (positive = upper) — raised to clear L3 inductor
port_flare_r = 15;        // Radial extent of exit flare at port exit (back face, mm)
port_entry_flare_r = 15;  // Entry chamfer for tweeter clearance + turbulence reduction

// Port reinforcement ribs at back wall junction
port_rib_count = 6;        // Number of gusset ribs around port circumference
port_rib_height = 15;      // Rib extent along port tube from back wall (mm)
port_rib_extent = 10;      // Radial extent beyond port tube outer surface (mm)
port_rib_thick = 2;        // Rib thickness in circumferential direction (mm)

// --- Split plane ---
// Split aligned with front end of port tube so port stays 
// entirely in the back half (no split through the port)
// Port front = enclosure_depth - wall - port_length
split_z = enclosure_depth - wall - port_length;  // ~60.7mm from front

// --- Driver parameters ---

// Tang Band W4-1720 (surface mounted)
// Dimensions from mechanical drawing
woofer_cutout_dia = 96.5;         // Baffle cutout diameter (mm) — +1mm tolerance from 95.5 spec
woofer_flange_dia = 125.5;       // Overall flange OD (mm)
woofer_screw_circle_dia = 115.0; // Screw hole circle diameter (mm)
woofer_screw_dia = 5.2;          // Driver flange hole diameter (mm) - passes M4
woofer_screw_cbore_dia = 8.5;    // Screw counterbore diameter (mm)
woofer_screw_count = 4;          // Number of mounting screws
woofer_flange_thick = 4.5;       // Flange thickness (mm)
woofer_total_depth = 89;         // Total depth behind baffle (mm)
woofer_magnet_dia = 90;          // Magnet diameter for clearance (mm)
woofer_y_offset = -45;           // Below center
// M4 heat-set inserts for woofer mounting
woofer_insert_dia = print_m4_heatset_dia;  // M4 heat-set insert hole diameter
woofer_insert_depth = 8;         // Insert pocket depth (mm) — extra depth to avoid bottoming out

// Fountek NeoCD1.0 (flush mounted, ROUND faceplate)
// Dimensions from mechanical drawing
tweeter_faceplate_dia = 100.5;    // Round faceplate OD (mm) — +0.5mm tolerance from 100 spec
tweeter_cutout_dia = 76;          // Baffle cutout for ribbon access (mm, circular)
tweeter_recess_depth = 4.0;       // Faceplate thickness / flush recess (mm)
tweeter_ribbon_w = 24;            // Ribbon opening width (mm)  
tweeter_ribbon_h = 46;            // Ribbon opening height (mm)
tweeter_screw_spacing = 60.8;     // Square screw pattern spacing (mm)
tweeter_screw_dia = 3.5;          // Driver faceplate hole diameter (mm) - passes M3
tweeter_screw_count = 4;          // 4 screws in square pattern
tweeter_rear_width = 55;          // Rear body width (mm)
tweeter_mount_depth = 70;         // Total depth behind baffle (66 + 4mm faceplate)
tweeter_y_offset = 55;            // Above center
// M3 heat-set inserts for tweeter mounting
tweeter_insert_dia = print_m3_heatset_dia;  // M3 heat-set insert hole diameter
tweeter_insert_depth = 6;         // Insert pocket depth (mm) — extra depth to avoid bottoming out

// --- Assembly hardware ---
bolt_dia = print_bolt_dia;  // M4 through-hole diameter
insert_dia = print_m4_heatset_dia;  // M4 heat-set insert hole
insert_depth = 12;         // Insert pocket depth (pillar bolts, extra clearance for M4×70 bolt)
bolt_landing_dia = print_counterbore_dia;  // Counterbore/landing diameter for bolt head
bolt_inset = 12;           // Distance from edge to bolt center

// --- Tongue-and-groove seal joint ---
// Tongue on front half, groove in back half
// Self-aligning + sealing with 3mm round rubber cord in groove
tongue_width = 3;          // Width of tongue ridge (mm)
tongue_height = 4;         // Tongue protrusion past split face (mm)
tongue_clearance = (print_groove_w - tongue_width) / 2;  // Derived from groove width
seal_dia = 3;              // Rubber seal cord diameter (mm)
seal_depth = 2.8;          // Groove depth below tongue tip for seal (mm)
tongue_inset = 5;          // From outer wall to tongue center (mm)

// --- Direct-mount binding posts (Dayton Audio BPP-SNB) ---
// Two individual posts mounted directly through back wall.
// Panel cutout per manufacturer drawing + 0.2mm print tolerance:
//   2× Ø11.7mm holes, 30mm c-c, with 2.7mm × 14.2mm anti-rotation keyway
bp_hole_dia = print_bp_hole_dia;     // Panel hole diameter (mm)
bp_spacing = 30;                 // Post center-to-center spacing (mm)
bp_keyway_width = print_bp_keyway_w;  // Anti-rotation slot width (mm)
bp_keyway_total = 14.5;          // From hole top to keyway bottom (mm) — 2.8mm extension past hole edge
bp_y_offset = -45;               // Vertical position on back face (same as old terminal)
bp_intrusion = 34;               // Internal protrusion past wall (25mm shaft + 9mm lug)

// --- Crossover PCB mounting ---
// Two PCBs (high-pass and low-pass) separated from V-cut stack,
// mounted on opposing side walls with components facing inward.
// PCB dimensions from gregose/speedster-crossover KiCad layout.
xover_pcb_width = 92;            // PCB width (mm) - maps to Z axis
xover_pcb_height = 126;          // PCB height (mm) - maps to Y axis
xover_pcb_thick = 1.6;           // PCB board thickness (mm) — conservative (actual 1.2mm)
xover_comp_height = 40;          // Max component height, most parts (mm)
xover_comp_height_tall = 50;     // Tallest inductor height (mm)
xover_tall_pcb_y = 80;           // Tall inductor Y position on PCB (from top=0)

// Mounting hole positions on PCB (from top-left corner as 0,0):
//   (43,5), (87,121), (5,121) — 3 holes per board
//   Hole (87,5) omitted: falls in back-bottom corner rounding zone
// Hole diameter: 3.3mm (accepts M3 screws)
xover_holes = [[43,5], [87,121], [5,121]];
xover_hole_dia = 3.3;

// Mounting boss parameters
xover_boss_dia = 10;             // Boss pad diameter (mm)
xover_insert_dia = print_m3_heatset_z;  // M3 heat-set insert hole diameter
xover_insert_depth = 6;          // Insert pocket depth (mm) — extra depth to avoid bottoming out
xover_boss_min_depth = 6;        // Minimum boss depth for insert engagement

// PCB placement in enclosure coordinates
// PCB long axis (126mm) runs vertically (Y), short axis (92mm) along Z
// Board top at y=35, bottom at y=-91 (shifted up to clear back corner rounding)
// Z from 88 to 180 (clears woofer depth, 7mm from inner back wall)
xover_y_top = 26;                // Enclosure Y of PCB top edge (inductor clears port by ~2mm)
xover_z_start = 90;              // Enclosure Z of PCB front edge (clears woofer depth 89.5mm)

// Binding post dimensions (Dayton BPP-SNB)
// Direct-mount through back wall at y=-45, 30mm spacing
// Internal protrusion: 25mm shaft + 9mm terminal lug = 34mm past wall
bp_shaft_length = 25;            // Threaded shaft below flange (mm)
bp_lug_length = 9;               // Terminal lug below shaft (mm)

// --- Rendering ---
$fn = 100;

// ========================
// CORE SHAPE: TAPERED WEDGE
// ========================

// Roundover inset at depth z using compound profile:
//   1. Small 45° chamfer from z=0 to z=baffle_edge_chamfer
//   2. Cubic Hermite spline from z=chamfer to z=roundover_depth
// G1 continuous at junction (both sides have 45° slope).
// Max overhang exactly 45°, monotonically decreasing.
function roundover_inset_at(z) =
    let(c = baffle_edge_chamfer)
    (z < c && c > 0) ?
        // 45° chamfer zone: linear from (roundover + c) to roundover
        baffle_roundover + c - z
    : (z < roundover_depth && roundover_depth > 0) ?
        let(
            f = (z - c) / (roundover_depth - c),
            s = (roundover_depth - c) / baffle_roundover,
            a = 2 - s,
            b = 2*s - 3,
            cc = -s
        )
        baffle_roundover * (a*pow(f,3) + b*pow(f,2) + cc*f + 1)
    : 0;

// Back edge chamfer: linear 45° bevel near back face
// Mirror of the front baffle_edge_chamfer — softens the rear edge
function back_inset_at(z) =
    (back_edge_chamfer > 0 && z > enclosure_depth - back_edge_chamfer) ?
        z - (enclosure_depth - back_edge_chamfer)
    : 0;

// 2D cross-section at depth z (0=front, enclosure_depth=back)
// Smoothly tapers from baffle dims to back dims
// Incorporates front edge roundover and back edge chamfer
module cross_section_at(z) {
    t = z / enclosure_depth;
    t_curved = pow(t, taper_power);
    
    // Base interpolated dimensions (baffle → back taper)
    w_base = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_base = baffle_height * (1 - t_curved) + back_height * t_curved;
    r_base = baffle_corner_r * (1 - t_curved) + back_corner_r * t_curved;
    
    // Combined edge insets: front roundover + back chamfer
    ri = roundover_inset_at(z) + back_inset_at(z);
    
    w = max(0.1, w_base - 2 * ri);
    h = max(0.1, h_base - 2 * ri);
    r_safe = min(r_base, w/2 - 0.1, h/2 - 0.1);
    
    offset(r = r_safe)
        square([max(0.1, w - 2*r_safe), max(0.1, h - 2*r_safe)], center = true);
}

// Build outer shell by hulling adjacent slices
// Uses finer slicing in the roundover zone for smooth curvature
module outer_shape() {
    // Fine slices in roundover zone (now extends to roundover_depth)
    roundover_slices = 20;
    if (roundover_depth > 0) {
        for (i = [0 : roundover_slices - 1]) {
            z0 = roundover_depth * i / roundover_slices;
            z1 = roundover_depth * (i + 1) / roundover_slices;
            hull() {
                translate([0, 0, z0])
                    linear_extrude(height = 0.01)
                        cross_section_at(z0);
                translate([0, 0, z1])
                    linear_extrude(height = 0.01)
                        cross_section_at(z1);
            }
        }
    }
    
    // Regular slices for the rest of the body
    body_slices = 40;
    z_start = max(0.01, roundover_depth);
    for (i = [0 : body_slices - 1]) {
        z0 = z_start + (enclosure_depth - z_start) * i / body_slices;
        z1 = z_start + (enclosure_depth - z_start) * (i + 1) / body_slices;
        hull() {
            translate([0, 0, z0])
                linear_extrude(height = 0.01)
                    cross_section_at(z0);
            translate([0, 0, z1])
                linear_extrude(height = 0.01)
                    cross_section_at(z1);
        }
    }
}

// Inner cavity cross-section (inset by wall thickness)
// Also applies roundover profile so wall thickness stays uniform
module inner_cross_section_at(z) {
    t = z / enclosure_depth;
    t_curved = pow(t, taper_power);
    
    w_outer = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_outer = baffle_height * (1 - t_curved) + back_height * t_curved;
    r_outer = baffle_corner_r * (1 - t_curved) + back_corner_r * t_curved;
    
    ri = roundover_inset_at(z);
    w = w_outer - 2 * wall - 2 * ri;
    h = h_outer - 2 * wall - 2 * ri;
    r = max(1, r_outer - wall);
    r_safe = min(r, max(0.1, w/2 - 0.1), max(0.1, h/2 - 0.1));
    
    if (w > 0.2 && h > 0.2) {
        offset(r = r_safe)
            square([max(0.1, w - 2*r_safe), max(0.1, h - 2*r_safe)], center = true);
    }
}

// Full inner cavity
// IMPORTANT: Uses the same hull slice z-positions as outer_shape() but
// offset by a tiny epsilon (0.001mm). This ensures:
//   1. Hull boundaries nearly align (no visible shelves from mismatched steps)
//   2. No exactly coplanar faces with outer_shape (prevents non-manifold edges)
// Without this alignment, each mismatched hull boundary creates a visible
// horizontal plane artifact in the STL.
module inner_cavity() {
    // Tiny offset to prevent exact coplanarity with outer_shape hull faces
    _eps = 0.001;
    
    // Roundover zone: same 20 slices as outer_shape, clamped to [wall, roundover_depth]
    roundover_slices = 20;
    if (roundover_depth > wall) {
        for (i = [0 : roundover_slices - 1]) {
            z0_raw = roundover_depth * i / roundover_slices + _eps;
            z1_raw = roundover_depth * (i + 1) / roundover_slices + _eps;
            z0 = max(wall, z0_raw);
            z1 = z1_raw;
            if (z0 < z1) {
                hull() {
                    translate([0, 0, z0])
                        linear_extrude(height = 0.01)
                            inner_cross_section_at(z0);
                    translate([0, 0, z1])
                        linear_extrude(height = 0.01)
                            inner_cross_section_at(z1);
                }
            }
        }
    }

    // Body zone: same 40 slices as outer_shape, clamped to [roundover_depth, depth-wall]
    body_slices = 40;
    z_start = max(0.01, roundover_depth);
    for (i = [0 : body_slices - 1]) {
        z0_raw = z_start + (enclosure_depth - z_start) * i / body_slices + _eps;
        z1_raw = z_start + (enclosure_depth - z_start) * (i + 1) / body_slices + _eps;
        z1 = min(enclosure_depth - wall, z1_raw);
        if (z0_raw < z1) {
            hull() {
                translate([0, 0, z0_raw])
                    linear_extrude(height = 0.01)
                        inner_cross_section_at(z0_raw);
                translate([0, 0, z1])
                    linear_extrude(height = 0.01)
                        inner_cross_section_at(z1);
            }
        }
    }
}

// ========================
// DRIVER CUTOUTS
// ========================

// Woofer rear chamfer parameters
woofer_chamfer_start = 3;     // Depth of straight bore before chamfer begins (mm)
                               // Leaves material for screw thread engagement
woofer_chamfer_angle = 45;     // Chamfer angle (degrees from bore wall)
woofer_bore_r = woofer_cutout_dia / 2;
woofer_chamfer_depth = wall - woofer_chamfer_start;
woofer_chamfer_expand = woofer_chamfer_depth * tan(woofer_chamfer_angle);

module woofer_cutout() {
    translate([0, woofer_y_offset, 0]) {
        // Unified bore + rear chamfer as a single solid of revolution
        // Profile: straight bore for woofer_chamfer_start depth,
        // then 45° chamfer widening toward the inside
        rotate_extrude($fn = $fn) {
            // Straight bore section (front face to chamfer start)
            translate([0, -1])
                square([woofer_bore_r, woofer_chamfer_start + 1]);
            
            // 45° chamfer section (widens toward interior)
            translate([0, woofer_chamfer_start])
                polygon([
                    [0, 0],
                    [woofer_bore_r, 0],
                    [woofer_bore_r + woofer_chamfer_expand, woofer_chamfer_depth + 1],
                    [0, woofer_chamfer_depth + 1]
                ]);
        }
        
        // Heat-set insert pockets - 4x M4 on 115mm circle, diamond pattern (45° offset)
        // Blind holes from front face for heat-set inserts
        // M4 screws pass through driver flange into these inserts
        for (i = [0 : woofer_screw_count - 1]) {
            angle = i * (360 / woofer_screw_count) + 45;
            translate([cos(angle) * woofer_screw_circle_dia/2,
                       sin(angle) * woofer_screw_circle_dia/2, -0.1]) {
                cylinder(d = woofer_insert_dia, h = woofer_insert_depth + 0.1);
            }
        }
    }
}

module tweeter_cutout() {
    translate([0, tweeter_y_offset, 0]) {
        // Flush recess for round faceplate (101mm dia, 4mm deep)
        translate([0, 0, -0.1])
            cylinder(d = tweeter_faceplate_dia, h = tweeter_recess_depth + 0.1);
        
        // Through-hole for driver body — two overlapping rectangles to clear
        // the body profile without intersecting the M3 heat-set insert pockets.
        // Narrow tall slot (25×67mm) for the central ribbon/transformer section,
        // plus wide short slot (56×47mm) for the body shoulders.
        // Dimensions include 1mm clearance per side.
        translate([0, 0, -1])
            linear_extrude(height = wall + 2) {
                square([25, 67], center = true);
                square([56, 47], center = true);
            }
        
        // Heat-set insert pockets - 4x M3 in SQUARE pattern (60.8mm x 60.8mm)
        // Pockets start at the recess floor (z = tweeter_recess_depth)
        // and go deeper into the baffle
        // M3 screws pass through faceplate into these inserts
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * tweeter_screw_spacing/2,
                           sy * tweeter_screw_spacing/2,
                           tweeter_recess_depth - 0.1])
                    cylinder(d = tweeter_insert_dia, h = tweeter_insert_depth + 0.1);
    }
}

// ========================
// PORT
// ========================

// The port tube solid adds material inside the cavity for the port walls.
// Extends 1mm past the inner back wall (z = depth - wall + 1) to avoid
// coplanar faces with the inner cavity boundary at z = depth - wall.
// A bell-shaped cone at the entry end provides material for the entry flare.
module port_tube_solid() {
    port_start_z = enclosure_depth - wall - port_length;
    
    // Main straight tube — extended 1mm past inner back wall
    translate([port_x_offset, port_y_offset, port_start_z])
        cylinder(d = port_diameter + 2*port_wall_thick, 
                 h = port_length + 1);
    
    // Entry flare bell: cone from flare mouth diameter to tube diameter
    if (port_entry_flare_r > 0) {
        translate([port_x_offset, port_y_offset, port_start_z])
            cylinder(d1 = port_diameter + 2*port_entry_flare_r + 2*port_wall_thick,
                     d2 = port_diameter + 2*port_wall_thick,
                     h = port_entry_flare_r);
    }
}

// Triangular gusset ribs reinforcing the port tube at the back wall.
// Each rib is a hull of two thin strips: one along the tube outer
// surface (axial) and one along the inner back wall (radial).
// This spreads the tube-to-wall load across more layer lines.
module port_ribs() {
    port_end_z = enclosure_depth - wall;  // inner back wall surface
    tube_outer_r = (port_diameter + 2*port_wall_thick) / 2;
    
    translate([port_x_offset, port_y_offset, 0])
    for (i = [0:port_rib_count-1]) {
        rotate([0, 0, i * 360/port_rib_count])
        hull() {
            // Vertical strip on port tube outer surface
            translate([tube_outer_r - 0.5, -port_rib_thick/2,
                       port_end_z - port_rib_height])
                cube([1, port_rib_thick, port_rib_height]);
            // Horizontal strip on inner back wall
            translate([tube_outer_r, -port_rib_thick/2,
                       port_end_z - 1])
                cube([port_rib_extent, port_rib_thick, 1]);
        }
    }
}

// Unified port bore + flares as a single solid of revolution.
// 2D profile in the r-z plane (r = radial distance from port axis):
//   - Entry flare: quarter-circle from bore wall outward at the cavity face
//   - Straight bore wall (r = port_diameter/2) between flares
//   - Exit flare: 45° linear chamfer within the back wall thickness
// This is subtracted from the enclosure in one operation.
module port_bore() {
    // Z coordinates (absolute, along enclosure depth axis)
    port_start_z = enclosure_depth - wall - port_length;
    inner_back_z = enclosure_depth - wall;  // inner back wall surface
    back_face_z = enclosure_depth;
    
    bore_r = port_diameter / 2;
    // 45° chamfer: expands 1mm radially per 1mm depth, confined to wall
    exit_chamfer_r = wall;  // max radial expansion = wall thickness
    
    translate([port_x_offset, port_y_offset, 0]) {
        rotate_extrude($fn = $fn) {
            // Build the 2D bore+flare profile as a union of shapes
            // All in the positive-r half-plane (required by rotate_extrude)
            
            // 1. Straight bore: rectangle from port entrance to inner back wall
            translate([0, port_start_z - 1])
                square([bore_r, inner_back_z - port_start_z + 1]);
            
            // 2. Entry flare (cavity-side bell):
            //    Quarter-circle concave curve from bore_r + entry_flare_r
            //    at the port mouth (z=port_start_z) down to bore_r at
            //    z = port_start_z + entry_flare_r (where straight bore begins)
            if (port_entry_flare_r > 0) {
                translate([0, port_start_z - 1])
                    difference() {
                        square([bore_r + port_entry_flare_r,
                                port_entry_flare_r + 1]);
                        translate([bore_r + port_entry_flare_r,
                                   port_entry_flare_r + 1])
                            circle(r = port_entry_flare_r, $fn = 60);
                    }
            }
            
            // 3. Exit flare: 45° linear chamfer within back wall with fillet.
            //    A R=10mm fillet smooths the bore-to-chamfer junction.
            //    The fillet center sits ~4.1mm before inner_back_z, tangent to
            //    both the vertical bore wall and the 45° chamfer line.
            //    Arc sweeps clockwise from 180° (bore tangent) to 135° (chamfer tangent).
            fillet_r = 10;
            _fc_r = bore_r + fillet_r;
            _fc_z_off = fillet_r * (1 - sqrt(2));  // ~-2.9mm
            
            _arc_steps = 12;
            _arc_pts = [for (i = [0:_arc_steps])
                let(a = 180 - i * 45 / _arc_steps)
                [_fc_r + fillet_r * cos(a),
                 inner_back_z + _fc_z_off + fillet_r * sin(a)]];
            
            // Extend straight bore to fillet tangent point
            translate([0, inner_back_z + _fc_z_off])
                square([bore_r, -_fc_z_off + 0.001]);
            
            // Fillet arc + chamfer as single closed polygon
            polygon(concat(
                [[0, inner_back_z + _fc_z_off]],
                [[bore_r, inner_back_z + _fc_z_off]],
                _arc_pts,
                [[bore_r + exit_chamfer_r, back_face_z + 1]],
                [[0, back_face_z + 1]]
            ));
        }
    }
}

// ========================
// BINDING POST HOLES
// ========================

module binding_post_holes() {
    // Two keyhole-shaped through-holes on the back face
    // Each is a Ø11.7mm circle + 2.7mm wide anti-rotation slot
    bp_r = bp_hole_dia / 2;
    slot_ext = bp_keyway_total - bp_hole_dia;  // extension past hole edge
    
    for (sx = [-1, 1]) {
        translate([sx * bp_spacing/2, bp_y_offset, enclosure_depth - wall - 1]) {
            linear_extrude(height = wall + 2) {
                // Main hole
                circle(d = bp_hole_dia);
                // Anti-rotation keyway extending downward
                // Overlaps into circle center so the union is continuous
                translate([-bp_keyway_width/2, -bp_r - slot_ext])
                    square([bp_keyway_width, slot_ext + bp_r]);
            }
        }
    }
}

// ========================
// BOLT PATTERN (SPLIT-PLANE PERIMETER)
// ========================

// 8 bolts around the perimeter of the split plane cross-section.
// Bolt from BACK through back half wall → into heat-set inserts in front pillars.
// Pillars in front half run from baffle to split face; back pillars match.
module bolt_positions() {
    t = split_z / enclosure_depth;
    t_curved = pow(t, taper_power);
    w_at_split = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_at_split = baffle_height * (1 - t_curved) + back_height * t_curved;
    
    positions = [
        // Top and bottom center
        [0, h_at_split/2 - bolt_inset],
        [0, -(h_at_split/2 - bolt_inset)],
        // Left and right center  
        [w_at_split/2 - bolt_inset, 0],
        [-(w_at_split/2 - bolt_inset), 0],
        // Four corners (inset from edges)
        [w_at_split/2 - bolt_inset, h_at_split/2 - bolt_inset - 15],
        [-(w_at_split/2 - bolt_inset), h_at_split/2 - bolt_inset - 15],
        [w_at_split/2 - bolt_inset, -(h_at_split/2 - bolt_inset - 15)],
        [-(w_at_split/2 - bolt_inset), -(h_at_split/2 - bolt_inset - 15)],
    ];
    
    for (pos = positions) {
        translate([pos[0], pos[1], 0])
            children();
    }
}

// Through-holes for bolt shanks through the back half
module bolt_through_holes() {
    bolt_positions()
        translate([0, 0, split_z - 1])
            cylinder(d = bolt_dia, h = enclosure_depth - split_z + 2);
}

// Counterbores on the back exterior for bolt heads
// The enclosure tapers, so bolts exit through angled side walls.
// Strategy: find the z depth where the cross-section still provides
// at least 4mm of material around each bolt center (enough for an 8mm
// landing), then cut an 8mm cylinder from that z all the way to the back.
// This creates a flat perpendicular face at the right depth in the wall.
// The bolt head sits on this flat; slight overhang past the curve is OK.

// Function to find the deepest z where the cross-section edge is at least
// 'clearance' mm from a point (px, py). Uses the taper formula.
// Returns the z where the bolt center has exactly 'clearance' to the edge.
function landing_z(px, py, clearance) = 
    let(
        // For the x-direction: find z where half-width = abs(px) + clearance
        target_w = 2 * (abs(px) + clearance),
        // w(z) = baffle_width*(1-tc) + back_width*tc = target_w
        // tc = (baffle_width - target_w) / (baffle_width - back_width)
        tc_x = (abs(px) < 0.1) ? 1 :
               (baffle_width - target_w) / (baffle_width - back_width),
        
        // For the y-direction: find z where half-height = abs(py) + clearance  
        target_h = 2 * (abs(py) + clearance),
        tc_y = (abs(py) < 0.1) ? 1 :
               (baffle_height - target_h) / (baffle_height - back_height),
        
        // Use whichever constraint is tighter (smaller tc = shallower z)
        tc = max(0.001, min(tc_x, tc_y)),
        z = enclosure_depth * pow(tc, 1/taper_power)
    ) z;

// Uniform landing z: use the shallowest (most restrictive) bolt position
// so all bolts are the same length. Computed by finding the minimum
// landing_z across all 8 bolt positions.
function min_landing_z() = 
    let(
        t = split_z / enclosure_depth,
        t_curved = pow(t, taper_power),
        w = baffle_width * (1 - t_curved) + back_width * t_curved,
        h = baffle_height * (1 - t_curved) + back_height * t_curved,
        positions = [
            [0, h/2 - bolt_inset],
            [0, -(h/2 - bolt_inset)],
            [w/2 - bolt_inset, 0],
            [-(w/2 - bolt_inset), 0],
            [w/2 - bolt_inset, h/2 - bolt_inset - 15],
            [-(w/2 - bolt_inset), h/2 - bolt_inset - 15],
            [w/2 - bolt_inset, -(h/2 - bolt_inset - 15)],
            [-(w/2 - bolt_inset), -(h/2 - bolt_inset - 15)],
        ],
        zs = [for (p = positions) landing_z(p[0], p[1], bolt_landing_dia/2)]
    ) min(zs);

module bolt_counterbores() {
    cut_z = min_landing_z();
    
    bolt_positions()
        translate([0, 0, cut_z])
            cylinder(d = bolt_landing_dia, h = enclosure_depth - cut_z + 1);
}

// Heat-set insert pockets in the FRONT half at the split face
module insert_pockets() {
    bolt_positions()
        translate([0, 0, split_z - insert_depth])
            cylinder(d = insert_dia, h = insert_depth + 0.1);
}

// ========================
// PILLAR SYSTEM
// ========================

// Front pillars: baffle inner wall to split face
// Back pillars: split face into back half with taper
// Each pair meets at split plane with interlock boss/recess
pillar_dia = 16;          // Outer diameter of support pillar (mm)
pillar_length = split_z - wall;  // Front pillar length

// Pillar interlock: boss on BACK half, recess on FRONT half (insert side)
// This prevents heat-set insert expansion from interfering with the fit —
// expansion around the recess is absorbed by clearance, while the boss
// on the non-insert side stays at nominal dimensions.
pillar_interlock_dia = 10;    // Boss/recess outer diameter (mm)
pillar_interlock_h = 2;       // Boss height / recess depth (mm)
pillar_interlock_clearance = print_interlock_clr;  // Gap per side for print tolerance

// Back pillar extends from split face into back half
back_pillar_depth = 30;       // Functional depth from split face (increased for coverage)

// Taper on back pillars for overhang-free printing — gradual blend into wall
back_pillar_taper_angle = 15;  // Degrees from vertical (gentler = longer taper)
back_pillar_taper_h = (pillar_dia/2) / tan(back_pillar_taper_angle);

// Front pillars: solid cylinders from inner baffle to split face
module insert_pillars() {
    bolt_positions()
        translate([0, 0, wall])
            cylinder(d = pillar_dia, h = pillar_length);
}

// Back pillars: from split face into back cavity with 15° taper
module back_pillars() {
    bolt_positions()
        translate([0, 0, split_z]) {
            cylinder(d = pillar_dia, h = back_pillar_depth);
            translate([0, 0, back_pillar_depth])
                cylinder(d1 = pillar_dia, d2 = 0, h = back_pillar_taper_h);
        }
}

// Interlock RECESS on front pillars at split face (insert side)
// The recess absorbs any heat-set insert expansion
module pillar_interlock_recesses() {
    bolt_positions()
        translate([0, 0, split_z - pillar_interlock_h - 0.1])
            cylinder(d = pillar_interlock_dia + 2*pillar_interlock_clearance, 
                     h = pillar_interlock_h + 0.2);
}

// Interlock BOSS on back pillars at split face (no insert, stays nominal)
// Protrudes past split_z into front half territory
module pillar_interlock_bosses() {
    bolt_positions()
        translate([0, 0, split_z - pillar_interlock_h - 0.01])
            difference() {
                cylinder(d = pillar_interlock_dia, h = pillar_interlock_h + 0.01);
                // Clear the bolt through-hole
                translate([0, 0, -0.1])
                    cylinder(d = bolt_dia + 1, h = pillar_interlock_h + 0.3);
            }
}

// ========================
// TONGUE-AND-GROOVE SEAL JOINT
// ========================

// 2D ring at the split plane, centered within the wall thickness.
// Uses the outer and inner cross-sections at split_z, then creates
// a ring at a specified width centered between them.
// tongue_inset = distance from outer wall surface to ring center.
module seal_ring_2d(ring_width) {
    // Get outer cross-section dimensions at the split plane
    t = split_z / enclosure_depth;
    t_curved = pow(t, taper_power);
    w_out = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_out = baffle_height * (1 - t_curved) + back_height * t_curved;
    r_out = baffle_corner_r * (1 - t_curved) + back_corner_r * t_curved;
    r_out_safe = min(r_out, w_out/2 - 0.1, h_out/2 - 0.1);
    
    // The ring center sits tongue_inset mm inside the outer surface
    // Outer edge of ring: inset by (tongue_inset - ring_width/2) from outer
    // Inner edge of ring: inset by (tongue_inset + ring_width/2) from outer
    inset_outer = tongue_inset - ring_width/2;
    inset_inner = tongue_inset + ring_width/2;
    
    w_ring_out = w_out - 2 * inset_outer;
    h_ring_out = h_out - 2 * inset_outer;
    r_ring_out = max(1, r_out_safe - inset_outer);
    
    w_ring_in = w_out - 2 * inset_inner;
    h_ring_in = h_out - 2 * inset_inner;
    r_ring_in = max(1, r_out_safe - inset_inner);
    
    difference() {
        // Outer edge of ring
        offset(r = min(r_ring_out, w_ring_out/2 - 0.1, h_ring_out/2 - 0.1))
            square([max(0.1, w_ring_out - 2*min(r_ring_out, w_ring_out/2 - 0.1, h_ring_out/2 - 0.1)),
                    max(0.1, h_ring_out - 2*min(r_ring_out, w_ring_out/2 - 0.1, h_ring_out/2 - 0.1))], center = true);
        // Inner edge of ring
        offset(r = min(r_ring_in, w_ring_in/2 - 0.1, h_ring_in/2 - 0.1))
            square([max(0.1, w_ring_in - 2*min(r_ring_in, w_ring_in/2 - 0.1, h_ring_in/2 - 0.1)),
                    max(0.1, h_ring_in - 2*min(r_ring_in, w_ring_in/2 - 0.1, h_ring_in/2 - 0.1))], center = true);
    }
}

// Tongue: raised ridge on the front half's split face
// Protrudes toward the back half
module tongue() {
    translate([0, 0, split_z - 0.01])
        linear_extrude(height = tongue_height + 0.01)
            seal_ring_2d(tongue_width);
}

// Groove: channel cut into the back half's split face
// Wider than tongue by 2x clearance, deeper by seal_depth
// 3mm rubber seal cord sits in the bottom of the groove
module groove() {
    groove_width = tongue_width + 2 * tongue_clearance;
    groove_depth = tongue_height + seal_depth;
    translate([0, 0, split_z - 0.1])
        linear_extrude(height = groove_depth + 0.1)
            seal_ring_2d(groove_width);
}

// ========================
// CROSSOVER PCB MOUNTING BOSSES
// ========================

// Helper: compute inner half-width at a given z depth
function inner_half_w_at(z) = 
    let(
        t = z / enclosure_depth,
        tc = pow(t, taper_power),
        w_outer = baffle_width * (1 - tc) + back_width * tc
    ) (w_outer - 2 * wall) / 2;

// Helper: compute inner half-height at a given z depth
function inner_half_h_at(z) =
    let(
        t = z / enclosure_depth,
        tc = pow(t, taper_power),
        h_outer = baffle_height * (1 - tc) + back_height * tc
    ) (h_outer - 2 * wall) / 2;

// Helper: compute inner corner radius at a given z depth
function inner_corner_r_at(z) =
    let(
        t = z / enclosure_depth,
        tc = pow(t, taper_power),
        r_outer = baffle_corner_r * (1 - tc) + back_corner_r * tc
    ) max(0, r_outer - wall);

// Helper: actual inner wall x-position at (z, y), accounting for corner rounding.
// In the flat wall zone, returns inner_half_w_at(z).
// In the corner zone, returns the reduced x from the rounded corner arc.
function inner_wall_x_at(z, y) =
    let(
        ihw = inner_half_w_at(z),
        ihh = inner_half_h_at(z),
        icr = inner_corner_r_at(z),
        abs_y = abs(y),
        corner_y = ihh - icr
    ) (abs_y <= corner_y) ? ihw
      : (abs_y >= ihh) ? ihw - icr
      : let(dy = abs_y - corner_y,
            dx = sqrt(max(0, icr * icr - dy * dy)))
        (ihw - icr) + dx;

// Helper: minimum inner wall x within the boss cylinder envelope at (z, y).
// Samples the 4 cardinal points of the boss cylinder (±boss_r in Y and Z)
// plus the center, returning the minimum. This ensures the boss cylinder
// doesn't protrude past the wall at any point along its perimeter.
function min_wall_x_in_boss(z, y) =
    let(
        br = xover_boss_dia / 2,
        samples = [
            inner_wall_x_at(z, y),
            inner_wall_x_at(z + br, y),
            inner_wall_x_at(z - br, y),
            inner_wall_x_at(z, y + br),
            inner_wall_x_at(z, y - br),
            inner_wall_x_at(z + br * 0.707, y + br * 0.707),
            inner_wall_x_at(z + br * 0.707, y - br * 0.707),
            inner_wall_x_at(z - br * 0.707, y + br * 0.707),
            inner_wall_x_at(z - br * 0.707, y - br * 0.707)
        ]
    ) min(samples);

// Convert PCB hole coordinates to enclosure coordinates.
// sign: -1 for left wall, +1 for right wall
//
// Both PCBs are rotated 180° in-plane (flipped top-to-bottom and
// left-to-right) so components clear the binding post hardware.
//
// Left wall:  components face +x (inward). PCB bottom-right (W,H)
//   maps to enclosure (z_start, y_top).
//
// Right wall: components face -x (inward). Additionally mirrored
//   around the vertical axis (flipping pcb_x) so the component side
//   faces inward.
//
// Returns [enc_z, enc_y]
function xover_hole_enc(hole, sign) = 
    let(
        // 180° in-plane rotation: flip both pcb_x and pcb_y
        // Then left wall (sign<0) uses pcb_x as-is, right wall flips for mirror
        pcb_x = (sign < 0) ? hole[0] : (xover_pcb_width - hole[0]),
        pcb_y = xover_pcb_height - hole[1]
    )
    [xover_z_start + pcb_x, xover_y_top - pcb_y];

// Find the PCB face x-position magnitude.
// Uses the narrowest envelope-aware wall x across all hole positions
// for BOTH orientations, minus minimum boss depth.
// Returns a POSITIVE value; actual face_x is ±this value.
function xover_pcb_face_x_abs() =
    let(
        // Compute minimum wall x within boss envelope at each hole
        left_wxs = [for (h = xover_holes)
            let(ez = xover_z_start + h[0],
                ey = xover_y_top - (xover_pcb_height - h[1]))
            min_wall_x_in_boss(ez, ey)],
        right_wxs = [for (h = xover_holes)
            let(ez = xover_z_start + (xover_pcb_width - h[0]),
                ey = xover_y_top - (xover_pcb_height - h[1]))
            min_wall_x_in_boss(ez, ey)],
        min_wx = min([each left_wxs, each right_wxs])
    ) min_wx - xover_boss_min_depth;

// Crossover mounting bosses for ONE side wall.
// Each boss is a cylinder extending from the curved inner wall surface
// inward to a common flat PCB mounting face, plus a 45° triangular brace
// above each boss (in +Z direction, toward split plane) for print support.
//
// Back half prints with back wall DOWN on build plate, so Z DECREASES
// going upward during printing. Bosses near the back wall print first;
// bosses near the split plane print last. Each boss needs support from
// the +Z side (material already printed below it = closer to back wall).
//
// sign: -1 for left wall, +1 for right wall
module xover_bosses(sign) {
    face_abs = xover_pcb_face_x_abs();
    
    for (h = xover_holes) {
        enc = xover_hole_enc(h, sign);
        ez = enc[0];  // enclosure z
        ey = enc[1];  // enclosure y
        // Use center wall position for boss wall-side placement so the
        // boss fully connects to the wall surface, even in corner zones
        // where the wall curves inward. The boss may protrude slightly
        // into the shell at perimeter points — this merges with the wall
        // via the union. face_abs is still based on min_wall_x to ensure
        // minimum boss depth for insert engagement.
        hw = inner_wall_x_at(ez, ey);
        
        // Boss spans from actual wall inner surface to PCB face
        boss_len = hw - face_abs;
        
        if (boss_len > 1) {  // skip if boss doesn't fit
            // Brace extends in +Z direction from the bottom of the boss
            // (ez + boss_dia/2) so the full cylinder is supported at 45°
            boss_r = xover_boss_dia / 2;
            brace_avail = (enclosure_depth - wall) - (ez + boss_r) - 0.5;
            brace_h = min(boss_len, brace_avail);
            
            // Clamp D-flat position to not exceed back inner wall
            flat_z = min(ez + boss_r, enclosure_depth - wall - 0.01);
            
            if (sign < 0) {
                // Left wall: wall at x=-hw, face at x=-face_abs
                hull() {
                    translate([-hw, ey, ez])
                        rotate([0, 90, 0])
                            cylinder(d = xover_boss_dia, h = boss_len);
                    translate([-hw, ey - boss_r, flat_z])
                        cube([boss_len, xover_boss_dia, 0.01]);
                }
                if (brace_h > 0.5) {
                    hull() {
                        translate([-hw, ey - boss_r, flat_z])
                            cube([0.01, xover_boss_dia, brace_h]);
                        translate([-face_abs - 0.01, ey - boss_r, flat_z])
                            cube([0.01, xover_boss_dia, 0.01]);
                    }
                }
            } else {
                // Right wall: wall at x=+hw, face at x=+face_abs
                hull() {
                    translate([face_abs, ey, ez])
                        rotate([0, 90, 0])
                            cylinder(d = xover_boss_dia, h = boss_len);
                    translate([face_abs, ey - boss_r, flat_z])
                        cube([boss_len, xover_boss_dia, 0.01]);
                }
                if (brace_h > 0.5) {
                    hull() {
                        translate([hw - 0.01, ey - boss_r, flat_z])
                            cube([0.01, xover_boss_dia, brace_h]);
                        translate([face_abs, ey - boss_r, flat_z])
                            cube([0.01, xover_boss_dia, 0.01]);
                    }
                }
            }
        }
    }
}

// Heat-set insert pockets in crossover bosses.
// Pocket is bored into the PCB-facing end of each boss.
// The pocket goes INTO the boss from the flat face toward the wall.
// Skips holes where the boss was too short to create.
module xover_insert_pockets(sign) {
    face_abs = xover_pcb_face_x_abs();
    
    for (h = xover_holes) {
        enc = xover_hole_enc(h, sign);
        ez = enc[0];
        ey = enc[1];
        hw = min_wall_x_in_boss(ez, ey);
        boss_len = hw - face_abs;
        
        if (boss_len > 1) {  // only bore if boss exists
            if (sign < 0) {
                translate([-face_abs, ey, ez])
                    rotate([0, -90, 0])
                        cylinder(d = xover_insert_dia, h = xover_insert_depth + 0.1);
            } else {
                translate([face_abs, ey, ez])
                    rotate([0, 90, 0])
                        cylinder(d = xover_insert_dia, h = xover_insert_depth + 0.1);
            }
        }
    }
}

// Both sets of crossover bosses (left and right walls)
module xover_bosses_all() {
    xover_bosses(-1);  // Left wall (PCB flipped so components face +x inward)
    xover_bosses(+1);  // Right wall (PCB normal, components face -x inward)
}

module xover_insert_pockets_all() {
    xover_insert_pockets(-1);
    xover_insert_pockets(+1);
}

// ========================
// INTERNAL BAFFLE RIBS
// ========================
// Integral stiffening ribs on the inner baffle surface to reduce panel
// resonance. The flat baffle (180×264mm) is the largest unsupported panel;
// these ribs break it into smaller zones with higher natural frequencies.
//
// Layout:
//   A) Horizontal bridge between drivers (y=10, gap between bores)
//   B) Two vertical ribs at x=±55 (clear both driver bores)
//   C) Four diagonal stubs from woofer bore edge at ±45°
//
// Ribs have an isosceles trapezoid cross-section (wider at baffle base,
// tapering to narrower tip). 9mm base × 3mm tip × 10mm tall from inner
// baffle wall (z=wall to z=wall+10).
// Clipped to inner cavity so they don't protrude past the tapered walls.
// Front half prints baffle-down, so ribs grow upward — no overhang issues.

baffle_rib_width = 3;       // Rib thickness at top/tip (mm)
baffle_rib_base_width = 9;  // Rib thickness at baffle base (mm) — trapezoidal profile
baffle_rib_height = 10;     // Rib depth from inner baffle surface (mm)

module baffle_ribs() {
    // Spoke-to-pillar rib pattern: radial ribs from the woofer ring
    // to each bolt/pillar position. Structurally optimal — distributes
    // woofer motor load directly to the fastener points.
    //
    // Layout:
    //   - Concentric ring (R=60mm) around woofer bore
    //   - 7 radial spokes from ring edge to pillar positions
    //     (top center pillar skipped — spoke would cross tweeter bore)

    // C) Concentric ring rib around woofer bore
    // R=60mm sits just outside the 45° chamfer expansion zone (~55mm at inner wall)
    // and inside the woofer screw circle (R=57.5). Intersects spokes to tie
    // the structure into a unified web.
    woofer_ring_r = 60;
    translate([0, woofer_y_offset, wall])
        difference() {
            cylinder(r1=woofer_ring_r + baffle_rib_base_width/2,
                     r2=woofer_ring_r + baffle_rib_width/2,
                     h=baffle_rib_height, $fn=64);
            translate([0, 0, -0.1])
                cylinder(r1=woofer_ring_r - baffle_rib_base_width/2,
                         r2=woofer_ring_r - baffle_rib_width/2,
                         h=baffle_rib_height + 0.2, $fn=64);
        }

    // Radial spokes from ring edge to pillar positions
    // Uses the same bolt_positions() logic to find pillar locations
    t_sp = split_z / enclosure_depth;
    tc_sp = pow(t_sp, taper_power);
    w_sp = baffle_width * (1 - tc_sp) + back_width * tc_sp;
    h_sp = baffle_height * (1 - tc_sp) + back_height * tc_sp;

    pillar_pts = [
        // Skip top center [0, h_sp/2 - bolt_inset] — spoke crosses tweeter bore
        [0, -(h_sp/2 - bolt_inset)],                          // bottom center
        [w_sp/2 - bolt_inset, 0],                              // right center
        [-(w_sp/2 - bolt_inset), 0],                           // left center
        [w_sp/2 - bolt_inset, h_sp/2 - bolt_inset - 15],      // top-right
        [-(w_sp/2 - bolt_inset), h_sp/2 - bolt_inset - 15],   // top-left
        [w_sp/2 - bolt_inset, -(h_sp/2 - bolt_inset - 15)],   // bottom-right
        [-(w_sp/2 - bolt_inset), -(h_sp/2 - bolt_inset - 15)],// bottom-left
    ];

    for (pt = pillar_pts) {
        // Direction from woofer center to pillar
        dx = pt[0];
        dy = pt[1] - woofer_y_offset;
        dist = sqrt(dx*dx + dy*dy);
        // Start point: ring outer edge
        sx = (dx/dist) * woofer_ring_r;
        sy = woofer_y_offset + (dy/dist) * woofer_ring_r;

        hull() {
            translate([sx, sy, wall])
                cylinder(d1=baffle_rib_base_width, d2=baffle_rib_width, h=baffle_rib_height, $fn=16);
            translate([pt[0], pt[1], wall])
                cylinder(d1=baffle_rib_base_width, d2=baffle_rib_width, h=baffle_rib_height, $fn=16);
        }
    }
}

// ========================
// FULL ENCLOSURE (ASSEMBLED)
// ========================

module full_enclosure() {
    difference() {
        union() {
            // Main shell
            difference() {
                outer_shape();
                inner_cavity();
            }
            
            // Port tube (added to shell)
            intersection() {
                outer_shape();
                port_tube_solid();
            }
            
            // Port reinforcement ribs at back wall junction
            intersection() {
                inner_cavity();
                port_ribs();
            }
            
            // Front pillar bosses (inside front half)
            intersection() {
                inner_cavity();
                insert_pillars();
            }
            
            // Internal baffle stiffening ribs (inside front half)
            intersection() {
                inner_cavity();
                baffle_ribs();
            }
            
            // Back pillar bosses (inside back half)
            intersection() {
                inner_cavity();
                back_pillars();
            }
            
            // Crossover PCB mounting bosses (both side walls)
            // Added directly without inner_cavity intersection to avoid
            // coplanar faces between boss cylinder facets and cavity hull
            // boundaries, which create horizontal plane artifacts in STL.
            // Bosses are already positioned within the cavity (from inner
            // wall surface to PCB face), so clipping is unnecessary.
            xover_bosses_all();
        }
        
        // Subtract all cutouts
        woofer_cutout();
        tweeter_cutout();
        port_bore();
        binding_post_holes();
        bolt_through_holes();
        insert_pockets();
        
        // Crossover mount insert pockets
        xover_insert_pockets_all();
    }
}

// ========================
// SPLIT INTO HALVES
// ========================

// Cutting block: everything in front of split plane
module front_block() {
    translate([-500, -500, -1])
        cube([1000, 1000, split_z + 1]);
}

// Cutting block: everything behind split plane
module back_block() {
    translate([-500, -500, split_z])
        cube([1000, 1000, 1000]);
}

// --- Front half (baffle side) ---
// Contains: baffle, driver cutouts, front pillars with heat-set pockets
// Tongue protrudes from split face for alignment and sealing
// Interlock recesses in each pillar face accept bosses from back half
// No visible hardware on front face
module front_half() {
    difference() {
        union() {
            intersection() {
                full_enclosure();
                front_block();
            }
            // Add tongue ridge on split face
            intersection() {
                outer_shape();  // Keep tongue within enclosure outline
                tongue();
            }
        }
        // Cut interlock recesses into front pillar faces
        pillar_interlock_recesses();
    }
}

// --- Back half ---
// Contains: port tube (intact), binding post holes, back pillars,
// bolt holes + counterbores
// Groove in split face accepts tongue from front half
// Interlock bosses protrude from each back pillar toward front half
module back_half() {
    union() {
        difference() {
            intersection() {
                full_enclosure();
                back_block();
            }
            // Counterbores for bolt heads on back exterior
            bolt_counterbores();
            // Cut groove into split face for tongue + seal strip
            groove();
        }
        // Add interlock bosses on back pillar faces
        // These protrude past split_z into front half territory
        pillar_interlock_bosses();
    }
}

// ========================
// SEAL VISUALIZATION
// ========================

// 3D tongue-and-groove joint for visualization
module seal_joint_3d() {
    color("Gold", 0.9) tongue();
    color("DarkOrange", 0.5) groove();
}

// ========================
// WHAT TO RENDER / EXPORT
// ========================

// render_mode controls what is displayed:
//   0 = Full assembled (default)
//   1 = Exploded view (front/back separated)
//   2 = Front half only
//   3 = Back half only
//   4 = Inner cavity (for volume check)
//   5 = Component fit (ghost shell + colored envelopes)
//   6 = Front half + components (woofer, tweeter)
//   7 = Back half + components (port, binding posts, crossover)
// Override from CLI: openscad -D render_mode=1 ...
render_mode = 0;

// validation_export: when > 0, exports individual component envelopes
// for geometric collision detection (validate.py). Overrides render_mode.
//   0 = normal (render_mode controls)
//   1 = inner cavity only
//   2 = woofer envelope
//   3 = tweeter envelope
//   4 = binding post envelopes
//   5 = crossover HP envelope (right wall)
//   6 = crossover LP envelope (left wall)
//   7 = port tube envelope
// Override from CLI: openscad -D validation_export=2 ...
validation_export = 0;

// Display rotation: model uses Y=vertical, but OpenSCAD screen uses Z=up.
// rotate([90,0,0]) stands the speaker upright for PNG renders (tweeter on top).
// After rotation: X=horizontal, Y=depth(0=baffle,-197=back), Z=height.
// Model center: (0, -98.5, 0). See render.sh for standard camera angles.
// For STL export, set render_mode and don't apply this rotation.

if (validation_export > 0) {
    // Export individual components for geometric validation (no rotation)
    if (validation_export == 1) {
        inner_cavity();
    } else if (validation_export == 2) {
        woofer_envelope();
    } else if (validation_export == 3) {
        tweeter_envelope();
    } else if (validation_export == 4) {
        binding_post_envelopes();
    } else if (validation_export == 5) {
        crossover_envelope_hp();
    } else if (validation_export == 6) {
        crossover_envelope_lp();
    } else if (validation_export == 7) {
        port_envelope();
    }
} else {
    rotate([90, 0, 0])
    if (render_mode == 0) {
        // Full assembled visualization
        color("SlateBlue", 0.7) full_enclosure();
    } else if (render_mode == 1) {
        // Exploded view (shows pillar interlocks + tongue-and-groove)
        translate([0, 0, -40]) color("SteelBlue", 0.8) front_half();
        translate([0, 0, 40]) color("CornflowerBlue", 0.8) back_half();
    } else if (render_mode == 2) {
        // Front half (baffle side)
        color("SteelBlue", 0.8) front_half();
    } else if (render_mode == 3) {
        // Back half
        color("CornflowerBlue", 0.8) back_half();
    } else if (render_mode == 4) {
        // Inner cavity only (for volume check in slicer)
        inner_cavity();
    } else if (render_mode == 5) {
        // Component fit visualization — full ghost enclosure
        // '%' background modifier renders enclosure as ghost/wireframe
        // that does NOT occlude the component envelopes inside
        % full_enclosure();
        color("Red", 0.7) woofer_envelope();
        color("DodgerBlue", 0.7) tweeter_envelope();
        color("Lime", 0.7) binding_post_envelopes();
        color("Orange", 0.7) crossover_envelope_hp();
        color("Gold", 0.7) crossover_envelope_lp();
        color("Cyan", 0.7) port_envelope();
    } else if (render_mode == 6) {
        // Front half (opaque) + front-mounted component envelopes
        color("SteelBlue", 0.8) front_half();
        color("Red", 0.9) woofer_envelope();
        color("DodgerBlue", 0.9) tweeter_envelope();
    } else if (render_mode == 7) {
        // Back half (opaque) + back-mounted component envelopes
        color("CornflowerBlue", 0.8) back_half();
        color("Lime", 0.9) binding_post_envelopes();
        color("Orange", 0.9) crossover_envelope_hp();
        color("Gold", 0.9) crossover_envelope_lp();
        color("Cyan", 0.9) port_envelope();
    }
}


// ========================
// VOLUME ESTIMATION
// ========================
// Approximate volume using Simpson's rule on cross-sections

// Front cavity cross-section area
_z_front = wall;
_t_f = _z_front / enclosure_depth;
_tc_f = pow(_t_f, taper_power);
_w_f = (baffle_width - 2*wall) * (1 - _tc_f) + max(0, back_width - 2*wall) * _tc_f;
_h_f = (baffle_height - 2*wall) * (1 - _tc_f) + max(0, back_height - 2*wall) * _tc_f;
_A_front = _w_f * _h_f;

// Mid cavity cross-section area
_z_mid = enclosure_depth / 2;
_t_m = _z_mid / enclosure_depth;
_tc_m = pow(_t_m, taper_power);
_w_m = (baffle_width - 2*wall) * (1 - _tc_m) + max(0, back_width - 2*wall) * _tc_m;
_h_m = (baffle_height - 2*wall) * (1 - _tc_m) + max(0, back_height - 2*wall) * _tc_m;
_A_mid = _w_m * _h_m;

// Back cavity cross-section area
_z_back = enclosure_depth - wall;
_t_b = _z_back / enclosure_depth;
_tc_b = pow(_t_b, taper_power);
_w_b = (baffle_width - 2*wall) * (1 - _tc_b) + max(0, back_width - 2*wall) * _tc_b;
_h_b = (baffle_height - 2*wall) * (1 - _tc_b) + max(0, back_height - 2*wall) * _tc_b;
_A_back = _w_b * _h_b;

// Simpson's rule: V = (h/6)(A1 + 4*A_mid + A2)
_cavity_length = enclosure_depth - 2*wall;
_vol_mm3 = (_cavity_length / 6) * (_A_front + 4*_A_mid + _A_back);
_vol_liters = _vol_mm3 / 1e6;

// Port tube displacement (straight tube + entry flare bell cone)
_port_outer_dia = port_diameter + 2*port_wall_thick;
_port_vol_mm3 = PI/4 * pow(_port_outer_dia, 2) * port_length;
// Entry flare bell: truncated cone from flare mouth to tube diameter
_bell_mouth_dia = port_diameter + 2*port_entry_flare_r + 2*port_wall_thick;
_bell_r1 = _bell_mouth_dia / 2;
_bell_r2 = _port_outer_dia / 2;
_bell_vol_mm3 = PI/3 * port_entry_flare_r * (_bell_r1*_bell_r1 + _bell_r2*_bell_r2 + _bell_r1*_bell_r2)
              - PI/4 * pow(_port_outer_dia, 2) * port_entry_flare_r;  // subtract overlap with main tube
_port_total_vol_mm3 = _port_vol_mm3 + _bell_vol_mm3;
_port_vol_liters = _port_total_vol_mm3 / 1e6;

// Pillar displacement (approximate - 8 front + 8 back pillars)
_pillar_vol_liters = 0.02;  // Rough estimate for pillar pairs

// Net volume
_net_vol = _vol_liters - _port_vol_liters - _pillar_vol_liters;

echo("============================================");
echo(str("  SPEEDSTER AI - VOLUME ESTIMATE"));
echo(str("  Gross cavity:   ", _vol_liters, " L"));
echo(str("  Port tube:      -", _port_vol_liters, " L"));
echo(str("  Pillars (approx): -", _pillar_vol_liters, " L"));
echo(str("  ----------------------------------------"));
echo(str("  Net air volume:  ", _net_vol, " L"));
echo(str("  Target:          ", target_volume_liters, " L"));
echo(str("  Difference:      ", _net_vol - target_volume_liters, " L"));
echo("============================================");
echo(str("  Enclosure: ", baffle_width, "W x ", baffle_height, "H x ", enclosure_depth, "D mm"));
echo(str("  Back:      ", back_width, "W x ", back_height, "H mm"));
echo(str("  Wall:      ", wall, " mm PETG"));
echo(str("  Taper:     power=", taper_power));
echo("============================================");
echo(str("  Tune depth (enclosure_depth) to adjust volume."));
echo(str("  ~1mm depth change ≈ ", round(_A_mid/1000)/1000, " L"));
echo("============================================");
echo("");
echo("  DRIVER FIT CHECK:");
_woofer_top = woofer_y_offset + woofer_flange_dia/2;
_tweeter_bottom = tweeter_y_offset - tweeter_faceplate_dia/2;
_driver_gap = _tweeter_bottom - _woofer_top;
echo(str("  Woofer flange top edge:   y=", _woofer_top, " mm"));
echo(str("  Tweeter faceplate bottom: y=", _tweeter_bottom, " mm"));
echo(str("  Gap between drivers:      ", _driver_gap, " mm"));
echo(str("    (negative = overlap, Carmody's original overlaps slightly)"));
_woofer_screw_edge = woofer_screw_circle_dia/2 + woofer_screw_dia/2;
_baffle_inner_half = (baffle_width - 2*wall) / 2;
echo(str("  Woofer screw outermost:   ", _woofer_screw_edge, "mm from center"));
echo(str("  Baffle inner half-width:  ", _baffle_inner_half, "mm"));
echo(str("  Screw-to-wall clearance:  ", _baffle_inner_half - _woofer_screw_edge, "mm"));
echo(str("  Woofer depth behind baffle: ", woofer_total_depth, "mm"));
echo(str("  Tweeter depth behind baffle: ", tweeter_mount_depth, "mm"));
echo("");
echo("  DIFFRACTION / BAFFLE STEP:");
echo(str("  Baffle width:     ", baffle_width, "mm"));
echo(str("  Edge roundover:   ", baffle_roundover, "mm radius"));
_baffle_step_hz = round(344000 / (PI * baffle_width));
echo(str("  Est. baffle step: ~", _baffle_step_hz, " Hz"));
echo(str("  Roundover effective above: ~", round(344000 / (2 * PI * baffle_roundover)), " Hz"));
echo("");
echo("  For precise volume: export inner_cavity() as STL,");
echo("  import into Bambu Studio → check volume in cm³");
echo("");
echo("  CROSSOVER PCB MOUNTING:");
_xover_face_x = xover_pcb_face_x_abs();
echo(str("  PCB face x-position:  ±", _xover_face_x, "mm from center"));
echo(str("  PCB y range:          ", xover_y_top - xover_pcb_height, " to ", xover_y_top, "mm"));
echo(str("  PCB z range:          ", xover_z_start, " to ", xover_z_start + xover_pcb_width, "mm"));
_port_bottom_y = port_y_offset - (port_diameter + 2*port_wall_thick)/2;
_xover_port_clear = _port_bottom_y - xover_y_top;
echo(str("  Port clearance below: ", _xover_port_clear, "mm (port bottom at y=", _port_bottom_y, ")"));
_bp_pcb_y = xover_y_top - (bp_y_offset);
echo(str("  BP at y=", bp_y_offset, " maps to: PCB y=", _bp_pcb_y, " (normal comp height zone)"));
_xover_inductor_y = xover_y_top - xover_tall_pcb_y;
echo(str("  Tall inductor at:     enc y=", _xover_inductor_y, " (BP zone: y=-60 to -30)"));
echo(str("  Boss lengths:         ", xover_boss_min_depth, "mm min (at narrowest) to ~20mm"));
echo("");


// ========================
// PRINT NOTES
// ========================
// 
// PETG Settings (10mm walls):
//   Layer height: 0.2mm
//   Perimeters: 5-6 (to fill most of the 10mm wall)
//   Infill: 50-80% gyroid (for remaining wall fill)
//   Top/bottom layers: 8+
//   Supports: Yes, for driver cutouts and counterbores
//
// Print orientation:
//   Front half: baffle face DOWN on bed (split face up)
//   Back half:  back face DOWN on bed (split face up)
//
// Assembly:
//   1. Print both halves (pillars + interlocks integral to each)
//   2. Clean up supports from driver cutouts
//   3. Install M4 heat-set inserts into front half pillars (8x enclosure bolts)
//   4. Install M4 heat-set inserts into woofer screw holes (4x, from front face)
//   5. Install M3 heat-set inserts into tweeter recess floor (4x, from recess)
//   6. Install M3 heat-set inserts into crossover bosses (8x, 4 per side wall)
//   7. Mount high-pass PCB on one side wall, low-pass on opposite (M3 screws)
//   8. Run speaker wire from back to front through split plane
//   9. Press foam tape or TPU strip into groove on back half split face
//   10. Add polyfill loosely to cavity
//   11. Align tongue into groove and interlock bosses into recesses,
//       mate halves, bolt from BACK with M4 caps
//       (bolt heads on rear tapered walls, no hardware on front)
//   12. Mount tweeter (flush into recess) with M3 screws
//   13. Mount woofer (surface mount) with M4 screws
//   14. Connect drivers to crossover
//   15. Install binding posts through back wall (nut from inside)
//
// Hardware BOM (per speaker):
//   Enclosure assembly:
//     8x M4 heat-set inserts (Ø5.6mm × 8mm deep) - front half pillars
//     8x M4 × 65mm socket head cap screws - from back
//   Woofer mounting:
//     4x M4 heat-set inserts (Ø5.6mm × 6mm deep) - baffle front face
//     4x M4 × 10mm socket head cap screws - through driver flange
//   Tweeter mounting:
//     4x M3 heat-set inserts (Ø4.5mm × 5mm deep) - recess floor
//     4x M3 × 8mm socket head cap screws - through faceplate
//   Seal strip (one of):
//     Closed-cell foam tape ~3mm wide, pressed into groove
//     OR TPU filament bead laid into groove before mating
//   Crossover mounting:
//     6x M3 heat-set inserts (Ø4.5mm × 6mm deep) - side wall bosses (3 per side)
//     6x M3 × 8mm socket head cap screws - through PCB holes (3 per board)
//   Binding posts:
//     2x Dayton BPP-SNB binding posts - direct mount through back wall
//     2x M9 nuts (included with posts)
//
// Pillar interlock system:
//   8x 16mm dia pillar pairs (front + back) at split-plane perimeter
//   Front pillars: baffle inner wall to split face
//   Back pillars: split face + 30mm into back half, with 15° taper (~30mm cone)
//   Interlock BOSS on back pillar face (protrudes into front half)
//   Interlock RECESS on front pillar face (absorbs heat-set insert expansion)
//   Boss/recess: 10mm dia × 2mm, 0.3mm clearance per side
//   Boss on non-insert side stays at nominal dims; recess on insert side
//   absorbs thermal expansion from heat-set installation
//
// Tongue-and-groove joint:
//   Tongue: 3mm wide × 4mm tall ridge on front half split face
//   Groove: 3.6mm wide × 5mm deep channel in back half split face
//   Self-aligning in X and Y, seal strip compressed in groove bottom
//
// Crossover PCB mounting (split boards, one per side wall):
//   Two V-cut PCBs separated and mounted on opposing side walls
//   Left wall: PCB flipped (rotated 180° around vertical), components face +x (inward)
//   Right wall: PCB in normal orientation, components face -x (inward)
//   Hole pattern differs per side due to asymmetric flip
//   3x M3 heat-set inserts (Ø4.5mm × 6mm) per side wall (6 total)
//   3x M3 × 8mm socket head cap screws per board (6 total)
//   Boss pads integral to back half print, variable length 6-20mm
//   Each boss has a 45° triangular brace below for print support
//   PCB position: y=-100 to +26, z=83 to 175
//   Port tube clearance: inductor clears port by 3mm (circle-to-circle)
//   Binding post clearance: components don't reach center at post y-level
//   Tall inductor (PCB y=102) positioned below binding post zone
//
// Airtightness:
//   PETG at 5+ perimeters is inherently airtight
//   Tongue-and-groove + foam/TPU seals the split joint
//   8 pillar pairs with interlocks provide structural rigidity
//   Test: cover port, push woofer cone gently
//   Should resist and return slowly
