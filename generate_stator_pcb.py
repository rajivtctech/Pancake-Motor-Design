#!/usr/bin/env python3
"""
generate_stator_pcb.py
======================
Generates a KiCad 6/7 .kicad_pcb for a 2-layer axial-flux pancake motor stator.

Topology
--------
  12 coils, 3-phase star, 8-pole rotor.
  Phase A: coils 0, 3, 6, 9  (series-connected)
  Phase B: coils 1, 4, 7, 10
  Phase C: coils 2, 5, 8, 11
  Neutral: all innermost B.Cu coil ends connected by a ring on F.Cu.

Coil winding (per coil, 2-layer series spiral)
-----------------------------------------------
  F.Cu: N_TURNS turns spiralling inward from R_OUT.
    Turn k:  arc(radius R_OUT - k*PITCH, from ±COIL_HALF to ∓COIL_HALF)
    Radial segment connects turn k end to turn k+1 start.
  Via: innermost F.Cu end → B.Cu (same physical point).
  B.Cu: N_TURNS turns continuing inward.
    Same alternating arc pattern, continuing from via side.
  Neutral via: innermost B.Cu end → Neutral net on F.Cu.

Electrical connectivity
-----------------------
  Outer F.Cu lead of each coil → phase stub at R_STUB, then phase bus arc at R_BUS.
  All neutral vias tied by neutral ring arc at R_INNER on F.Cu.
  4 through-hole pads at board edge: Ph_A (0°), Ph_B (120°), Ph_C (240°), Neut (60°).

Usage
-----
  python3 generate_stator_pcb.py stator.kicad_pcb
  python3 generate_stator_pcb.py my_motor.kicad_pcb
  Then open the file in KiCad 6 or 7.
"""
import argparse, math, uuid, sys

# ── Primary parameters ────────────────────────────────────────────────────────
CX, CY      = 100.0, 100.0   # Board origin in KiCad mm space
PCB_OD      = 72.0           # Board outer diameter [mm]
PCB_ID      = 16.0           # Central clearance hole diameter [mm]
N_COILS     = 12             # Total coils
N_TURNS     = 6              # Turns per layer per coil (12 turns total per coil)
TW          = 0.5            # Trace width [mm]
TC          = 0.3            # Clearance [mm]
PITCH       = TW + TC        # 0.8 mm centre-to-centre
R_OUT       = 31.0           # Outermost coil turn radius [mm]
COIL_HALF   = 12.5           # ±half-angle of each coil [degrees] (25° active, 5° gap)
MOUNT_R     = 34.0           # M3 mounting hole PCD radius [mm]
VIA_DRILL   = 0.4            # Via drill diameter [mm]
VIA_SIZE    = 0.8            # Via annular pad diameter [mm]
R_STUB      = R_OUT + 1.5   # Radius of outer lead stub [mm]
R_BUS       = R_OUT + 3.0   # Radius of phase bus ring [mm]  (< MOUNT_R-1.6-TC ≈ 32.1 OK)
BOARD_T     = 1.6            # PCB thickness [mm]

# Net IDs
NET_A, NET_B, NET_C, NET_N = 1, 2, 3, 4

# Net name lookup — KiCad 6/7 requires (net N "name") in every copper element
NET_NAMES = {
    0: "",
    NET_A: "Phase_A",
    NET_B: "Phase_B",
    NET_C: "Phase_C",
    NET_N: "Neutral",
}
def nref(net):
    """Return KiCad net reference string: N "name" """
    return f'{net} "{NET_NAMES[net]}"'

# ── Derived geometry ──────────────────────────────────────────────────────────
R_FCU_LAST  = R_OUT - (N_TURNS - 1) * PITCH       # Last F.Cu turn: 27.0 mm
R_BCU_FIRST = R_OUT - N_TURNS * PITCH              # First B.Cu turn: 26.2 mm
R_INNER     = R_OUT - (2 * N_TURNS - 1) * PITCH   # Innermost B.Cu turn: 22.2 mm

# ── Helpers ───────────────────────────────────────────────────────────────────
def uid():   return str(uuid.uuid4())
def f(v):    return f"{v:.4f}"
def pnet(ci): return ci % 3 + 1   # coil index → phase net (1=A, 2=B, 3=C)

def kp(r, a_deg):
    """Polar → KiCad XY.  KiCad Y-axis is downward, so sin is negated."""
    t = math.radians(a_deg)
    return CX + r * math.cos(t), CY - r * math.sin(t)

def arc_elem(r, a1, a2, layer, net, w=TW):
    """Copper arc: net is number-only in tracks/arcs (KiCad 7+ format)."""
    am = (a1 + a2) / 2.0
    s, m, e = kp(r, a1), kp(r, am), kp(r, a2)
    return (f'  (arc (start {f(s[0])} {f(s[1])}) '
            f'(mid {f(m[0])} {f(m[1])}) '
            f'(end {f(e[0])} {f(e[1])}) '
            f'(width {w}) (layer "{layer}") (net {net}) (uuid "{uid()}"))')

def seg_elem(p1, p2, layer, net, w=TW):
    """Copper segment: net is number-only."""
    return (f'  (segment (start {f(p1[0])} {f(p1[1])}) (end {f(p2[0])} {f(p2[1])}) '
            f'(width {w}) (layer "{layer}") (net {net}) (uuid "{uid()}"))')

def via_elem(p, net):
    """Via: net is number-only."""
    return (f'  (via (at {f(p[0])} {f(p[1])}) (size {VIA_SIZE}) (drill {VIA_DRILL}) '
            f'(layers "F.Cu" "B.Cu") (net {net}) (uuid "{uid()}"))')

def gr_circle(r, layer, w=0.1):
    return (f'  (gr_circle (center {f(CX)} {f(CY)}) (end {f(CX + r)} {f(CY)}) '
            f'(stroke (width {w}) (type solid)) (layer "{layer}") (uuid "{uid()}"))')

def gr_text(text, x, y, layer, sz=1.2, ang=0):
    return (f'  (gr_text "{text}" (at {f(x)} {f(y)} {ang}) '
            f'(layer "{layer}") (uuid "{uid()}")\n'
            f'    (effects (font (size {sz} {sz}) (thickness 0.15))))')

def npth_hole(x, y, d=3.2):
    return (f'  (footprint "MountingHole:MountingHole_3.2mm_M3_Pad" '
            f'(layer "F.Cu") (at {f(x)} {f(y)}) (uuid "{uid()}")\n'
            f'    (pad "" np_thru_hole circle (at 0 0) (size {d+0.3:.1f} {d+0.3:.1f}) '
            f'(drill {d:.1f}) (layers "*.Cu" "*.Mask") (uuid "{uid()}"))\n'
            f'  )')

def tht_pad(x, y, net, label, ang=0, drill=1.0, size=1.8):
    return (f'  (footprint "Connector:TestPoint_Pad_1.0x1.0mm" '
            f'(layer "F.Cu") (at {f(x)} {f(y)} {ang}) (uuid "{uid()}")\n'
            f'    (fp_text value "{label}" (at 0 -2.8) (layer "F.SilkS") (uuid "{uid()}")\n'
            f'      (effects (font (size 1.2 1.2) (thickness 0.15))))\n'
            f'    (pad "1" thru_hole circle (at 0 0) (size {size} {size}) '
            f'(drill {drill}) (layers "*.Cu" "*.Mask") (net {nref(net)}) (uuid "{uid()}"))\n'
            f'  )')

# ── Build output list ─────────────────────────────────────────────────────────
O = []

# Header
O.append(f'''(kicad_pcb (version 20250324) (generator "stator_gen") (generator_version "1.0")
  (general (thickness {BOARD_T}))
  (paper "A4")
  (layers
    (0 "F.Cu" signal)
    (31 "B.Cu" signal)
    (36 "F.Mask" user)
    (37 "B.Mask" user)
    (38 "F.SilkS" user)
    (39 "B.SilkS" user)
    (40 "F.Fab" user)
    (44 "Edge.Cuts" user)
  )
  (setup
    (pad_to_mask_clearance 0.1)
    (solder_mask_min_width 0)
    (allow_soldermask_bridges_in_footprints no)
  )
  (net 0 "")
  (net 1 "Phase_A")
  (net 2 "Phase_B")
  (net 3 "Phase_C")
  (net 4 "Neutral")''')

# ── Board outline (Edge.Cuts) ─────────────────────────────────────────────────
O.append(gr_circle(PCB_OD / 2,  "Edge.Cuts", w=0.1))
O.append(gr_circle(PCB_ID / 2,  "Edge.Cuts", w=0.1))

# Courtyard
O.append(gr_circle(PCB_OD / 2 + 0.5, "F.CrtYd", w=0.05))
O.append(gr_circle(PCB_ID / 2 - 0.5, "F.CrtYd", w=0.05))

# Fab reference circles (coil active zone boundaries)
O.append(gr_circle(R_OUT,   "F.Fab", w=0.05))
O.append(gr_circle(R_INNER, "F.Fab", w=0.05))
O.append(gr_circle(R_BUS,   "F.Fab", w=0.05))

# Silkscreen
O.append(gr_text("PANCAKE MOTOR STATOR v1.0",        CX-26, CY + PCB_OD/2 + 5,  "F.SilkS", sz=1.5))
O.append(gr_text("12-coil | 3-ph star | 2L | 8-pole",  CX-24, CY + PCB_OD/2 + 8,  "F.SilkS", sz=1.0))
O.append(gr_text("0.5mm trace / 0.3mm clr | 2oz Cu rec.", CX-26, CY + PCB_OD/2 + 11, "F.SilkS", sz=1.0))
O.append(gr_text("Ph_A=0deg Ph_B=120deg Ph_C=240deg N=60deg", CX-32, CY + PCB_OD/2 + 14, "F.SilkS", sz=0.8))

# Coil phase labels at outer edge
for ci in range(N_COILS):
    ph  = "ABC"[ci % 3]
    ang = ci * 30 + 15.0
    lx, ly = kp(R_OUT + 4.5, ang)
    O.append(gr_text(ph, lx, ly, "F.SilkS", sz=1.5, ang=-ang))

# ── Mounting holes (M3 NPTH) ──────────────────────────────────────────────────
for i in range(4):
    hx, hy = kp(MOUNT_R, i * 90 + 45)
    O.append(npth_hole(hx, hy, d=3.2))

# ── Phase / neutral connection pads ──────────────────────────────────────────
# Large THT pads at PCB edge, one per phase + neutral.
for label, net, ang in [("Ph_A", NET_A, 0),
                         ("Ph_B", NET_B, 120),
                         ("Ph_C", NET_C, 240),
                         ("N",    NET_N,  60)]:
    px, py = kp(PCB_OD / 2 - 4.5, ang)
    O.append(tht_pad(px, py, net, label, ang=ang, drill=1.2, size=2.2))

# ── Coil geometry ─────────────────────────────────────────────────────────────
# For each coil ci:
#   F.Cu: turns k=0..N_TURNS-1, radii R_OUT..R_FCU_LAST.
#     Even k: arc a_pos→a_neg, radial at a_neg side.
#     Odd k:  arc a_neg→a_pos, radial at a_pos side.
#   k=N_TURNS-1 is odd (=5) → ends at a_pos → via on a_pos side.
#   B.Cu: turns k_r=0..N_TURNS-1, radii R_BCU_FIRST..R_INNER.
#     Same even/odd alternation, starting from a_pos (via side).
#   Neutral via at innermost B.Cu end (a_pos side, k_r=5 odd).
#
# Outer F.Cu lead stub → phase bus arcs at R_BUS per phase.

# Collect phase bus connection angles (outer F.Cu start for each coil)
# k=0 is even → arc starts at a_pos. Outer lead at kp(R_OUT, a_pos).
outer_lead_angles = []   # index ci → angle of outer F.Cu lead

for ci in range(N_COILS):
    net   = pnet(ci)
    tc    = ci * 30.0
    a_pos = tc + COIL_HALF   # e.g.  12.5° for ci=0
    a_neg = tc - COIL_HALF   # e.g. -12.5° for ci=0

    outer_lead_angles.append(a_pos)   # k=0 even: arc starts at a_pos

    # ── F.Cu spiral ──────────────────────────────────────────────
    for k in range(N_TURNS):
        r = R_OUT - k * PITCH
        if k % 2 == 0:
            a1, a2, es = a_pos, a_neg, a_neg
        else:
            a1, a2, es = a_neg, a_pos, a_pos
        O.append(arc_elem(r, a1, a2, "F.Cu", net))
        if k < N_TURNS - 1:
            O.append(seg_elem(kp(r, es), kp(r - PITCH, es), "F.Cu", net))

    # ── Via: F.Cu innermost → B.Cu ───────────────────────────────
    # k_last = N_TURNS-1 = 5 (odd) → ends at a_pos
    via_side = a_pos
    vp = kp(R_FCU_LAST, via_side)
    O.append(via_elem(vp, net))

    # Radial stub on B.Cu from via down to first B.Cu turn
    O.append(seg_elem(kp(R_FCU_LAST, via_side),
                      kp(R_BCU_FIRST, via_side), "B.Cu", net))

    # ── B.Cu spiral ──────────────────────────────────────────────
    # k_r=0 (even) starts at via_side=a_pos: arc a_pos→a_neg
    for k_r in range(N_TURNS):
        k = N_TURNS + k_r
        r = R_OUT - k * PITCH
        if k_r % 2 == 0:
            a1, a2, es = a_pos, a_neg, a_neg
        else:
            a1, a2, es = a_neg, a_pos, a_pos
        O.append(arc_elem(r, a1, a2, "B.Cu", net))
        if k_r < N_TURNS - 1:
            O.append(seg_elem(kp(r, es), kp(r - PITCH, es), "B.Cu", net))
        else:
            # k_r=5 (odd) → es = a_pos; neutral via here
            nv_pt = kp(r, es)    # (R_INNER, a_pos)
            O.append(via_elem(nv_pt, NET_N))

    # ── Outer F.Cu lead → phase bus stub ─────────────────────────
    # Short radial segment from outer arc start outward to R_STUB,
    # then to R_BUS.  The arc starts at kp(R_OUT, a_pos).
    O.append(seg_elem(kp(R_OUT, a_pos), kp(R_STUB, a_pos), "F.Cu", net))
    O.append(seg_elem(kp(R_STUB, a_pos), kp(R_BUS, a_pos), "F.Cu", net))

# ── Phase bus arcs at R_BUS ───────────────────────────────────────────────────
# For each phase, 4 coils at angular positions [ci*30+12.5 for ci in phase_coils].
# Connect them in series order around the ring.
phase_coil_map = {
    NET_A: [0, 3, 6, 9],
    NET_B: [1, 4, 7, 10],
    NET_C: [2, 5, 8, 11],
}
for net, coils in phase_coil_map.items():
    angs = sorted([outer_lead_angles[ci] for ci in coils])
    # Connect adjacent bus points with arcs
    for i in range(len(angs)):
        a1 = angs[i]
        a2 = angs[(i + 1) % len(angs)]
        if a2 < a1:
            a2 += 360.0    # wrap: e.g. 282.5→12.5 becomes 282.5→372.5
        O.append(arc_elem(R_BUS, a1, a2, "F.Cu", net, w=0.5))

# ── Neutral ring on F.Cu at R_INNER ──────────────────────────────────────────
# All 12 neutral vias are at (R_INNER, ci*30+12.5°).
# Connect consecutive vias with arcs at R_INNER.
n_angs = [ci * 30 + COIL_HALF for ci in range(N_COILS)]
for i in range(N_COILS):
    a1 = n_angs[i]
    a2 = n_angs[(i + 1) % N_COILS]
    if a2 < a1:
        a2 += 360.0
    O.append(arc_elem(R_INNER, a1, a2, "F.Cu", NET_N, w=0.5))

# ── Close ─────────────────────────────────────────────────────────────────────
O.append(")")

# ── Write ─────────────────────────────────────────────────────────────────────
parser = argparse.ArgumentParser(
    description="Generate a KiCad 2-layer axial-flux pancake motor stator PCB.")
parser.add_argument(
    "output",
    metavar="OUTPUT.kicad_pcb",
    nargs="?",                          # now optional on the command line
    help="Path of the .kicad_pcb file to write (e.g. stator.kicad_pcb)")
args = parser.parse_args()

if not args.output:
    args.output = input("Output filename (e.g. stator.kicad_pcb): ").strip()
    if not args.output:
        print("Error: no filename given.", file=sys.stderr)
        sys.exit(1)

content = '\n'.join(O)

with open(args.output, 'w', encoding='utf-8') as fh:
    fh.write(content)
    fh.write('\n')

print(f"Written {len(O)} elements → {args.output}")
