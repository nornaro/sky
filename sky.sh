#!/bin/sh
printf '\033c\033]0;%s\a' Sky - Stuff Kept Yonder
base_path="$(dirname "$(realpath "$0")")"
"$base_path/sky.min" "$@"
