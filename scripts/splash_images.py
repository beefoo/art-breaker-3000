import argparse
import os
import shutil

from PIL import Image

from helper import make_directories

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--in", dest="IMAGE", default="godot/icons/icon-splash.png", help="Path to source icon")
    parser.add_argument("--bg", dest="BACKGROUND", default="181818", help="Background color")
    parser.add_argument("--size", dest="ICON_SIZE", default=0.4, type=float, help="Size of icon as a percent of smaller dimension")
    parser.add_argument("--out", dest="OUTPUT_DIR", default="godot/icons/splash_ios/", help="Path to output directory")
    parser.add_argument("--overwrite", dest="OVERWRITE", action="store_true", help="Overwrite image files if already exists")
    return parser.parse_args()

def main(args):
    make_directories(args.OUTPUT_DIR)
    splash_images = [
        {"filename": "ipad_1024x768.png", "width": 1024, "height": 768},
        {"filename": "ipad_2048x1536.png", "width": 2048, "height": 1536},
        {"filename": "iphone_2208x1242.png", "width": 2208, "height": 1242},
        {"filename": "iphone_2436x1125.png", "width": 2436, "height": 1125},
        {"filename": "ipad_768x1024.png", "width": 768, "height": 1024},
        {"filename": "ipad_1536x2048.png", "width": 1536, "height": 2048},
        {"filename": "iphone_640x960.png", "width": 640, "height": 960},
        {"filename": "iphone_640x1136.png", "width": 640, "height": 1136},
        {"filename": "iphone_750x1334.png", "width": 750, "height": 1334},
        {"filename": "iphone_1125x2436.png", "width": 1125, "height": 2436},
        {"filename": "iphone_1242x2208.png", "width": 1242, "height": 2208}
    ]
    im = Image.open(args.IMAGE)
    for d in splash_images:
        filepath = f"{args.OUTPUT_DIR}{d['filename']}"

        # Check if file exists
        if not args.OVERWRITE and os.path.isfile(filepath):
            print(f"Already created {filepath}; skipping.")
            continue

        rgb = [int(args.BACKGROUND[i:i+2], 16) for i in (0, 2, 4)]
        rgba = tuple(rgb + [255])

        bg = Image.new("RGBA", (d["width"], d["height"]), rgba)
        icon_size = int(round(min(d["width"], d["height"]) * args.ICON_SIZE))
        
        # Resize icon
        resized = im.resize((icon_size, icon_size), Image.Resampling.NEAREST)

        # Paste icon
        x = int(round((d["width"] - icon_size) * 0.5))
        y = int(round((d["height"] - icon_size) * 0.5))
        bg.paste(resized, (x, y), resized)
        
        # Save splash image
        bg.save(filepath)
        print(f"Created {filepath}")

    print("Done.")

main(parse_args())


