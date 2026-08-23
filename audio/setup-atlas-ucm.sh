#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
overlay="$project_dir/audio/atlas-ucm2"
system_ucm=/usr/share/alsa/ucm2

mkdir -p "$overlay/conf.d/avs_max98373"

# Reuse the distribution's UCM tree through links; only Atlas files are
# maintained by this project.
for entry in "$system_ucm"/*; do
  name=${entry##*/}
  [[ "$name" == conf.d ]] && continue
  [[ -e "$overlay/$name" ]] || ln -s "$entry" "$overlay/$name"
done

for entry in "$system_ucm/conf.d"/*; do
  name=${entry##*/}
  [[ "$name" == avs_max98373 ]] && continue
  [[ -e "$overlay/conf.d/$name" ]] || ln -s "$entry" "$overlay/conf.d/$name"
done

cp "$project_dir/audio/config/Atlas.conf" "$overlay/Atlas.conf"
cp "$project_dir/audio/config/Atlas-HiFi.conf" "$overlay/Atlas-HiFi.conf"
cp "$project_dir/audio/config/Atlas.conf" \
  "$overlay/conf.d/avs_max98373/AVS I2S MAX98373.conf"

printf 'Atlas UCM overlay ready at %s\n' "$overlay"

