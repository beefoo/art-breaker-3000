import argparse
import os

from PIL import Image

from helper import make_directories

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--in", dest="SOURCE_DIR", default="godot/icons/", help="Path to source icon")
    parser.add_argument("--preset", dest="PRESET", choices=["macos", "ios"], default="macos", help="Which preset to use")
    parser.add_argument("--out", dest="OUTPUT_DIR", default="godot/icons/", help="Path to output iconset")
    parser.add_argument("--overwrite", dest="OVERWRITE", action="store_true", help="Overwrite image files if already exists")
    return parser.parse_args()

def main(args):
    make_directories(f"{args.OUTPUT_DIR}icon.iconset_{args.PRESET}/")
    # https://gist.github.com/ansarizafar/6fa64f44aa933794c4d6638eec32b9aa
    iconsets = {
        "macos": [
            {"filename": "icon_16x16.png", "width": 16, "height": 16},
            {"filename": "icon_16x16@2x.png", "width": 32, "height": 32},
            {"filename": "icon_32x32.png", "width": 32, "height": 32},
            {"filename": "icon_32x32@2x.png", "width": 64, "height": 64},
            {"filename": "icon_128x128.png", "width": 128, "height": 128},
            {"filename": "icon_128x128@2x.png", "width": 256, "height": 256},
            {"filename": "icon_256x256.png", "width": 256, "height": 256},
            {"filename": "icon_256x256@2x.png", "width": 512, "height": 512},
            {"filename": "icon_512x512.png", "width": 512, "height": 512},
            {"filename": "icon_512x512@2x.png", "width": 1024, "height": 1024},
            {"filename": "icon_512x512@3x.png", "width": 1536, "height": 1536}
        ],
        "ios": [
            {"filename": "app_store_1024x1024.png", "width": 1024, "height": 1024},
            {"filename": "ipad_76x76.png", "width": 76, "height": 76},
            {"filename": "ipad_152x152.png", "width": 152, "height": 152},
            {"filename": "ipad_167x167.png", "width": 167, "height": 167},
            {"filename": "iphone_120x120.png", "width": 120, "height": 120},
            {"filename": "iphone_180x180.png", "width": 180, "height": 180},
            {"filename": "notification_40x40.png", "width": 40, "height": 40},
            {"filename": "notification_60x60.png", "width": 60, "height": 60},
            {"filename": "settings_58x58.png", "width": 58, "height": 58},
            {"filename": "settings_87x87.png", "width": 87, "height": 87},
            {"filename": "spotlight_40x40.png", "width": 40, "height": 40},
            {"filename": "spotlight_80x80.png", "width": 80, "height": 80}
        ]
    }
    iconset = iconsets[args.PRESET]
    file_source = f"{args.SOURCE_DIR}icon_{args.PRESET}.png"
    im = Image.open(file_source)
    im.convert("RGB")
    imw, imh = im.size
    for ico in iconset:
        filepath = f"{args.OUTPUT_DIR}icon.iconset_{args.PRESET}/{ico['filename']}"

        # Check if file exists
        if not args.OVERWRITE and os.path.isfile(filepath):
            print(f"Already created {filepath}; skipping.")
            continue
        
        # # If already the same size, just copy it over
        # if imw == ico["width"] and imh == ico["height"]:
        #     shutil.copyfile(file_source, filepath)
        #     print(f"Created {filepath} via copy")
        #     continue
        
        # Resize and save
        resized = im.resize((ico["width"], ico["height"]), Image.Resampling.NEAREST)
        resized.save(filepath)
        print(f"Created {filepath} via resize")

    print("Done.")

main(parse_args())


