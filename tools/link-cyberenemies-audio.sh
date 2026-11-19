#!/usr/bin/env bash
# Copy Cyber Enemies' sound files next to our AudioXL manifest, inside your MO2 instance.
# Cyber Enemies ships them for Audioware (r6/audioware/CyberEnemies/); AudioXL plays the same
# names through the vanilla AudioSystem.Play call Cyber Enemies already uses, so no Audioware.
# The files are Cyber Enemies' assets, so they're copied locally, never committed here.
#   tools/link-cyberenemies-audio.sh <mo2-instance> [compat-mod-name] [cyber-enemies-mod-name]
set -euo pipefail
instance="${1:?usage: $0 <mo2-instance> [compat-mod-name] [cyber-enemies-mod-name]}"
default_compat="Link's Cyberpunk Compatibility Mod"
compat="${2:-$default_compat}"
ce="${3:-Cyber Enemies}"
src="$instance/mods/$ce/r6/audioware/CyberEnemies"
dst="$instance/mods/$compat/red4ext/plugins/AudioXL/sounds/CyberEnemies"
[[ -d "$src" ]] || { echo "Cyber Enemies' audio not found at $src (install Cyber Enemies first)" >&2; exit 1; }
mkdir -p "$dst"
for f in Cassiopeia_Original_R_1.ogg Cassiopeia_Original_R_5.ogg banshee.mp3 sonido.mp3; do
    cp -f "$src/$f" "$dst/$f"
done
echo "copied Cyber Enemies' sounds -> $dst"
