import argparse
import os

import pandas as pd
from PIL import Image
from tqdm import tqdm

from helper import make_directories, write_text

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", dest="DATA_FILE", default="data/collection.csv", help="Path to .csv data file")
    parser.add_argument("--thumb", dest="THUMB_SIZE", type=int, default=120, help="Largest side of the thumbnail images")
    parser.add_argument("--out", dest="OUTPUT_FILE", default="credits.md", help="Path to output Markdown file")
    parser.add_argument("--colors", dest="COLORS", type=int, default=64, help="Target color count")
    parser.add_argument("--src", dest="SOURCE_IMAGE_DIR", default="images/selections/", help="Path to source images")
    parser.add_argument("--tdir", dest="OUTPUT_THUMB_DIR", default="images/thumbs/", help="Path to output thumb images")
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
    make_directories(args.OUTPUT_THUMB_DIR)
    for i, row in tqdm(df.iterrows()):
        filename = f"{args.SOURCE_IMAGE_DIR}{row['Id']}.jpg"
        file_out = f"{args.OUTPUT_THUMB_DIR}{row['Id']}.jpg"
        if not args.OVERWRITE and os.path.isfile(file_out):
            continue
        
        # Make thumbnail and save
        im = Image.open(filename)
        im = im.convert("RGB")
        im.thumbnail((args.THUMB_SIZE, args.THUMB_SIZE), Image.Resampling.NEAREST)
        im.save(file_out)

    # Build markdown
    md = "# Art Breaker 3000 Credits\n\n"

    md += "## Software used\n\n"
    md += "This app was developed using [Godot](https://godotengine.org/), an open source game engine. [Python](https://www.python.org/) was used to pre-process collection data and images.\n\n"

    md += "## Audio used\n\n"
    md += "All music and sounds courtesy of public domain music by [Komiku](https://freemusicarchive.org/music/Komiku/) via the [Free Music Archive](https://freemusicarchive.org/) from albums [Captain Glouglou's Incredible Week Soundtrack](https://freemusicarchive.org/music/Komiku/Captain_Glouglous_Incredible_Week_Soundtrack) and [Helice Awesome Dance Adventure !!](https://freemusicarchive.org/music/Komiku/Helice_Awesome_Dance_Adventure_).\n\n"

    md += "## Artwork used\n\n"
    md += "Public domain artworks courtesy of [The Art Institute of Chicago](https://www.artic.edu/), [The Cleveland Art Museum](https://www.clevelandart.org/), [The Metropolitan Museum of Art](https://www.metmuseum.org/), [The National Gallery of Art](https://www.nga.gov/), and [The Smithsonian Institution](https://www.si.edu/).\n\n"

    md += "| Thumbnail | Title | Creator | Date | Source |\n"
    md += "| --------- | ----- | ------- | ---- | ------ |\n"
    records = df.to_dict("records")
    for r in records:
        md += f"| ![]({args.OUTPUT_THUMB_DIR}{r['Id']}.jpg)"
        md += f" | [{r['Title']}]({r['URL']})"
        md += f" | {r['Creator']}"
        md += f" | {r['Date']}"
        md += f" | {r['Source']} |\n"
    write_text(args.OUTPUT_FILE, md)
    print("Done.")

main(parse_args())
