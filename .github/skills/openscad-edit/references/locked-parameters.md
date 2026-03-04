# Locked Parameters — SpeedsterAI

These parameters are established and verified. Change them only with full awareness of the cascading effects.

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| `baffle_width` | 180 mm | Width for woofer flange (125.5mm + margins); original proportions preserved |
| `baffle_height` | 264 mm | Proportional to back_height (0.8 ratio) |
| `baffle_corner_r` | 15 mm | Front face corner rounding |
| `back_width` | 118 mm | Accommodates binding posts (30mm spacing + margin) |
| `back_height` | 211 mm | Proportional to baffle height (0.8 ratio) |
| `back_corner_r` | 17 mm | Sharper than original R42 for PCB clearance at bottom-back corner |
| `enclosure_depth` | 205 mm | Extended from 197mm for tweeter-port clearance (+10.7mm gap) and PCB fit |
| `wall` | 10 mm | PETG stiffness parity with 1/2" MDF at 5-6 perimeters |
| `taper_power` | 2.0 | Quadratic — concentrates volume near baffle |
| `baffle_roundover` | 20 mm | Diffraction control > ~2737 Hz (reduced from 24 for driver fit) |
| `roundover_depth` | 33 mm | ≤45° FDM overhang (ratio 33/20=1.65) |
| `baffle_edge_chamfer` | 2 mm | 45° bevel softening front face edge |
| `split_z` | auto: depth-wall-port_length = 80.7 mm | Port tube stays in back half |
| `port_diameter` | 34.925 mm | Carmody spec: 1.375" exact conversion |
| `port_length` | 114.3 mm | Carmody spec: 4.5" exact conversion |
| `port_wall_thick` | 2.5 mm | Port tube wall thickness |
| `port_y_offset` | 52 mm | Raised from 45 to clear L3 inductor by 3mm |
| `port_entry_flare_r` | 15 mm | Quarter-circle bell for turbulence reduction + tweeter clearance |
| `port_flare_r` | 15 mm | Exit flare (implemented as 45° chamfer for printability) |
| `pillar_dia` | 16 mm | 8 pairs at split-plane perimeter |
| `back_pillar_depth` | 30 mm | + 15° taper (~30mm cone) = ~60mm total |
| `bolt_inset` | 12 mm | Distance from edge to bolt center |
| `bolt_landing_dia` | 8 mm | Counterbore diameter |
| `tongue_width` | 3 mm | Self-aligning seal joint |
| `tongue_height` | 4 mm | Protrusion past split face |
| `tongue_clearance` | 0.3 mm | Gap per side for print tolerance |
| `seal_depth` | 1 mm | Extra groove depth for foam/TPU |
| `xover_pcb_width` | 92 mm | PCB short axis (maps to Z) |
| `xover_pcb_height` | 126 mm | PCB long axis (maps to Y) |
| `xover_z_start` | 90 mm | Clears woofer depth (89.5mm) with 0.5mm margin |
| `xover_y_top` | 26 mm | Inductor clears port by 3mm |
| `xover_holes` | [43,5], [87,121], [5,121] | 3 holes per board (4th omitted: corner rounding zone) |
| `bp_spacing` | 30 mm | Binding post center-to-center |
| `bp_y_offset` | -45 mm | Same vertical position as woofer |
| `bp_intrusion` | 34 mm | 25mm shaft + 9mm terminal lug |

## Heat-Set Insert Specs

| Application | Thread | Bore Ø | Depth | Count |
|-------------|--------|--------|-------|-------|
| Enclosure bolts | M4 | 5.6 mm | 8 mm | 8 per speaker |
| Woofer mount | M4 | 5.6 mm | 8 mm | 4 per speaker |
| Tweeter mount | M3 | 4.5 mm | 6 mm | 4 per speaker |
| Crossover bosses | M3 | 4.5 mm | 6 mm | 6 per speaker |
| Binding posts | — | 11.7 mm | through | 2 per speaker |

## Volume Budget

| Item | Volume |
|------|--------|
| Gross cavity (STL verified) | 5.86 L |
| Port tube + entry bell | -0.16 L |
| Pillars (estimated) | -0.02 L |
| **Net air volume** | **5.68 L** |
| Crossover displacement | -0.33 L |
| **Effective air volume** | **~5.35 L** |
| Target | 5.5 L |
