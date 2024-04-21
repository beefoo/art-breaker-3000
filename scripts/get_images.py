import argparse
import os

import pandas as pd
from tqdm import tqdm

from helper import download, make_directories

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", dest="DATA_FILE", default="data/collection.csv", help="Path to .csv data file")
    parser.add_argument("--out", dest="OUTPUT_DIR", default="downloads/", help="Path to download images")
    return parser.parse_args()

def main(args):
    df = pd.read_csv(args.DATA_FILE, dtype=str)
    print(f"Read {df.shape[0]:,} rows from {args.DATA_FILE}")

    duplicates = df[df.duplicated(subset=['ImageURL'])]
    if duplicates.shape[0] > 0:
        print('-----------------------')
        print(f"Warning: there are duplicate image URLs:")
        print(duplicates)
        print('-----------------------')

    make_directories(args.OUTPUT_DIR)
    for i, row in tqdm(df.iterrows()):
        image_url = row["ImageURL"]
        filename = f"{args.OUTPUT_DIR}{row['Id']}.jpg"
        if os.path.isfile(filename):
            continue
        
        download(image_url, filename)

    print("Done.")

main(parse_args())
