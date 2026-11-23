#!/usr/bin/env python3
"""Draws the six placeholder sample images in agents/developer/test-images/.

Needs Pillow (a local drawing tool, not part of the app). No network.
    python3 agents/developer/tools/make_test_images.py

These are synthetic stand-ins. Replace them with real screenshots that
keep the same file names. See test-images/README.md.
"""
import os

from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "test-images")
W, H = 780, 1688


def font(size):
    return ImageFont.load_default(size=size)


def canvas(color):
    image = Image.new("RGB", (W, H), color)
    return image, ImageDraw.Draw(image)


def lines(draw, x, y, rows, fill, gap=18):
    for text, size in rows:
        draw.text((x, y), text, font=font(size), fill=fill)
        y += size + gap
    return y


def flyer():
    image, d = canvas("#FFF4D6")
    d.rectangle([40, 40, W - 40, H - 40], outline="#C2410C", width=10)
    lines(d, 90, 200, [
        ("SUMMER STREET", 76), ("FOOD FESTIVAL", 76), ("", 30),
        ("Saturday 18 July 2026", 52), ("12:00 to 20:00", 52), ("", 30),
        ("Riverside Park, Bristol", 44), ("Free entry", 44), ("", 30),
        ("Live music. 40 stalls.", 38), ("Bring a blanket.", 38),
    ], "#7C2D12")
    return image


def poster():
    image, d = canvas("#111827")
    d.ellipse([190, 140, 590, 540], outline="#F472B6", width=14)
    lines(d, 80, 640, [
        ("THE NIGHT OWLS", 78), ("LIVE IN CONCERT", 56), ("", 30),
        ("Friday 9 October 2026", 52), ("Doors 7:30pm", 52), ("", 30),
        ("O2 Academy, Leeds", 46), ("Tickets from 25 pounds", 40),
    ], "#F9FAFB")
    return image


def chat():
    image, d = canvas("#ECE5DD")
    d.rectangle([0, 0, W, 150], fill="#075E54")
    d.text((40, 50), "Priya", font=font(52), fill="white")

    def bubble(y, rows, mine):
        height = 40 + len(rows) * 58
        x0, x1 = (170, W - 30) if mine else (30, W - 170)
        d.rounded_rectangle([x0, y, x1, y + height], radius=24, fill="#DCF8C6" if mine else "white")
        for index, text in enumerate(rows):
            d.text((x0 + 26, y + 22 + index * 58), text, font=font(40), fill="#111111")
        return y + height + 36

    y = 220
    y = bubble(y, ["Are you free next week?"], False)
    y = bubble(y, ["I think so. What is the plan?"], True)
    # Deliberate mismatch: 15 August 2026 is a Saturday, not a Wednesday.
    y = bubble(y, ["Dinner at 9pm on Wednesday", "the 15th of August.", "Luigi's on Park Street."], False)
    bubble(y, ["Perfect. See you there."], True)
    return image


def ticket():
    image, d = canvas("#F3F4F6")
    d.rounded_rectangle([40, 240, W - 40, 1240], radius=36, fill="white", outline="#1D4ED8", width=6)
    d.rectangle([40, 240, W - 40, 400], fill="#1D4ED8")
    d.text((80, 285), "BOARDING PASS", font=font(64), fill="white")
    lines(d, 80, 450, [
        ("Passenger: A SAMPLE", 40), ("Flight: BA 0478", 48),
        ("From: London Heathrow (LHR)", 40), ("To: Barcelona (BCN)", 40),
        ("Date: 18 SEP 2026", 52), ("Departs: 07:25", 52),
        ("Gate closes: 06:55", 40), ("Seat: 14C", 40), ("Booking ref: X7K9QP", 40),
    ], "#111827", gap=24)
    x = 80
    for index in range(60):
        width = 4 + (index * 7) % 9
        d.rectangle([x, 1080, x + width, 1190], fill="#111827")
        x += width + 5
    return image


def diagram():
    image, d = canvas("white")
    d.text((60, 80), "Kitchen refit plan", font=font(56), fill="#111827")
    boxes = [("Order units", 240), ("Electrician", 520), ("Fit worktops", 800), ("Final check", 1080)]
    notes = ["by 3 March", "week of 16 March", "30 March", "Friday 3 April"]
    for (label, y), note in zip(boxes, notes):
        d.rounded_rectangle([140, y, 640, y + 170], radius=20, outline="#2563EB", width=6)
        d.text((180, y + 28), label, font=font(46), fill="#111827")
        d.text((180, y + 96), note, font=font(36), fill="#4B5563")
        if y < 1080:
            d.line([390, y + 170, 390, y + 280], fill="#2563EB", width=6)
            d.polygon([(370, y + 250), (410, y + 250), (390, y + 280)], fill="#2563EB")
    return image


def no_text_photo():
    image, d = canvas("#7DD3FC")
    for row in range(900):
        shade = 125 + int(100 * row / 900)
        d.line([0, row, W, row], fill=(shade, 211, 252))
    d.ellipse([520, 140, 700, 320], fill="#FDE047")
    d.polygon([(0, 1150), (260, 620), (520, 1150)], fill="#475569")
    d.polygon([(300, 1150), (590, 520), (W, 1150)], fill="#334155")
    d.polygon([(545, 615), (590, 520), (640, 625), (590, 600)], fill="white")
    d.rectangle([0, 1150, W, H], fill="#15803D")
    d.ellipse([120, 1250, 430, 1420], fill="#0EA5E9")
    return image


SAMPLES = {
    "flyer": flyer,
    "poster": poster,
    "chat": chat,
    "ticket": ticket,
    "diagram": diagram,
    "no-text-photo": no_text_photo,
}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, draw in SAMPLES.items():
        path = os.path.join(OUT, f"{name}.png")
        draw().save(path, optimize=True)
        print(f"{name}.png {os.path.getsize(path)} bytes")
