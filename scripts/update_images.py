import json
import requests
import base64

def get_remote(url: str) -> tuple[dict, bool]:
    try:
        resp = requests.get(url)
        resp.raise_for_status()  # HTTPError

        data = resp.json()

        if not data:
            return {}, False

        return data, True
    except requests.exceptions.RequestException as err:
        print(f'Error fetching the JSON file: {err}')
        return {}, False

def get_local(path: str) -> tuple[dict, bool]:
    with open(path) as f:
        return json.load(f), True

def parse_debian_cloud_meta(meta: dict) -> dict:
    d = {}
    for item in meta["items"]:
        if item["kind"] == "Upload":
            if item["metadata"]["labels"]["upload.cloud.debian.org/image-format"] == "qcow2":
                enc_digest = item["metadata"]["annotations"]["cloud.debian.org/digest"]
                url = f"https://cloud.debian.org/images/cloud/{ item["data"]["ref"] }"

                # split at prefix `sha512:...`
                enc_digest_data = enc_digest.split(":", 1)[1]
                # add correct b64 padding
                while len(enc_digest_data) % 4 != 0:
                    enc_digest_data += "="

                # checksum
                digest = f"sha512:{ base64.b64decode(enc_digest_data).hex() }"

                d["url"] = url
                d["digest"] = digest
    return d

def main():
    meta = {}
    for provider in {"genericcloud", "generic", "nocloud"}:
        for arch in {"amd64", "arm64"}:
            uri = f"https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-{provider}-{arch}.json"
            data, ok = get_remote(uri)
            if not ok:
                raise Exception("No data for: ", uri)
            meta[f"debian-12-{provider}-{arch}"] = parse_debian_cloud_meta(data)

    s = f"""\
image_repository = {{
  debian-12-genericcloud-amd64 = {{
    url    = "{ meta["debian-12-genericcloud-amd64"]["url"] }"
    digest = "{ meta["debian-12-genericcloud-amd64"]["digest"] }"
  }},
  debian-12-genericcloud-arm64 = {{
    url    = "{ meta["debian-12-genericcloud-arm64"]["url"] }"
    digest = "{ meta["debian-12-genericcloud-arm64"]["digest"] }"
  }}
  debian-12-generic-amd64 = {{
    url    = "{ meta["debian-12-generic-amd64"]["url"] }"
    digest = "{ meta["debian-12-generic-amd64"]["digest"] }"
  }}
  debian-12-generic-arm64 = {{
    url    = "{ meta["debian-12-generic-arm64"]["url"] }"
    digest = "{ meta["debian-12-generic-arm64"]["digest"] }"
  }}
  debian-12-nocloud-amd64 = {{
    url    = "{ meta["debian-12-nocloud-amd64"]["url"] }"
    digest = "{ meta["debian-12-nocloud-amd64"]["digest"] }"
  }}
  debian-12-nocloud-arm64 = {{
    url    = "{ meta["debian-12-nocloud-arm64"]["url"] }"
    digest = "{ meta["debian-12-nocloud-arm64"]["digest"] }"
  }}
}}
"""
    print("Got info:\n", meta, "\nWriting to file...")
    with open("images.auto.pkrvars.hcl", "w", encoding="utf-8") as f:
        f.write(s)


if __name__ == "__main__":
    main()
