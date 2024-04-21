import argparse
import glob
import os
import re

from PIL import Image
from tqdm import tqdm

from helper import make_directories

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--in", dest="INPUT_FILES", default="frames/*.png", help="Path to input image files")
    parser.add_argument("--fcount", dest="FRAME_COUNT", type=int, default=12, help="Max number of frames per spritesheet")
    parser.add_argument("--fwidth", dest="FRAME_W", type=int, default=128, help="Target frame width")
    parser.add_argument("--fheight", dest="FRAME_H", type=int, default=128, help="Target frame height")
    parser.add_argument("--colors", dest="COLORS", type=int, default=16, help="Target color count")
    parser.add_argument("--out", dest="OUTPUT_DIR", default="godot/art/spritesheets/", help="Path to output image spritesheets")
    return parser.parse_args()

def main(args):
    files = glob.glob(args.INPUT_FILES)
    files = sorted(files)

    groups = {}
    pattern = re.compile(r"^([A-Za-z]+)[0-9]+$")

    # Put filenames into groups
    for fn in files:
        basename = os.path.splitext(os.path.basename(fn))[0]
        match = re.match(pattern, basename)
        group_name = match.group(1)
        if group_name not in groups:
            groups[group_name] = []
        groups[group_name].append(fn)

    # Make a sprite sheet for each group
    make_directories(args.OUTPUT_DIR)
    for group_name, frames in tqdm(groups.items()):
        frames = sorted(frames)
        count = len(frames)
        sprite_frames = frames

        # Sample the full set of frames if count is larger than target
        if count > args.FRAME_COUNT:
            sprite_frames = []
            step = 1.0 * count / args.FRAME_COUNT
            for i in range(args.FRAME_COUNT):
                index = min(int(round(i * step)), count - 1)
                sprite_frames.append(frames[index])

        # Create spritesheet
        image_h = len(sprite_frames) * args.FRAME_H
        base_image = Image.new("RGB", (args.FRAME_W, image_h))
        for i, image_fn in enumerate(sprite_frames):
            im = Image.open(image_fn)
            im = im.convert("RGB")
            resized = im.resize((args.FRAME_W, args.FRAME_H), Image.Resampling.NEAREST)
            y = i * args.FRAME_H
            base_image.paste(resized, (0, y))

        # Convert to 8-bit color and save
        base_image = base_image.convert("P", palette=Image.Palette.ADAPTIVE, colors=args.COLORS)
        base_image.save(f"{args.OUTPUT_DIR}{group_name}.png")

    print("Done.")

main(parse_args())
