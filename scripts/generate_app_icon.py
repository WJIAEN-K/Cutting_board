#!/usr/bin/env python3
"""
生成剪贴板应用图标（与 Pencil 设计一致：macOS 26 简约风格）
输出多尺寸 PNG 到 Cutting_board/Assets.xcassets/AppIcon.appiconset/
"""
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("请先安装 Pillow: pip3 install Pillow")
    raise SystemExit(1)

# 设计稿基准 256px，按比例缩放
BASE = 256
BG_FILL = (0xF5, 0xF5, 0xF7, 255)
SHAPE_FILL = (0x1C, 0x1C, 0x1E, 255)


def draw_icon(size: int) -> Image.Image:
    scale = size / BASE
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    def rect(x, y, w, h, r):
        return [
            int(x * scale),
            int(y * scale),
            int((x + w) * scale),
            int((y + h) * scale),
        ], int(max(1, r * scale))

    # 背景（圆角方）
    (x1, y1, x2, y2), r = rect(0, 0, BASE, BASE, 56)
    draw.rounded_rectangle([x1, y1, x2, y2], radius=r, fill=BG_FILL)

    # 剪贴板板面
    (x1, y1, x2, y2), r = rect(48, 64, 160, 168, 12)
    draw.rounded_rectangle([x1, y1, x2, y2], radius=r, fill=SHAPE_FILL)

    # 夹子
    (x1, y1, x2, y2), r = rect(92, 36, 72, 44, 10)
    draw.rounded_rectangle([x1, y1, x2, y2], radius=r, fill=SHAPE_FILL)

    # 三条横线
    for ox, oy, w in [(72, 108, 112), (72, 126, 96), (72, 144, 80)]:
        (x1, y1, x2, y2), r = rect(ox, oy, w, 5, 2.5)
        draw.rounded_rectangle([x1, y1, x2, y2], radius=r, fill=SHAPE_FILL)

    return img


def main():
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    out_dir = project_root / "Cutting_board" / "Assets.xcassets" / "AppIcon.appiconset"
    out_dir.mkdir(parents=True, exist_ok=True)

    # macOS AppIcon 需要的尺寸（同一图可复用于多 scale）
    sizes = [1024, 512, 256, 128, 64, 32, 16]
    for s in sizes:
        icon = draw_icon(s)
        icon.save(out_dir / f"icon_{s}.png", "PNG")
        print(f"  icon_{s}.png")

    print(f"已生成 {len(sizes)} 个图标 → {out_dir}")


if __name__ == "__main__":
    main()
