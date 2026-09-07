# Dead Street offline character render (Blender 4.x).
# Does not run inside Godot. Requires bpy.
#
# Generic directional sprite renderer for a rigged GLTF source.
# M7E used this with the Quaternius UAL mannequin as pipeline proof only.
# M7F look_calib_01 / MPFB builder has been retired from the active path.
# Do not use the UAL mannequin body as final Dead Street character art.
#
#   blender --background --python tools/character_pipeline/render_tactical_sprites.py -- --mode calibrate
#   blender --background --python tools/character_pipeline/render_tactical_sprites.py -- --mode render
#
# Imports one rigged humanoid, plays real skeletal actions, rotates the SAME
# character under ONE locked camera/light, writes transparent RGBA sprites.

import argparse
import math
import os
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DEFAULT_GLTF = os.path.join(
    REPO_ROOT,
    "tools",
    "character_pipeline",
    "source",
    "gltf-universal-animation-library-main",
    "glTF",
    "AnimationLibrary_Godot_Standard.gltf",
)
DEFAULT_OUT = os.path.join(
    REPO_ROOT,
    "assets",
    "tactical",
    "units",
    "local_street_gang",
    "rig_proto_01",
)
CALIB_OUT = os.path.join(REPO_ROOT, "tools", "character_pipeline", "calib")

CANVAS_PX = 256
CAMERA_KIND = "orthographic"
# Elevation from horizontal. 90 = overhead. Locked after calibration.
CAMERA_ELEVATION_DEG = 46.0
CAMERA_DIST = 5.5
ORTHO_SCALE = 2.15
LIGHT_YAW_DEG = -28.0
LIGHT_PITCH_DEG = 48.0
FOOT_PAD_FRAC = 0.06
# Rest mesh faces +Y. Camera sits on -Y. Add 180 so "s" faces the camera.
FACING_YAW_OFFSET_DEG = 180.0
DIRECTION_YAW_DEG = {
    "s": 0.0,
    "se": 45.0,
    "e": 90.0,
    "ne": 135.0,
    "n": 180.0,
    "nw": 225.0,
    "w": 270.0,
    "sw": 315.0,
}
CLIP_ACTIONS = {
    "idle": {"action": "Idle_Loop", "frames": 6},
    "walk": {"action": "Walk_Loop", "frames": 16},
}


def _parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["calibrate", "render"], default="render")
    parser.add_argument("--gltf", default=DEFAULT_GLTF)
    parser.add_argument("--out", default=DEFAULT_OUT)
    parser.add_argument("--elevation", type=float, default=CAMERA_ELEVATION_DEG)
    parser.add_argument("--ortho", type=float, default=ORTHO_SCALE)
    parser.add_argument("--armature", default="Rig")
    return parser.parse_args(argv)


def _require_blender():
    try:
        import bpy  # noqa: F401
    except ImportError as exc:
        raise SystemExit("Blender Python (bpy) is required. This script is offline-only.") from exc


def _mat(bpy, name, color, metallic=0.0, roughness=0.9, specular=0.08):
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial")
    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.inputs["Base Color"].default_value = (color[0], color[1], color[2], 1.0)
    if "Metallic" in bsdf.inputs:
        bsdf.inputs["Metallic"].default_value = metallic
    if "Roughness" in bsdf.inputs:
        bsdf.inputs["Roughness"].default_value = roughness
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = specular
    elif "Specular" in bsdf.inputs:
        bsdf.inputs["Specular"].default_value = specular
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    return mat


def _apply_gritty_materials(bpy):
    cloth = _mat(bpy, "DS_Cloth", (0.22, 0.24, 0.16), roughness=0.93, specular=0.04)
    joint = _mat(bpy, "DS_Joint", (0.40, 0.30, 0.22), roughness=0.88, specular=0.06)
    mannequin = bpy.data.objects.get("Mannequin")
    if mannequin is None or mannequin.type != "MESH":
        return
    while len(mannequin.data.materials) < 2:
        mannequin.data.materials.append(cloth)
    mannequin.data.materials[0] = cloth
    mannequin.data.materials[1] = joint


def _add_rifle(bpy, armature):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.0, 0.0))
    body = bpy.context.active_object
    body.name = "RifleBody"
    body.scale = (0.045, 0.62, 0.055)
    bpy.ops.object.transform_apply(scale=True)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, -0.22, -0.02))
    stock = bpy.context.active_object
    stock.name = "RifleStock"
    stock.scale = (0.04, 0.18, 0.08)
    bpy.ops.object.transform_apply(scale=True)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.04, -0.10))
    mag = bpy.context.active_object
    mag.name = "RifleMag"
    mag.scale = (0.035, 0.05, 0.13)
    bpy.ops.object.transform_apply(scale=True)
    metal = _mat(bpy, "DS_Rifle", (0.07, 0.075, 0.07), metallic=0.35, roughness=0.72, specular=0.1)
    wood = _mat(bpy, "DS_Stock", (0.10, 0.08, 0.06), metallic=0.0, roughness=0.9, specular=0.04)
    body.data.materials.append(metal)
    stock.data.materials.append(wood)
    mag.data.materials.append(metal)
    bpy.ops.object.select_all(action="DESELECT")
    body.select_set(True)
    stock.select_set(True)
    mag.select_set(True)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.join()
    rifle = bpy.context.active_object
    rifle.name = "Rifle"
    bone_name = "DEF-hand.R"
    if bone_name not in armature.data.bones:
        raise SystemExit("Missing hand bone %s" % bone_name)
    rifle.parent = armature
    rifle.parent_type = "BONE"
    rifle.parent_bone = bone_name
    rifle.location = (0.0, 0.22, 0.03)
    rifle.rotation_euler = (math.radians(-8.0), 0.0, 0.0)


def _setup_world(bpy):
    scene = bpy.context.scene
    if "BLENDER_EEVEE_NEXT" in dir(bpy.ops.render) or True:
        try:
            scene.render.engine = "BLENDER_EEVEE_NEXT"
        except TypeError:
            scene.render.engine = "BLENDER_EEVEE"
    scene.render.film_transparent = True
    scene.render.resolution_x = CANVAS_PX
    scene.render.resolution_y = CANVAS_PX
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.image_settings.color_depth = "8"
    scene.render.dither_intensity = 0.0
    scene.render.use_compositing = False
    scene.render.use_sequencer = False
    if hasattr(scene, "eevee"):
        eevee = scene.eevee
        if hasattr(eevee, "taa_render_samples"):
            eevee.taa_render_samples = 16
        if hasattr(eevee, "use_gtao"):
            eevee.use_gtao = True
        if hasattr(eevee, "gtao_distance"):
            eevee.gtao_distance = 0.35
        if hasattr(eevee, "use_bloom"):
            eevee.use_bloom = False
        if hasattr(eevee, "use_raytracing"):
            eevee.use_raytracing = False
    world = bpy.data.worlds.new("DSWorld") if "DSWorld" not in bpy.data.worlds else bpy.data.worlds["DSWorld"]
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    if bg is None:
        bg = world.node_tree.nodes.new("ShaderNodeBackground")
        out = world.node_tree.nodes.get("World Output")
        if out:
            world.node_tree.links.new(bg.outputs["Background"], out.inputs["Surface"])
    bg.inputs["Color"].default_value = (0.12, 0.12, 0.11, 1.0)
    bg.inputs["Strength"].default_value = 0.35
    scene.world = world
    light_data = bpy.data.lights.new("TacticalKey", "SUN")
    light_data.energy = 2.6
    light_data.angle = 0.32
    light_data.color = (1.0, 0.96, 0.90)
    light = bpy.data.objects.new("TacticalKey", light_data)
    scene.collection.objects.link(light)
    light.rotation_euler = (
        math.radians(LIGHT_PITCH_DEG),
        0.0,
        math.radians(LIGHT_YAW_DEG),
    )
    fill_data = bpy.data.lights.new("TacticalFill", "SUN")
    fill_data.energy = 0.45
    fill_data.angle = 0.8
    fill_data.color = (0.75, 0.78, 0.80)
    fill = bpy.data.objects.new("TacticalFill", fill_data)
    scene.collection.objects.link(fill)
    fill.rotation_euler = (math.radians(70.0), 0.0, math.radians(140.0))


def _setup_camera(bpy, elevation_deg, ortho_scale):
    cam_data = bpy.data.cameras.new("TacticalCam")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = ortho_scale
    cam_data.clip_start = 0.05
    cam_data.clip_end = 40.0
    cam = bpy.data.objects.new("TacticalCam", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    elev = math.radians(elevation_deg)
    cam.location = (
        0.0,
        -math.cos(elev) * CAMERA_DIST,
        math.sin(elev) * CAMERA_DIST,
    )
    target = bpy.data.objects.new("TacticalAim", None)
    bpy.context.scene.collection.objects.link(target)
    target.location = (0.0, 0.0, 0.92)
    track = cam.constraints.new("TRACK_TO")
    track.target = target
    track.track_axis = "TRACK_NEGATIVE_Z"
    track.up_axis = "UP_Y"
    bpy.context.scene.camera = cam
    return cam


def _play_action(bpy, armature, action_name):
    action = bpy.data.actions.get(action_name)
    if action is None:
        raise SystemExit("Missing action '%s'" % action_name)
    if armature.animation_data is None:
        armature.animation_data_create()
    armature.animation_data.action = action
    return action


def _zero_root(armature):
    root = armature.pose.bones.get("root")
    if root is None:
        return
    root.location[0] = 0.0
    root.location[1] = 0.0


def _set_yaw(armature, direction_id):
    yaw = DIRECTION_YAW_DEG[direction_id] + FACING_YAW_OFFSET_DEG
    armature.rotation_euler = (0.0, 0.0, math.radians(yaw))


def _sample_frames(action, count):
    start = int(round(action.frame_range[0]))
    end = int(round(action.frame_range[1]))
    if end <= start:
        return [start] * count
    if count <= 1:
        return [start]
    span = end - start
    frames = []
    for i in range(count):
        frames.append(start + int(round(i * span / float(count))))
    return frames


def _render_still(bpy, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)


def _import_character(bpy, gltf_path, armature_name):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if not os.path.isfile(gltf_path):
        raise SystemExit("Missing glTF: %s" % gltf_path)
    bpy.ops.import_scene.gltf(filepath=gltf_path)
    extras = [obj for obj in bpy.data.objects if obj.type == "MESH" and obj.name != "Mannequin"]
    for obj in extras:
        bpy.data.objects.remove(obj, do_unlink=True)
    armature = bpy.data.objects.get(armature_name)
    if armature is None:
        raise SystemExit("Missing armature '%s'" % armature_name)
    _apply_gritty_materials(bpy)
    _add_rifle(bpy, armature)
    return armature


def calibrate(bpy, args):
    armature = _import_character(bpy, args.gltf, args.armature)
    _setup_world(bpy)
    os.makedirs(CALIB_OUT, exist_ok=True)
    action = _play_action(bpy, armature, "Walk_Loop")
    elevations = [38.0, 42.0, 46.0, 50.0, 55.0]
    bpy.context.scene.frame_set(int(round(action.frame_range[0] + 8)))
    _zero_root(armature)
    _set_yaw(armature, "s")
    bpy.context.view_layer.update()
    for elev in elevations:
        old_cams = [
            obj
            for obj in bpy.data.objects
            if obj.name.startswith("TacticalCam") or obj.name.startswith("TacticalAim")
        ]
        for obj in old_cams:
            bpy.data.objects.remove(obj, do_unlink=True)
        _setup_camera(bpy, elev, args.ortho)
        bpy.context.view_layer.update()
        path = os.path.join(CALIB_OUT, "elev%02d_s.png" % elev)
        _render_still(bpy, path)
        print("CALIB", path)


def render_clips(bpy, args):
    armature = _import_character(bpy, args.gltf, args.armature)
    _setup_world(bpy)
    _setup_camera(bpy, args.elevation, args.ortho)
    for clip_id, spec in CLIP_ACTIONS.items():
        action = _play_action(bpy, armature, spec["action"])
        samples = _sample_frames(action, spec["frames"])
        for direction_id in DIRECTION_YAW_DEG:
            clip_dir = os.path.join(args.out, clip_id, direction_id)
            os.makedirs(clip_dir, exist_ok=True)
            _set_yaw(armature, direction_id)
            for frame_index, src_frame in enumerate(samples):
                bpy.context.scene.frame_set(src_frame)
                _zero_root(armature)
                bpy.context.view_layer.update()
                path = os.path.join(clip_dir, "%02d.png" % frame_index)
                _render_still(bpy, path)
                print("WROTE", path)


def main(argv=None):
    _require_blender()
    import bpy

    args = _parse_args(argv if argv is not None else [])
    if args.mode == "calibrate":
        calibrate(bpy, args)
    else:
        render_clips(bpy, args)


if __name__ == "__main__":
    if "--" in sys.argv:
        main(sys.argv[sys.argv.index("--") + 1 :])
    else:
        main([])
