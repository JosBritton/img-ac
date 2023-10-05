import os
import sys
import math
import json
from typing import TypedDict

VAR: str = "OUTPUT"
BINARY_PREFIXES: list[str] = ["B", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi", "Yi"]


class JsonData(TypedDict):
    actual_size: int
    virtual_size: int


def check_environment_variable_exists(env_var_name: str) -> bool:
    if env_var_name not in os.environ:
        return False
    return True


def check_file_exists(file_path: str) -> bool:
    if os.path.isfile(file_path):
        return True
    return False


def check_file_is_non_empty(file_path: str) -> bool:
    if os.path.getsize(file_path) == 0:
        return False
    return True


def bytes_to_human_readable(bytes: int) -> str:
    if bytes <= 0:
        return "0 B"

    i = int(math.floor(math.log(bytes, 1024)))
    size: int = bytes / (1024**i)

    return f"{size:.2f} {BINARY_PREFIXES[i]}"


def load_json_data(path: str) -> JsonData:
    try:
        with open(path, "r") as json_file:
            return json.load(json_file)
    except json.JSONDecodeError as err:
        print(f"Failed to parse JSON file: {err}", file=sys.stderr)
        sys.exit(1)
    except OSError as err:
        print(f"Failed to open JSON file: {err}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    if not check_environment_variable_exists(VAR):
        print(f"Environment variable {VAR} does not exist.", file=sys.stderr)
        sys.exit(1)

    env: str = os.environ[VAR]
    if not check_file_exists(env):
        print(f"OUTPUT value: '{env}' is not a valid file path.", file=sys.stderr)
        sys.exit(1)

    if not check_file_is_non_empty(env):
        print(f"OUTPUT value: '{env}' is an empty file.", file=sys.stderr)
        sys.exit(1)

    data: JsonData = load_json_data(env)

    actual_size: str
    virtual_size: str
    actual_size, virtual_size = (
        bytes_to_human_readable(data.get(key, 0))
        for key in ["actual-size", "virtual-size"]
    )

    print(f"Actual Size: {actual_size}\nVirtual Size: {virtual_size}")
