import argparse
import time

import pandas as pd
from tqdm import tqdm

from helper import get_api_data, make_directories

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", dest="DATA_FILE", default="data/collection.csv", help="Path to .csv data file")
    parser.add_argument("--cache", dest="CACHE_DIR", default="tmp/", help="Cache API responses here")
    parser.add_argument("--debug", dest="DEBUG", action="store_true", help="Only print details; do not update file")
    return parser.parse_args()

def main(args):
    df = pd.read_csv(args.DATA_FILE, dtype=str)
    print(f"Read {df.shape[0]:,} rows from {args.DATA_FILE}")

    fields_to_check = ["Title", "Creator", "Date", "ImageURL"]
    make_directories(args.CACHE_DIR)
    for i, row in tqdm(df.iterrows()):
        needs_update = False
        for field in fields_to_check:
            if pd.isnull(row[field]):
                needs_update = True
                break
        
        if not needs_update:
            continue

        api_data = get_api_data(row["SourceId"], row["ItemId"], args.CACHE_DIR, args.DEBUG)
        time.sleep(1.0)

        if "error" in api_data:
            print(api_data["error"])
            continue
        
        if args.DEBUG:
            print(f"Updating {row['Id']}")

        for field in fields_to_check:
            if pd.isnull(row[field]) and field in api_data:
                df.at[i, field] = api_data[field]
                if args.DEBUG:
                    print(f"  {field} => {api_data[field]}")
    
    if not args.DEBUG:
        df.to_csv(args.DATA_FILE)
    # df.to_csv(args.DATA_FILE)
    print("Done.")

main(parse_args())
