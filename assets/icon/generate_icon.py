"""Generates the Recolta app icon: a glossy bunch of grapes with two vine leaves.

The artwork is built as SVG (radial gradients + blurred highlights give the
berries their shine) and rasterised with headless Edge/Chrome, then Pillow
writes the three PNG variants used by flutter_launcher_icons.
"""
import math
import os
import subprocess
import sys
import tempfile

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SIZE = 1024
RENDER_SCALE = 2  # supersampling factor for the browser render

BROWSERS = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
]

# ---- Layout: berry centres on a 240x240 sketch grid, drawn back to front ----
K = 3.6           # sketch -> canvas scale
BERRY_R = 19 * K
SKETCH_CENTER = (120, 119)
BERRIES = [
    (92, 84), (116, 76),
    (70, 106), (160, 106),
    (138, 92), (104, 104),
    (88, 132), (150, 134), (120, 128),
    (102, 158), (136, 160),
    (119, 187),
    (113, 213),
]


def to_canvas(x, y):
    return ((x - SKETCH_CENTER[0]) * K + SIZE / 2,
            (y - SKETCH_CENTER[1]) * K + SIZE / 2)


DEFS = """
<defs>
  <radialGradient id="bg" cx="0.35" cy="0.25" r="0.95">
    <stop offset="0" stop-color="#FFFDF4"/>
    <stop offset="0.55" stop-color="#FBF0D3"/>
    <stop offset="1" stop-color="#EFD9A6"/>
  </radialGradient>

  <radialGradient id="berry0" cx="0.36" cy="0.32" r="0.78" fx="0.30" fy="0.26">
    <stop offset="0" stop-color="#D49BF0"/>
    <stop offset="0.22" stop-color="#A152CC"/>
    <stop offset="0.6" stop-color="#6B1F94"/>
    <stop offset="1" stop-color="#2E0842"/>
  </radialGradient>
  <radialGradient id="berry1" cx="0.36" cy="0.32" r="0.78" fx="0.30" fy="0.26">
    <stop offset="0" stop-color="#C9A0F5"/>
    <stop offset="0.22" stop-color="#8A4FD0"/>
    <stop offset="0.6" stop-color="#55209A"/>
    <stop offset="1" stop-color="#240A45"/>
  </radialGradient>
  <radialGradient id="berry2" cx="0.36" cy="0.32" r="0.78" fx="0.30" fy="0.26">
    <stop offset="0" stop-color="#E29AE6"/>
    <stop offset="0.22" stop-color="#B04CBE"/>
    <stop offset="0.6" stop-color="#7A1C86"/>
    <stop offset="1" stop-color="#360A3C"/>
  </radialGradient>

  <linearGradient id="leaf" x1="0" y1="1" x2="0.6" y2="0">
    <stop offset="0" stop-color="#2C7A2E"/>
    <stop offset="0.55" stop-color="#4FA83A"/>
    <stop offset="1" stop-color="#9BD957"/>
  </linearGradient>
  <linearGradient id="stem" x1="0" y1="0" x2="1" y2="0">
    <stop offset="0" stop-color="#5C7A2A"/>
    <stop offset="1" stop-color="#7A5A2E"/>
  </linearGradient>

  <filter id="blurS" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="2.5"/></filter>
  <filter id="blurM" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="7"/></filter>
  <filter id="blurL" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="11"/></filter>
  <filter id="drop" x="-30%" y="-30%" width="160%" height="160%">
    <feDropShadow dx="0" dy="16" stdDeviation="18" flood-color="#5A3A10" flood-opacity="0.28"/>
  </filter>
</defs>
"""


def berry_svg(cx, cy, r, variant):
    # rim light: reflected glow along the lower-right inner edge
    a0, a1 = math.radians(15), math.radians(105)
    rr = r * 0.80
    x0, y0 = cx + rr * math.cos(a0), cy + rr * math.sin(a0)
    x1, y1 = cx + rr * math.cos(a1), cy + rr * math.sin(a1)
    hx, hy = cx - r * 0.34, cy - r * 0.40
    return f"""
  <circle cx="{cx + 7:.1f}" cy="{cy + 11:.1f}" r="{r:.1f}" fill="#1A0428" opacity="0.38" filter="url(#blurM)"/>
  <circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" fill="url(#berry{variant})"/>
  <circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r - 1.5:.1f}" fill="none" stroke="#22062F" stroke-width="3" opacity="0.45"/>
  <path d="M {x0:.1f} {y0:.1f} A {rr:.1f} {rr:.1f} 0 0 1 {x1:.1f} {y1:.1f}" fill="none"
        stroke="#E2B4FA" stroke-width="{r * 0.10:.1f}" stroke-linecap="round" opacity="0.55" filter="url(#blurS)"/>
  <ellipse cx="{hx:.1f}" cy="{hy:.1f}" rx="{r * 0.50:.1f}" ry="{r * 0.36:.1f}" fill="#FFFFFF" opacity="0.26"
           transform="rotate(-38 {hx:.1f} {hy:.1f})" filter="url(#blurL)"/>
  <ellipse cx="{hx:.1f}" cy="{hy:.1f}" rx="{r * 0.27:.1f}" ry="{r * 0.16:.1f}" fill="#FFFFFF" opacity="0.92"
           transform="rotate(-38 {hx:.1f} {hy:.1f})" filter="url(#blurS)"/>
  <circle cx="{cx - r * 0.60:.1f}" cy="{cy - r * 0.02:.1f}" r="{r * 0.065:.1f}" fill="#FFFFFF" opacity="0.75"/>
"""


# Serrated vine-leaf outline, right half only (base at origin, tip pointing up)
LEAF_HALF = [(55, -25), (125, -10), (112, -75), (170, -105), (128, -150),
             (158, -205), (98, -215), (85, -272), (38, -258)]
LEAF_TIP = (0, -325)
LEAF_VEINS = [((0, -30), (112, -22)), ((0, -55), (155, -108)),
              ((0, -125), (145, -200)), ((0, -195), (78, -264))]


def leaf_svg(bx, by, angle, sx, sy):
    right = [(0, 0)] + LEAF_HALF + [LEAF_TIP]
    left = [(-x, y) for x, y in reversed(LEAF_HALF)] + [(0, 0)]
    pts = right + left
    d = f"M {pts[0][0]} {pts[0][1]}"
    for (ax, ay), (px, py) in zip(pts, pts[1:]):
        mx, my = (ax + px) / 2, (ay + py) / 2
        # pull the control point towards the midrib so edges between teeth curve inward
        cxp = mx - math.copysign(12, mx) if mx else mx
        d += f" Q {cxp:.1f} {my + 6:.1f} {px} {py}"
    d += " Z"
    veins = f'<path d="M 0 0 L 0 -300" />'
    for (ax, ay), (px, py) in LEAF_VEINS:
        veins += f'<path d="M {ax} {ay} Q {px * 0.5:.0f} {ay - 8} {px} {py}"/>'
        veins += f'<path d="M {-ax} {ay} Q {-px * 0.5:.0f} {ay - 8} {-px} {py}"/>'
    return f"""
  <g transform="translate({bx:.1f} {by:.1f}) rotate({angle}) scale({sx} {sy})">
    <path d="{d}" fill="url(#leaf)" stroke="#1F5E24" stroke-width="6" stroke-linejoin="round"/>
    <path d="M 0 0 {' '.join(f'L {x} {y}' for x, y in LEAF_HALF)} L 0 -325 Z" fill="#FFFFFF" opacity="0.10"/>
    <g fill="none" stroke="#D3F0A8" stroke-width="5" stroke-linecap="round" opacity="0.7">{veins}</g>
  </g>
"""


def artwork_svg():
    parts = []
    lbx, lby = to_canvas(124, 68)
    rbx, rby = to_canvas(138, 62)
    parts.append(leaf_svg(lbx, lby, -73, 0.80, 1.08))
    parts.append(leaf_svg(rbx, rby, 102, 0.72, 0.86))

    # stem: rises from the top of the bunch and curls to the right
    s0 = to_canvas(124, 84)
    s1 = to_canvas(126, 60)
    s2 = to_canvas(140, 50)
    s3 = to_canvas(160, 46)
    stem_d = (f"M {s0[0]:.1f} {s0[1]:.1f} C {s1[0]:.1f} {s1[1]:.1f} "
              f"{s2[0]:.1f} {s2[1]:.1f} {s3[0]:.1f} {s3[1]:.1f}")
    parts.append(f'<path d="{stem_d}" fill="none" stroke="#3E2A12" stroke-width="26" stroke-linecap="round"/>')
    parts.append(f'<path d="{stem_d}" fill="none" stroke="url(#stem)" stroke-width="19" stroke-linecap="round"/>')
    parts.append(f'<path d="{stem_d}" fill="none" stroke="#C9B26A" stroke-width="5" stroke-linecap="round" '
                 f'opacity="0.55" transform="translate(-4 -4)"/>')

    for i, (x, y) in enumerate(BERRIES):
        cx, cy = to_canvas(x, y)
        parts.append(berry_svg(cx, cy, BERRY_R, i % 3))
    return "".join(parts)


def svg_doc(background, art_scale=1.08):
    """background: 'rounded' | 'square' | None"""
    bg = ""
    if background == "rounded":
        bg = f'<rect width="{SIZE}" height="{SIZE}" rx="{SIZE * 0.22}" fill="url(#bg)"/>'
    elif background == "square":
        bg = f'<rect width="{SIZE}" height="{SIZE}" fill="url(#bg)"/>'
    c = SIZE / 2
    art = (f'<g filter="url(#drop)" transform="translate({c} {c - 14 * art_scale}) scale({art_scale}) '
           f'translate({-c} {-c})">{artwork_svg()}</g>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}" '
            f'width="{SIZE}" height="{SIZE}">{DEFS}{bg}{art}</svg>')


def render(svg, out_path, opaque):
    browser = next((b for b in BROWSERS if os.path.exists(b)), None)
    if browser is None:
        sys.exit("Edge/Chrome not found - needed to rasterise the SVG")
    with tempfile.TemporaryDirectory() as tmp:
        html = os.path.join(tmp, "icon.html")
        shot = os.path.join(tmp, "shot.png")
        with open(html, "w", encoding="utf-8") as f:
            f.write("<!doctype html><html><body style='margin:0;background:transparent'>"
                    + svg + "</body></html>")
        # window is larger than the artwork, then cropped: headless window
        # sizes are not guaranteed to match the viewport exactly
        subprocess.run([
            browser, "--headless=new", "--disable-gpu", "--hide-scrollbars",
            f"--user-data-dir={os.path.join(tmp, 'profile')}",
            f"--force-device-scale-factor={RENDER_SCALE}",
            "--default-background-color=00000000",
            f"--window-size={SIZE + 100},{SIZE + 100}",
            f"--screenshot={shot}", "file:///" + html.replace("\\", "/"),
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        img = Image.open(shot).convert("RGBA")
        img = img.crop((0, 0, SIZE * RENDER_SCALE, SIZE * RENDER_SCALE))
        img = img.resize((SIZE, SIZE), Image.LANCZOS)
    if opaque:
        # iOS rejects icons with an alpha channel
        img = img.convert("RGB")
    img.save(out_path)


with open(os.path.join(HERE, "app_icon.svg"), "w", encoding="utf-8") as f:
    f.write(svg_doc("rounded"))

# Windows / in-app: rounded square with transparent corners
render(svg_doc("rounded"), os.path.join(HERE, "app_icon.png"), opaque=False)
# iOS: full-bleed square, the system applies its own corner mask
render(svg_doc("square"), os.path.join(HERE, "app_icon_ios.png"), opaque=True)
# Android adaptive foreground: artwork only, shrunk into the launcher safe zone
render(svg_doc(None, art_scale=0.68), os.path.join(HERE, "app_icon_foreground.png"), opaque=False)

print("done")
