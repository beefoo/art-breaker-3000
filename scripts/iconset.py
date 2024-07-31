import argparse
import os
import shutil

from PIL import Image

from helper import make_directories

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--in", dest="SOURCE_IMAGE", default="godot/icons/icon_macos.png", help="Path to source icon")
    parser.add_argument("--out", dest="OUTPUT_DIR", default="godot/icons/icon.iconset_macos/", help="Path to output iconset")
    parser.add_argument("--overwrite", dest="OVERWRITE", action="store_true", help="Overwrite image files if already exists")
    return parser.parse_args()

def main(args):
    make_directories(args.OUTPUT_DIR)
    # https://gist.github.com/ansarizafar/6fa64f44aa933794c4d6638eec32b9aa
    iconset = [
        {"filename": "icon_16x16.png", "width": 16, "height": 16},
        {"filename": "icon_16x16@2x.png", "width": 32, "height": 32},
        {"filename": "icon_32x32.png", "width": 32, "height": 32},
        {"filename": "icon_32x32@2x.png", "width": 64, "height": 64},
        {"filename": "icon_128x128.png", "width": 128, "height": 128},
        {"filename": "icon_128x128@2x.png", "width": 256, "height": 256},
        {"filename": "icon_256x256.png", "width": 256, "height": 256},
        {"filename": "icon_256x256@2x.png", "width": 512, "height": 512},
        {"filename": "icon_512x512.png", "width": 512, "height": 512},
        {"filename": "icon_512x512@2x.png", "width": 1024, "height": 1024}
    ]
    im = Image.open(args.SOURCE_IMAGE)
    imw, imh = im.size
    for ico in iconset:
        filepath = f"{args.OUTPUT_DIR}{ico['filename']}"

        # Check if file exists
        if not args.OVERWRITE and os.path.isfile(filepath):
            print(f"Already created {filepath}; skipping.")
            continue
        
        # If already the same size, just copy it over
        if imw == ico["width"] and imh == ico["height"]:
            shutil.copyfile(args.SOURCE_IMAGE, filepath)
            print(f"Created {filepath} via copy")
            continue
        
        # Resize and save
        resized = im.resize((ico["width"], ico["height"]), Image.Resampling.NEAREST)
        resized.save(filepath)
        print(f"Created {filepath} via resize")

    print("Done.")

main(parse_args())


