"""Generates a suggestive, polished app icon for Recolta (a bunch of grapes)."""
from PIL import Image, ImageDraw, ImageFilter
import math

SCALE = 4
SIZE = 1024 * SCALE


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def vertical_gradient(size, top_color, bottom_color):
    img = Image.new("RGB", (size, size))
    for y in range(size):
        t = y / (size - 1)
        color = lerp_color(top_color, bottom_color, t)
        for x in range(size):
            img.putpixel((x, y), color)
    return img


def rounded_rect_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


# ---- Background: deep wine-purple gradient rounded square ----
bg_grad = vertical_gradient(SIZE, (74, 20, 60), (142, 36, 107))  # deep plum -> wine purple
bg_mask = rounded_rect_mask(SIZE, radius=int(SIZE * 0.22))
background = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
background.paste(bg_grad, (0, 0), bg_mask)

# subtle radial highlight top-left for depth
highlight = Image.new("L", (SIZE, SIZE), 0)
hd = ImageDraw.Draw(highlight)
hd.ellipse([-SIZE * 0.3, -SIZE * 0.35, SIZE * 0.75, SIZE * 0.55], fill=55)
highlight = highlight.filter(ImageFilter.GaussianBlur(SIZE * 0.08))
white_layer = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 255))
glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
glow.paste(white_layer, (0, 0), highlight)
background = Image.alpha_composite(background, Image.composite(glow, Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0)), bg_mask))

# All grape artwork is drawn on a transparent "foreground" layer first
# (reused as-is for the Android adaptive icon foreground), then composited
# onto the gradient background for the full icon.
canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
cx, cy = SIZE / 2, SIZE * 0.46

grape_r = SIZE * 0.105
grape_dark = (58, 14, 74)     # deep grape purple (shadow side)
grape_mid = (118, 44, 122)    # mid purple
grape_light = (191, 118, 178)  # highlight pink-purple

# Cluster layout: rows of grapes, narrowing towards the bottom (classic
# triangular bunch), each row offset so grapes nestle between the ones above.
rows = [
    (-1.5, 0), (-0.5, 0), (0.5, 0), (1.5, 0),
    (-1.0, 1), (0.0, 1), (1.0, 1),
    (-0.5, 2), (0.5, 2),
    (0.0, 3),
]
spacing = grape_r * 1.45

# Draw back-to-front (top rows first) so lower grapes overlap the ones above,
# matching how a real bunch layers from the stem downward.
grape_shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
gsd = ImageDraw.Draw(grape_shadow)
for col, row in rows:
    gx = cx + col * spacing
    gy = cy + row * spacing * 0.92
    gsd.ellipse(
        [gx - grape_r + SIZE * 0.012, gy - grape_r + SIZE * 0.018,
         gx + grape_r + SIZE * 0.012, gy + grape_r + SIZE * 0.018],
        fill=(20, 5, 20, 110),
    )
grape_shadow = grape_shadow.filter(ImageFilter.GaussianBlur(SIZE * 0.014))
canvas = Image.alpha_composite(canvas, grape_shadow)

for col, row in rows:
    gx = cx + col * spacing
    gy = cy + row * spacing * 0.92
    layer_size = int(grape_r * 2.6)
    grape_layer = Image.new("RGBA", (layer_size, layer_size), (0, 0, 0, 0))
    gld = ImageDraw.Draw(grape_layer)
    lcx, lcy = layer_size / 2, layer_size / 2
    # radial-ish shading via layered ellipses: dark base, mid, light highlight
    gld.ellipse([lcx - grape_r, lcy - grape_r, lcx + grape_r, lcy + grape_r], fill=grape_dark)
    gld.ellipse(
        [lcx - grape_r * 0.82, lcy - grape_r * 0.9, lcx + grape_r * 0.55, lcy + grape_r * 0.55],
        fill=grape_mid,
    )
    gld.ellipse(
        [lcx - grape_r * 0.45, lcy - grape_r * 0.7, lcx + grape_r * 0.05, lcy - grape_r * 0.05],
        fill=grape_light,
    )
    canvas.paste(grape_layer, (int(gx - lcx), int(gy - lcy)), grape_layer)

draw = ImageDraw.Draw(canvas)

# ---- Stem (curved, connects the top grape to the leaf) ----
stem_top = (cx, cy - spacing * 2.05)
stem_color = (94, 64, 40)
leaf_cx = cx + SIZE * 0.075
leaf_cy = stem_top[1] - SIZE * 0.05
draw.line(
    [(cx, cy - spacing * 1.55), stem_top, (leaf_cx - SIZE * 0.02, leaf_cy + SIZE * 0.05)],
    fill=stem_color, width=int(SIZE * 0.018), joint="curve",
)
draw.ellipse(
    [cx - SIZE * 0.012, cy - spacing * 1.55 - SIZE * 0.012,
     cx + SIZE * 0.012, cy - spacing * 1.55 + SIZE * 0.012],
    fill=stem_color,
)

# ---- Leaf (simple rounded vine-leaf silhouette, top-right of the stem) ----
leaf_color = (86, 140, 62)
leaf_light = (123, 179, 92)
leaf_layer = Image.new("RGBA", (int(SIZE * 0.30), int(SIZE * 0.26)), (0, 0, 0, 0))
lld = ImageDraw.Draw(leaf_layer)
lw, lh = leaf_layer.size
# three overlapping lobes approximate a grape-leaf silhouette
lld.ellipse([lw * 0.10, lh * 0.30, lw * 0.65, lh * 0.85], fill=leaf_color)
lld.ellipse([lw * 0.02, lh * 0.05, lw * 0.55, lh * 0.55], fill=leaf_color)
lld.ellipse([lw * 0.40, lh * 0.00, lw * 0.95, lh * 0.50], fill=leaf_color)
lld.ellipse([lw * 0.45, lh * 0.35, lw * 0.98, lh * 0.88], fill=leaf_color)
# soft highlight near the leaf's center, no stray vein line
lld.ellipse([lw * 0.32, lh * 0.30, lw * 0.64, lh * 0.58], fill=leaf_light)
leaf_layer = leaf_layer.rotate(-14, resample=Image.BICUBIC, expand=True)
canvas.paste(
    leaf_layer,
    (int(leaf_cx - leaf_layer.width / 2), int(leaf_cy - leaf_layer.height / 2)),
    leaf_layer,
)

# ---- Composite foreground artwork onto the gradient background ----
foreground = canvas
full = Image.alpha_composite(background, foreground)

# ---- Downscale for anti-aliasing ----
final_size = 1024
full = full.resize((final_size, final_size), Image.LANCZOS)
full.save("app_icon.png")

# Version without alpha (flat background) for iOS (no transparency allowed)
flat = Image.new("RGB", (final_size, final_size), (74, 20, 60))
flat.paste(full, (0, 0), full)
flat.save("app_icon_ios.png")

# Android adaptive icon foreground: same artwork, transparent background,
# shrunk and centered so it survives the launcher's circular/rounded crop
# (safe zone is roughly the center 66% of the canvas).
adaptive = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
scale = 0.68
scaled = foreground.resize((int(SIZE * scale), int(SIZE * scale)), Image.LANCZOS)
offset = (int((SIZE - scaled.width) / 2), int((SIZE - scaled.height) / 2))
adaptive.paste(scaled, offset, scaled)
adaptive = adaptive.resize((final_size, final_size), Image.LANCZOS)
adaptive.save("app_icon_foreground.png")

print("done")
