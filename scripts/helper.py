import json
import os

import requests

def download(url, filename, verbose=True):
    try:
        r = requests.get(url, stream=True, timeout=60)
        with open(filename, "wb") as f:
            for chunk in r.iter_content(chunk_size=1024):
                if chunk:  # filter out keep-alive new chunks
                    f.write(chunk)
        if verbose:
            print(f"Downloaded {url}")
        return True
    except requests.exceptions.MissingSchema:
        print(f"Schema error when trying to get image {url}")
        return False
    except requests.HTTPError:
        print(f"HTTP error when trying to get {url}")
        return False
    except requests.Timeout:
        print(f"Timeout when trying to get {url}")
        return False

def get_api_data(source_id, item_id, cache_dir=None, verbose=False):
    """Retrieve normalized API data from a data source"""
    resp = {}
    if source_id == "clevelandart":
        resp = get_api_data_clevelandart(item_id, cache_dir, verbose)
    elif source_id == "metmuseum":
        resp = get_api_data_metmuseum(item_id, cache_dir, verbose)
    elif source_id == "si":
        resp = get_api_data_si(item_id, cache_dir, verbose)
    else:
        resp["error"] = f"No API service defined for {source_id}"
    return resp

def get_api_data_clevelandart(item_id, cache_dir=None, verbose=False):
    """Retrieve normalized API data from a Cleveland Art Museum API"""
    resp = {}
    api_url = f"https://openaccess-api.clevelandart.org/api/artworks/{item_id}"
    cache_file = f"{cache_dir}clevelandart_{item_id}.json" if cache_dir is not None else None
    api_resp = get_json(api_url, cache_file, verbose)
    if "data" not in api_resp or "id" not in api_resp["data"]:
        error = api_resp["error"] if "error" in api_resp else "Unknown error"
        resp["error"] = f"Could not find object from: {api_url} ({error})"
    else:
        if cache_file:
            write_json(cache_file, api_resp)
        data = api_resp["data"]
        resp["Title"] = get_nested_value(data, "title", "Untitled")
        resp["Creator"] = get_nested_value(data, ["creators", 0, "description"], "Unknown")
        resp["Date"] = get_nested_value(data, "creation_date", "Unknown")
        resp["ImageURL"] = get_nested_value(data, ["images", "print", "url"], "")
    return resp

def get_api_data_metmuseum(item_id, cache_dir=None, verbose=False):
    """Retrieve normalized API data from a Met Museum API"""
    resp = {}
    api_url = f"https://collectionapi.metmuseum.org/public/collection/v1/objects/{item_id}"
    cache_file = f"{cache_dir}metmuseum_{item_id}.json" if cache_dir is not None else None
    api_resp = get_json(api_url, cache_file, verbose)
    if "objectID" not in api_resp:
        error = api_resp["error"] if "error" in api_resp else "Unknown error"
        resp["error"] = f"Could not find object from: {api_url} ({error})"
    else:
        if cache_file:
            write_json(cache_file, api_resp)
        resp["Title"] = get_nested_value(api_resp, "title", "Untitled")
        resp["Creator"] = get_nested_value(api_resp, "artistDisplayName", "Unknown")
        resp["Date"] = get_nested_value(api_resp, "objectDate", "Unknown")
        resp["ImageURL"] = get_nested_value(api_resp, "primaryImage", "")
    return resp

def get_api_data_si(item_id, cache_dir=None, verbose=False):
    """Retrieve normalized API data from a Smithsonian Institute API"""
    resp = {}
    api_keys = read_json("api_keys.json")
    if "si" not in api_keys:
        resp["error"] = "You must set Smithsonian API key in api_keys.json with key 'si"
        return resp
    api_key = api_keys["si"]
    api_url = f"https://api.si.edu/openaccess/api/v1.0/content/edanmdm:{item_id}?api_key={api_key}"
    cache_file = f"{cache_dir}si_{item_id}.json" if cache_dir is not None else None
    api_resp = get_json(api_url, cache_file, verbose)
    if "status" not in api_resp or api_resp["status"] != 200:
        error = api_resp["error"] if "error" in api_resp else "Unknown error"
        resp["error"] = f"Could not find object from: {api_url} ({error})"
    else:
        if cache_file:
            write_json(cache_file, api_resp)
        data = api_resp["response"]
        resp["Title"] = get_nested_value(data, "title", "Untitled")
        resp["Creator"] = get_nested_value(data, ["content", "indexedStructured", "name", 0], "Unknown")
        resp["Date"] = get_nested_value(data, ["content", "freetext", "date", 0, "content"], "Unknown")
        resp["ImageURL"] = get_nested_value(data, ["content", "descriptiveNonRepeating", "online_media", "media", 0, "content"], "")
    return resp

def get_json(url, cache_file=None, verbose=False):
    """Parse JSON from a URL"""

    if cache_file and os.path.isfile(cache_file):
        if verbose:
            print(f"Data already requested for {url}. Loading from cache.")
        return read_json(cache_file)

    if verbose:
        print(f"Requesting data from {url}...")

    data = {}
    try:
        response = requests.get(url, timeout=30)
        data = response.json()
    except requests.HTTPError:
        data = {"error": "HTTPError"}
    except requests.Timeout:
        data = {"error": "Timeout"}
    except requests.JSONDecodeError:
        data = {"error": "JSONDecodeError"}

    return data

def get_nested_value(root, nodes, default_value=""):
    """Get a value from a nested dict"""
    value = default_value
    found = True
    if not isinstance(nodes, list):
        nodes = [nodes]

    for node in nodes:
        if isinstance(node, int):
            if isinstance(root, list) and len(root) > node:
                root = root[node]
            else:
                found = False
                break
        elif isinstance(root, dict) and node in root:
            root = root[node]
        else:
            found = False
            break

    if found:
        value = root
        if value == "":
            value = default_value

    return value

def read_json(filename):
    """Read a JSON file"""
    data = {}
    with open(filename) as f:
        data = json.load(f)
    return data


def write_json(filename, data):
    """Write data to JSON file"""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f)