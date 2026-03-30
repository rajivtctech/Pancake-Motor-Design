#!/usr/bin/env bash
# ================================================================
#  export_stls.sh — Render all pancake motor parts to STL files
#  Usage:  bash export_stls.sh [output_dir]
#  Requires: openscad ≥ 2021.01 on PATH
#            Ubuntu: sudo apt install openscad
#            macOS:  brew install openscad  (or download .dmg)
# ================================================================

set -euo pipefail

SCAD="pancake_motor_assembly.scad"
OUTDIR="${1:-stl_output}"
OPENSCAD="${OPENSCAD_BIN:-openscad}"   # override with OPENSCAD_BIN=/path/to/openscad

# Parts to export: "key" → "PART value used in -D"
# rotor_disc is exported once — both rotors are identical parts.
declare -A PARTS=(
    [shaft]="shaft"
    [rotor_disc]="rotor_disc"
    [housing_front]="housing_front"
    [housing_rear]="housing_rear"
    [front_end_cap]="front_end_cap"
    [rear_end_cap]="rear_end_cap"
)

# ── Pre-flight checks ────────────────────────────────────────────
if [[ ! -f "$SCAD" ]]; then
    echo "ERROR: $SCAD not found in current directory ($(pwd))"
    exit 1
fi

if ! command -v "$OPENSCAD" &>/dev/null; then
    echo "ERROR: openscad not found on PATH."
    echo "  Ubuntu/Debian: sudo apt install openscad"
    echo "  or set OPENSCAD_BIN=/path/to/openscad"
    exit 1
fi

OPENSCAD_VER=$("$OPENSCAD" --version 2>&1 | head -1)
echo "Using: $OPENSCAD_VER"
echo "Source: $SCAD"
echo "Output: $OUTDIR/"
echo ""

mkdir -p "$OUTDIR"

# ── Render loop ──────────────────────────────────────────────────
PASS=0
FAIL=0
FAILED_PARTS=()

for name in "${!PARTS[@]}"; do
    part_val="${PARTS[$name]}"
    outfile="$OUTDIR/${name}.stl"

    printf "  Rendering %-20s → %s ... " "$name" "$outfile"

    if "$OPENSCAD" \
        --quiet \
        -o "$outfile" \
        -D "PART=\"${part_val}\"" \
        -D "EXPLODE=0" \
        "$SCAD" 2>/dev/null; then
        SIZE=$(wc -c < "$outfile")
        echo "OK  ($(( SIZE / 1024 )) KB)"
        (( PASS++ )) || true
    else
        echo "FAILED"
        (( FAIL++ )) || true
        FAILED_PARTS+=("$name")
    fi
done

# ── Summary ──────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
echo "  Rendered : $PASS / $(( PASS + FAIL )) parts"
if [[ ${#FAILED_PARTS[@]} -gt 0 ]]; then
    echo "  Failed   : ${FAILED_PARTS[*]}"
    echo "  Run openscad manually to see errors:"
    for p in "${FAILED_PARTS[@]}"; do
        echo "    openscad -o /tmp/test.stl -D 'PART=\"${PARTS[$p]}\"' $SCAD"
    done
    exit 1
fi
echo "  Output   : $OUTDIR/"
ls -lh "$OUTDIR/"*.stl 2>/dev/null | awk '{print "    " $5 "  " $9}'
echo "═══════════════════════════════════════"
echo ""
echo "Note: rotor_disc.stl is used for BOTH rotor assemblies."
echo "      Print or machine two copies."
echo "      housing_front + housing_rear sandwich the PCB — both required."
