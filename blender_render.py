#!/usr/bin/env python3
"""
Blender Cycles render script for SpeedsterAI enclosure STLs.

Usage (called by render.sh):
    blender --background --python blender_render.py -- \
        --stl models/speedster-ai-front.stl models/speedster-ai-back.stl \
        --output renders/three_quarter_front.png \
        --camera 450,550,300 \
        --center 0,-102.5,0 \
        --resolution 1920,1080 \
        [--samples 64] \
        [--color 0.01,0.05,0.22]  (front half: deep navy blue PETG default)
        [--color2 0.25,0.55,0.85] (back half: bright sky blue)
        [--explode 40]  (explode distance for halves along depth axis)

Camera/center coordinates use the OpenSCAD display convention
(after rotate([90,0,0])): X=horizontal, Y=depth(0=baffle,-205=back), Z=height.
The script converts to Blender/STL model coords internally.
"""

import bpy
import sys
import os
import math
from mathutils import Vector

# ── Parse arguments after "--" ──────────────────────────────────────────

argv = sys.argv
if "--" in argv:
    argv = argv[argv.index("--") + 1:]
else:
    argv = []

def parse_arg(flag, default=None):
    if flag in argv:
        return argv[argv.index(flag) + 1]
    return default

def parse_list_arg(flag):
    """Parse all values after flag until next flag or end."""
    if flag not in argv:
        return []
    idx = argv.index(flag) + 1
    vals = []
    while idx < len(argv) and not argv[idx].startswith("--"):
        vals.append(argv[idx])
        idx += 1
    return vals

stl_files = parse_list_arg("--stl")
output_path = parse_arg("--output", "renders/render.png")
camera_str = parse_arg("--camera", "450,550,300")
center_str = parse_arg("--center", "0,-102.5,0")
resolution_str = parse_arg("--resolution", "1920,1080")
samples = int(parse_arg("--samples", "64"))
color_str = parse_arg("--color", "0.02,0.08,0.30")
color2_str = parse_arg("--color2", "0.30,0.60,0.90")
explode = float(parse_arg("--explode", "0"))
env_strength = float(parse_arg("--env-strength", "0.5"))

# Display coords map directly to Blender coords after -90° X rotation of STLs
camera_pos = tuple(float(x) for x in camera_str.split(","))
center_pos = tuple(float(x) for x in center_str.split(","))

resolution = [int(x) for x in resolution_str.split(",")]
base_color = [float(x) for x in color_str.split(",")]
base_color2 = [float(x) for x in color2_str.split(",")]

# ── Scene setup ─────────────────────────────────────────────────────────

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
for obj in bpy.data.objects:
    bpy.data.objects.remove(obj, do_unlink=True)

# ── Import STLs ─────────────────────────────────────────────────────────

imported_objects = []
for i, stl_path in enumerate(stl_files):
    bpy.ops.import_mesh.stl(filepath=stl_path)
    obj = bpy.context.active_object
    obj.name = f"part_{i}"

    # The back half STL is exported with rotate([180,0,0]) for print orientation
    # (back face on build plate). Undo that rotation for assembled/exploded views.
    is_back = "back" in os.path.basename(stl_path).lower()
    if is_back:
        obj.rotation_euler.x = math.pi
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.transform_apply(rotation=True)

    # Rotate +90° around X to match OpenSCAD's rotate([90,0,0]) display transform:
    # model (x,y,z) → Blender (x, -z, y), giving Z-up with Y=depth(negative=back)
    obj.rotation_euler.x = math.pi / 2
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(rotation=True)

    # Apply explode offset along Y axis (depth in Blender coords after rotation)
    if explode != 0 and len(stl_files) > 1:
        if is_back:
            obj.location.y -= explode  # Back half away from camera
        else:
            obj.location.y += explode  # Front half toward camera

    imported_objects.append(obj)

    # Smooth shading
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.shade_smooth()

    # Auto-smooth to keep sharp edges while smoothing curves
    mesh = obj.data
    if hasattr(mesh, 'use_auto_smooth'):
        mesh.use_auto_smooth = True
        mesh.auto_smooth_angle = math.radians(30)

    obj.select_set(False)

# ── Materials: matte PETG (per-half colors) ─────────────────────────────

part_colors = [base_color, base_color2]

def make_petg_material(name, color):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (0, 0)
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.45
    bsdf.inputs["Metallic"].default_value = 0.0
    for spec_name in ["Specular IOR Level", "Specular"]:
        if spec_name in bsdf.inputs:
            bsdf.inputs[spec_name].default_value = 0.3
            break
    if "Coat Weight" in bsdf.inputs:
        bsdf.inputs["Coat Weight"].default_value = 0.15
        bsdf.inputs["Coat Roughness"].default_value = 0.3

    output_node = nodes.new("ShaderNodeOutputMaterial")
    output_node.location = (300, 0)
    links.new(bsdf.outputs["BSDF"], output_node.inputs["Surface"])
    return mat

for i, obj in enumerate(imported_objects):
    color = part_colors[i % len(part_colors)]
    mat = make_petg_material(f"PETG_{i}", color)
    obj.data.materials.clear()
    obj.data.materials.append(mat)

# ── Lighting: 3-point studio ────────────────────────────────────────────

# Compute bounding box center for light positioning
all_coords = []
for obj in imported_objects:
    for v in obj.bound_box:
        world_v = obj.matrix_world @ Vector(v)
        all_coords.append(world_v)
bb_min = Vector([min(c[i] for c in all_coords) for i in range(3)])
bb_max = Vector([max(c[i] for c in all_coords) for i in range(3)])
bb_center = (bb_min + bb_max) / 2
bb_size = max((bb_max - bb_min)[i] for i in range(3))

def add_area_light(name, location, rotation, energy, size, color=(1, 1, 1)):
    bpy.ops.object.light_add(type='AREA', location=location)
    light = bpy.context.active_object
    light.name = name
    light.rotation_euler = [math.radians(r) for r in rotation]
    light.data.energy = energy
    light.data.size = size
    light.data.color = color
    return light

# Lights positioned relative to bounding box
scale = bb_size / 200  # Normalize to ~200mm model
add_area_light("Key",
    (bb_center.x + 300*scale, bb_center.y + 400*scale, bb_center.z + 350*scale),
    (-35, 20, -40), 5000 * scale**2, 4.0 * scale, (1.0, 0.97, 0.92))
add_area_light("Fill",
    (bb_center.x - 400*scale, bb_center.y + 100*scale, bb_center.z + 100*scale),
    (-10, -30, 20), 2000 * scale**2, 5.0 * scale, (0.92, 0.95, 1.0))
add_area_light("Rim",
    (bb_center.x, bb_center.y - 300*scale, bb_center.z + 400*scale),
    (30, 0, 0), 3000 * scale**2, 3.0 * scale, (1.0, 1.0, 1.0))

# ── Environment ─────────────────────────────────────────────────────────

world = bpy.data.worlds.get("World") or bpy.data.worlds.new("World")
bpy.context.scene.world = world
world.use_nodes = True
wnodes = world.node_tree.nodes
wlinks = world.node_tree.links
wnodes.clear()

bg = wnodes.new("ShaderNodeBackground")
bg.inputs["Strength"].default_value = env_strength
bg.inputs["Color"].default_value = (0.9, 0.9, 0.92, 1.0)
output_w = wnodes.new("ShaderNodeOutputWorld")
output_w.location = (300, 0)
wlinks.new(bg.outputs["Background"], output_w.inputs["Surface"])

# ── Camera with auto-framing ────────────────────────────────────────────

bpy.ops.object.camera_add(location=camera_pos)
camera = bpy.context.active_object
camera.name = "Camera"
bpy.context.scene.camera = camera

# Point camera at center
direction = Vector(center_pos) - Vector(camera_pos)
rot_quat = direction.to_track_quat('-Z', 'Z')
camera.rotation_euler = rot_quat.to_euler()

# Auto-fit: project bounding box corners onto camera view plane
cam_vec = Vector(camera_pos)
ctr_vec = Vector(center_pos)
forward = (ctr_vec - cam_vec).normalized()
cam_dist = (ctr_vec - cam_vec).length
# Build camera-local axes
world_up = Vector((0, 0, 1)) if abs(forward.dot(Vector((0, 0, 1)))) < 0.99 else Vector((0, 1, 0))
right = forward.cross(world_up).normalized()
up = right.cross(forward).normalized()

# Project all bounding box corners onto the camera view plane
max_h = 0  # half-width in view plane
max_v = 0  # half-height in view plane
for obj in imported_objects:
    for v in obj.bound_box:
        world_v = obj.matrix_world @ Vector(v)
        rel = world_v - cam_vec
        depth = rel.dot(forward)
        if depth <= 0:
            continue
        proj_right = rel.dot(right)
        proj_up = rel.dot(up)
        # Angular extent from camera
        max_h = max(max_h, abs(proj_right / depth))
        max_v = max(max_v, abs(proj_up / depth))

# Add 15% padding
max_h *= 1.15
max_v *= 1.15

sensor_width = 36  # mm (Blender default)
aspect = resolution[0] / resolution[1]
sensor_height = sensor_width / aspect

# Focal length to fit both horizontal and vertical extents
fl_h = sensor_width / (2 * max_h) if max_h > 0 else 50
fl_v = sensor_height / (2 * max_v) if max_v > 0 else 50
focal_length = min(fl_h, fl_v)  # Use tighter constraint
focal_length = max(18, min(200, focal_length))  # Clamp to reasonable range

camera.data.type = 'PERSP'
camera.data.lens = focal_length
camera.data.clip_start = 1
camera.data.clip_end = cam_dist * 5

# ── Render settings ─────────────────────────────────────────────────────

scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = samples
scene.cycles.use_denoising = False  # OIDN not available in container
scene.cycles.preview_samples = 16

scene.render.resolution_x = resolution[0]
scene.render.resolution_y = resolution[1]
scene.render.resolution_percentage = 100

scene.render.image_settings.file_format = 'PNG'
scene.render.image_settings.color_mode = 'RGBA'
scene.render.film_transparent = True

scene.render.use_persistent_data = True
scene.cycles.max_bounces = 6
scene.cycles.diffuse_bounces = 3
scene.cycles.glossy_bounces = 3

# ── Render ──────────────────────────────────────────────────────────────

os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
scene.render.filepath = output_path
bpy.ops.render.render(write_still=True)
print(f"Rendered: {output_path} (lens={focal_length:.0f}mm, samples={samples})")
