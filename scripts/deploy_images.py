import argparse
import os

import pandas as pd
from PIL import Image
from tqdm import tqdm

from helper import make_directories, pluck, write_json

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", dest="DATA_FILE", default="data/collection.csv", help="Path to .csv data file")
    parser.add_argument("--width", dest="TARGET_W", type=int, default=1780, help="Max target width")
    parser.add_argument("--height", dest="TARGET_H", type=int, default=1024, help="Max target height")
    parser.add_argument("--colors", dest="COLORS", type=int, default=32, help="Target color count")
    parser.add_argument("--res", dest="RESOLUTION", type=float, default=1.0, help="Reduce resolution with value between 0.0 and 1.0")
    parser.add_argument("--src", dest="SOURCE_IMAGE_DIR", default="images/selections/", help="Path to source images")
    parser.add_argument("--out", dest="OUTPUT_DIR", default="godot/art/images/", help="Path to output images")
    parser.add_argument("--outdata", dest="OUTPUT_DATA_FILE", default="godot/data/collection.json", help="Path to output images")
    parser.add_argument("--overwrite", dest="OVERWRITE", action="store_true", help="Overwrite image files if already exists")
    return parser.parse_args()

def items_exists(args, ids):
    return [os.path.isfile(f"{args.SOURCE_IMAGE_DIR}{id}.jpg") for id in ids]

def main(args):
    df = pd.read_csv(args.DATA_FILE, dtype=str)
    df = df.fillna("Unknown")
    print(f"Read {df.shape[0]:,} rows from {args.DATA_FILE}")

    # Filter out items that don't exist
    df = df[items_exists(args, df['Id'])]
    print(f"{df.shape[0]} rows after filtering")

    # Iterate over items
    make_directories(args.OUTPUT_DIR)
    for i, row in tqdm(df.iterrows()):
        filename = f"{args.SOURCE_IMAGE_DIR}{row['Id']}.jpg"
        file_out = f"{args.OUTPUT_DIR}{row['Id']}.png"
        if not args.OVERWRITE and os.path.isfile(file_out):
            continue

        im = Image.open(filename)
        im_w, im_h = im.size
        im = im.convert("RGB")
        t_w, t_h = (args.TARGET_W, args.TARGET_H)

        # Calculate new image size to be contained in target container
        im_ratio = 1.0 * im_w / im_h
        t_ratio = 1.0 * t_w / t_h
        new_w = t_w
        new_h = t_h
        if im_ratio > t_ratio:
            new_h = int(round(t_w / im_ratio))
        else:
            new_w = int(round(t_h * im_ratio))

        # Reduce resolution if necessary
        if 0.0 < args.RESOLUTION < 1.0:
            res_w = max(1, int(round(new_w * args.RESOLUTION)))
            res_h = max(1, int(round(new_h * args.RESOLUTION)))
            im = im.resize((res_w, res_h), Image.Resampling.BICUBIC)

        # Resize image to be contained in target container
        resized = im.resize((new_w, new_h), Image.Resampling.NEAREST)

        # Reduce colors and save
        reduced = resized.convert("P", palette=Image.Palette.ADAPTIVE, colors=args.COLORS)
        reduced.save(file_out)

    # Export metadata
    records = df.to_dict("records")
    fields_out = ["Id", "Source", "URL", "Title", "Creator", "Date"]
    records = [pluck(r, fields_out) for r in records]
    make_directories(args.OUTPUT_DATA_FILE)
    write_json(args.OUTPUT_DATA_FILE, records, indent=4)

    print("Done.")

main(parse_args())
