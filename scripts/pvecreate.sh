#!/usr/bin/env sh

set -e

err() {
    >&2 echo "ERROR: $1."
    exit 1
}

assert_has_value() {
    if [ -z "${1:+1}" ]; then
        err "The variable $2 has no value"
    fi
}

assert_is_bool() {
    if [ "$1" != "0" ] && [ "$1" != "1" ]; then
        err "Unknown $2 value: $1 is not a boolean (allowed: 1, 0)"
    fi
}

assert_is_file() {
    if [ ! -f "$1" ]; then
        err "Unknown $2 value: $1 is not a file"
    fi
}

#CONSTANTS
_vmid_max_int=999999999
_vmid_min_int=100
readonly _vmid_min_int _vmid_max_int

[ -z "${VMID:+1}" ] && VMID=$(/usr/bin/env pvesh get /cluster/nextid)

if [ -z "${VMID:+1}" ] || \
    [ "$VMID" -lt $_vmid_min_int ] || [ "$VMID" -gt $_vmid_max_int ]; then
    err "Could not get next VM ID."
fi

_defint=$(/usr/bin/env ip route \
    | grep -E -o 'default via [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ dev [^ ]+' \
    | sed 's/.* dev \([^ ]\+\)/\1/')
readonly _defint
if [ -z "${_defint:+1}" ] || [ ! -e "/sys/class/net/$_defint" ]; then
    err "Could not get default interface."
fi

assert_has_value "$VMNAME" "VMNAME"
assert_has_value "$VMMEM" "VMMEM"
assert_has_value "$VMCORES" "VMCORES"
assert_has_value "$VMNET" "VMNET"
assert_has_value "$VMSCSIHW" "VMSCSIHW"
assert_has_value "$VMSTORE" "VMSTORE"
assert_has_value "$VMOSTYPE" "VMOSTYPE"
assert_has_value "$VMBALLOON" "VMBALLOON"
assert_has_value "$VMQEMUAGENT" "VMQEMUAGENT"
assert_has_value "$VMCACHE" "VMCACHE"
assert_has_value "$VMIMGPATH" "VMIMGPATH"
assert_has_value "$VMDISKFORMAT" "VMDISKFORMAT"
assert_has_value "$VMDISCARD" "VMDISCARD"

assert_is_file "$VMIMGPATH" "VMIMGPATH"

qm create "$VMID" \
    --name "$VMNAME" \
    --memory "$VMMEM" \
    --core "$VMCORES" \
    --net0 "$VMNET" \
    --scsihw "$VMSCSIHW" \
    --scsi0 "$VMSTORE:0,\
import-from=$VMIMGPATH,\
cache=$VMCACHE,\
discard=$VMDISCARD,\
format=$VMDISKFORMAT" \
    --boot order=scsi0 \
    --ostype "$VMOSTYPE" \
    --serial0 socket \
    --ide2 "$VMSTORE:cloudinit" \
    --vga serial0 \
    --template 1 \
    --agent "$VMQEMUAGENT" \
    --onboot 0 \
    --balloon "$VMBALLOON" \
    --ipconfig0 ip=dhcp,ip6=dhcp \

rm -f "$VMIMGPATH"
echo Removed "$VMIMGPATH."
