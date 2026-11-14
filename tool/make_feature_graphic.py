#!/usr/bin/env python3
"""Draws the Google Play feature graphic: art/play-store/feature-graphic.png.

The picture is 1024 x 500, with the app icon and name on the left and a tilted
board on the right. It has no other text, so one picture serves every language.
Run it by hand, from anywhere, when the icon or the board's look changes:

    python3 -m pip install pillow
    python3 tool/make_feature_graphic.py

The name uses Fredoka SemiBold (art/fonts/), under the SIL Open Font License.
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ART = Path(__file__).resolve().parent.parent / "art"
OUTPUT = ART / "play-store" / "feature-graphic.png"
FONT = ART / "fonts" / "Fredoka-SemiBold.ttf"
ICON = ART / "app-icon-1024.png"

WIDTH, HEIGHT = 1024, 500
SCALE = 3  # everything is drawn three times as large, then shrunk, to smooth edges
NAME = "Cephalopod"
NAME_WIDTH = 440
BOARD_SIZE = 600
BOARD_TILT_DEGREES = 16
BOARD_CENTRE = (810, 270)  # right of the middle, so the right edge is cropped
ICON_SIZE = 124
LEFT_MARGIN = 66

GRADIENT_INNER = (10, 74, 66)
GRADIENT_OUTER = (3, 32, 28)
BOARD_FILL = (9, 56, 50)
BOARD_BORDER = (42, 128, 115, 170)
EMPTY_SQUARE = (12, 68, 60)
EMPTY_BORDER = (42, 128, 115, 100)
HIGHLIGHT = (94, 234, 212)
NAME_COLOUR = (232, 251, 246)
NAME_HARD_SHADOW = (2, 22, 19, 255)

# A die is (face, edge, pips).
CORAL = ((255, 122, 92), (194, 74, 48), (58, 18, 8))
CREAM = ((246, 239, 226), (205, 190, 158), (15, 46, 42))

PIP_POSITIONS = {
    1: [(.5, .5)],
    2: [(.28, .28), (.72, .72)],
    3: [(.28, .28), (.5, .5), (.72, .72)],
    4: [(.28, .28), (.72, .28), (.28, .72), (.72, .72)],
    5: [(.28, .28), (.72, .28), (.5, .5), (.28, .72), (.72, .72)],
    6: [(.28, .26), (.72, .26), (.28, .5), (.72, .5), (.28, .74), (.72, .74)],
}

# What each square holds. "going" is a die about to be captured, drawn as a
# dashed outline; "placed" is the die just put down, with the highlight.
BOARD_LAYOUT = [
    [("cream", 1), None, ("coral", 2), None, ("cream", 1)],
    [None, ("coral", 1), ("going-grey", 2), ("cream", 3), None],
    [("coral", 6), None, ("placed", 5), ("going-coral", 3), None],
    [("cream", 2), None, ("coral", 4), None, ("coral", 1)],
    [None, ("cream", 5), None, ("cream", 1), None],
]
GOING_COLOURS = {"going-grey": (160, 190, 180), "going-coral": (200, 110, 90)}


def px(value):
    """A length in final pixels, as a length in drawing pixels."""
    return int(round(value * SCALE))


def draw_background():
    image = Image.new("RGB", (WIDTH, HEIGHT))
    pixels = image.load()
    centre_x, centre_y, radius = 700, 250, 700
    for y in range(HEIGHT):
        for x in range(WIDTH):
            t = min(1.0, math.hypot(x - centre_x, y - centre_y) / radius)
            pixels[x, y] = tuple(
                int(GRADIENT_INNER[i] + (GRADIENT_OUTER[i] - GRADIENT_INNER[i]) * t)
                for i in range(3)
            )
    enlarged = image.resize((WIDTH * SCALE, HEIGHT * SCALE), Image.BICUBIC)
    return enlarged.convert("RGBA")


class BoardPainter:
    """Draws the flat board; everything is sized from the board's size."""

    def __init__(self, size):
        self.layer = Image.new("RGBA", (px(size), px(size)), (0, 0, 0, 0))
        self.draw = ImageDraw.Draw(self.layer)
        self.size = size
        self.unit = size / 420  # the shapes were designed on a 420-wide board
        padding, gap = 20 * self.unit, 10 * self.unit
        self.padding, self.gap = padding, gap
        self.cell = (size - 2 * padding - 4 * gap) / 5
        self.radius = 13 * self.unit

    def square_origin(self, row, column):
        step = self.cell + self.gap
        return self.padding + column * step, self.padding + row * step

    def rounded(self, box, radius, fill=None, outline=None, width=1):
        self.draw.rounded_rectangle(
            [px(v) for v in box], radius=px(radius), fill=fill, outline=outline, width=px(width)
        )

    def pips(self, x, y, count, colour, size):
        for across, down in PIP_POSITIONS[count]:
            cx, cy = x + across * self.cell, y + down * self.cell
            r = self.cell * size
            self.draw.ellipse([px(cx - r), px(cy - r), px(cx + r), px(cy + r)], fill=colour)

    def die(self, x, y, colours, count):
        face, edge, pip = colours
        depth = 5 * self.unit
        self.rounded((x, y + depth, x + self.cell, y + self.cell + depth), self.radius, fill=edge)
        self.rounded((x, y, x + self.cell, y + self.cell), self.radius, fill=face)
        self.pips(x, y, count, pip, 0.065)

    def going_die(self, x, y, colour, count):
        self.rounded((x, y, x + self.cell, y + self.cell), self.radius, fill=(12, 58, 52))
        self.dashed_outline(x, y, colour)
        self.pips(x, y, count, colour + (200,), 0.055)

    def dashed_outline(self, x, y, colour):
        points = self.outline_points(x, y)
        dash, gap = 7 * self.unit, 5 * self.unit
        drawing, used = True, 0.0
        for (ax, ay), (bx, by) in zip(points, points[1:]):
            length = math.hypot(bx - ax, by - ay)
            at = 0.0
            while at < length:
                limit = dash if drawing else gap
                step = min(limit - used, length - at)
                if drawing:
                    self.draw.line(
                        [px(ax + (bx - ax) * at / length), px(ay + (by - ay) * at / length),
                         px(ax + (bx - ax) * (at + step) / length),
                         px(ay + (by - ay) * (at + step) / length)],
                        fill=colour, width=px(2.4 * self.unit),
                    )
                at += step
                used += step
                if used >= limit - 1e-9:
                    drawing, used = not drawing, 0.0

    def outline_points(self, x, y):
        """The outline of a square with rounded corners, as short straight pieces."""
        inset, r = 1.5 * self.unit, self.radius
        left, top = x + inset, y + inset
        right, bottom = x + self.cell - inset, y + self.cell - inset
        points = []

        def corner(cx, cy, from_degrees):
            for i in range(13):
                angle = math.radians(from_degrees + 90 * i / 12)
                points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))

        points += [(left + r, top), (right - r, top)]
        corner(right - r, top + r, -90)
        points.append((right, bottom - r))
        corner(right - r, bottom - r, 0)
        points.append((left + r, bottom))
        corner(left + r, bottom - r, 90)
        points.append((left, top + r))
        corner(left + r, top + r, 180)
        points.append(points[0])
        return points

    def placed_die(self, x, y, count):
        margin, depth = 8 * self.unit, 14 * self.unit
        glow = Image.new("RGBA", self.layer.size, (0, 0, 0, 0))
        ImageDraw.Draw(glow).rounded_rectangle(
            [px(x - margin), px(y - margin), px(x + self.cell + margin), px(y + self.cell + depth)],
            radius=px(20 * self.unit), fill=HIGHLIGHT + (160,),
        )
        self.layer.alpha_composite(glow.filter(ImageFilter.GaussianBlur(px(10 * self.unit))))
        self.draw = ImageDraw.Draw(self.layer)
        self.die(x, y, CORAL, count)
        ring = 4 * self.unit
        self.rounded(
            (x - ring, y - ring, x + self.cell + ring, y + self.cell + 9 * self.unit),
            17 * self.unit, outline=HIGHLIGHT, width=3 * self.unit,
        )

    def paint_square(self, row, column, content):
        x, y = self.square_origin(row, column)
        if content is None:
            self.rounded((x, y, x + self.cell, y + self.cell), self.radius,
                         fill=EMPTY_SQUARE, outline=EMPTY_BORDER, width=1.2 * self.unit)
            return
        kind, count = content
        if kind == "coral":
            self.die(x, y, CORAL, count)
        elif kind == "cream":
            self.die(x, y, CREAM, count)
        elif kind in GOING_COLOURS:
            self.going_die(x, y, GOING_COLOURS[kind], count)

    def paint(self):
        self.rounded((0, 0, self.size, self.size), 34 * self.unit,
                     fill=BOARD_FILL, outline=BOARD_BORDER, width=2.5 * self.unit)
        for row, squares in enumerate(BOARD_LAYOUT):
            for column, content in enumerate(squares):
                self.paint_square(row, column, content)
        # The placed die is drawn last, so its highlight sits over its neighbours.
        for row, squares in enumerate(BOARD_LAYOUT):
            for column, content in enumerate(squares):
                if content and content[0] == "placed":
                    x, y = self.square_origin(row, column)
                    self.placed_die(x, y, content[1])
        return self.layer


def place_board(canvas):
    board = BoardPainter(BOARD_SIZE).paint()
    tilted = board.rotate(BOARD_TILT_DEGREES, resample=Image.BICUBIC, expand=True)
    left = px(BOARD_CENTRE[0]) - tilted.size[0] // 2
    top = px(BOARD_CENTRE[1]) - tilted.size[1] // 2

    shadow_mask = tilted.split()[3].point(lambda v: int(v * 0.55))
    shadow = Image.new("RGBA", tilted.size, (0, 0, 0, 255))
    shadow.putalpha(shadow_mask)
    shadow_layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_layer.paste(shadow, (left - px(6), top + px(14)), shadow)
    canvas.alpha_composite(shadow_layer.filter(ImageFilter.GaussianBlur(px(16))))

    board_layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    board_layer.paste(tilted, (left, top), tilted)
    canvas.alpha_composite(board_layer)


def place_icon(canvas, top):
    size = px(ICON_SIZE)
    icon = Image.open(ICON).convert("RGBA").resize((size, size), Image.LANCZOS)
    mask = Image.new("L", icon.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=px(29), fill=255
    )
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [px(LEFT_MARGIN), px(top + 6), px(LEFT_MARGIN + ICON_SIZE), px(top + ICON_SIZE + 6)],
        radius=px(29), fill=(0, 0, 0, 120),
    )
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(px(8))))
    canvas.paste(icon, (px(LEFT_MARGIN), px(top)), mask)


def name_font(canvas):
    """The biggest size at which the name is NAME_WIDTH wide."""
    draw = ImageDraw.Draw(canvas)
    size = 40
    while True:
        font = ImageFont.truetype(str(FONT), px(size))
        if draw.textlength(NAME, font=font) / SCALE >= NAME_WIDTH:
            return font
        size += 1


def place_name(canvas, top):
    font = name_font(canvas)
    position_x = px(LEFT_MARGIN - 2)
    position_y = px(top)
    # A hard shadow straight under the letters, then a soft one below it.
    for drop, blur, colour in ((6, 0, NAME_HARD_SHADOW), (14, 14, (0, 0, 0, 130))):
        shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        ImageDraw.Draw(shadow).text(
            (position_x, position_y + px(drop)), NAME, font=font, fill=colour
        )
        if blur:
            shadow = shadow.filter(ImageFilter.GaussianBlur(px(blur / 2)))
        canvas.alpha_composite(shadow)
    ImageDraw.Draw(canvas).text((position_x, position_y), NAME, font=font, fill=NAME_COLOUR)


def place_brand(canvas):
    name_height = 84
    top = (HEIGHT - (ICON_SIZE + 24 + name_height)) / 2
    place_icon(canvas, top)
    place_name(canvas, top + ICON_SIZE + 4)


def main():
    canvas = draw_background()
    place_board(canvas)
    place_brand(canvas)
    picture = canvas.resize((WIDTH, HEIGHT), Image.LANCZOS).convert("RGB")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    picture.save(OUTPUT)
    print(f"Wrote {OUTPUT.relative_to(ART.parent)} ({WIDTH} x {HEIGHT})")


if __name__ == "__main__":
    main()
