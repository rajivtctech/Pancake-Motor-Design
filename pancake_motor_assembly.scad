// ================================================================
//  Pancake Motor — TORUS Double-Rotor Assembly
//  60 mm rotor · 10 mm shaft · 7200B AC bearings · 8-pole 3-phase
//  NEMA 34 front face · Dual shaft output
// ================================================================
//
//  NEMA 34 compliance (ICS 16-2001 / NEMA MG 7)
//  ─────────────────────────────────────────────
//  Frame square   : 86.36 × 86.36 mm
//  Bolt pattern   : 69.60 × 69.60 mm square (holes at ±34.80 mm X/Y)
//  Bolt size      : M5 clearance Ø5.5 mm through front cap
//  Pilot boss OD  : 73.025 mm (tolerance h6: Ø73.025 –0.000/–0.019)
//  Pilot boss ht  : 1.60 mm protrusion from front face
//
//  Body & shaft
//  ────────────
//  Housing ring OD: 82 mm round (fits within NEMA 34 86.36 mm envelope)
//  Front shaft Ø  : 10 mm metric — NEMA / coupling end
//  Rear shaft stub : Ø8 × 10 mm — fits 58mm hollow-shaft encoder bore
//  Dual shaft     : front protrudes ~22 mm beyond NEMA boss; rear stub 10 mm
//
//  Parts summary
//  ─────────────
//  Shaft         : EN1A or Al 6082, Ø10 h6
//  Rotor discs   : Low-carbon steel 1010/1018, turned + pocket-milled
//  Housing front  : Al 6061 or FDM PETG — +Z half, mates at PCB plane
//  Housing rear   : Al 6061 or FDM PETG — –Z half, mates at PCB plane
//                   PCB sandwiched and clamped between the two halves
//  Front end cap : NEMA 34 square face — Al 6061, milled from plate
//  Rear end cap  : Round — Al 6061 or FDM
//  PCB stator    : 72 mm OD, from generate_stator_pcb.py
//  Assy fasteners: 4× M4×35 cap-head (housing ring to end caps)
//  Mounting bolts: 4× M5 customer-supplied (NEMA face to machine)
// ================================================================

$fn = 120;

EXPLODE = 1;      // 0 = assembled, 1 = exploded view
EXP     = EXPLODE * 16;

// ================================================================
//  PART SELECTOR
//  ─────────────
//  Default "assembly" shows the exploded/assembled view in the
//  OpenSCAD GUI.  Set to any part name below (or override with
//  -D on the CLI) to render that part alone for STL export.
//
//  Valid values
//    "assembly"        — full assembly (exploded or assembled per EXPLODE)
//    "shaft"           — stepped output shaft
//    "rotor_disc"      — rotor disc (both rotors are identical)
//    "housing_front"   — +Z housing half (front/rotor side of PCB)
//    "housing_rear"    — –Z housing half (rear/encoder side, has wire slots)
//    "front_end_cap"   — NEMA 34 square output face
//    "rear_end_cap"    — round encoder / secondary shaft end
//
//  Use export_stls.sh (Linux/macOS) or export_stls.bat (Windows)
//  to render all parts to individual STL files automatically.
// ================================================================
PART = "assembly";

// ================================================================
//  PRIMARY PARAMETERS
// ================================================================

// Shaft — stepped, asymmetric
SD            = 10.0;  // Main shaft diameter [mm] (front / bearing sections)
REAR_STUB_D   =  8.0;  // Rear encoder stub diameter [mm] — 58mm hollow-shaft encoder
REAR_STUB_L   = 10.0;  // Rear encoder stub length [mm]
SHAFT_FRONT_TIP = 45.0;// Front tip z from PCB mid [mm] → ~22 mm proud of NEMA boss

// Bearing 7200B: bore 10 mm, OD 30 mm, width 9 mm
BD  = 30.0;
BB  = 10.0;
BW  =  9.0;

// Rotor
RD  = 60.0;   // Disc OD [mm]
RT  =  5.0;   // Disc thickness — 2 mm back-iron + 3 mm magnet pocket
MT  =  3.0;   // Magnet thickness [mm]
ML  = 15.0;   // Magnet radial length [mm]
MW  = 11.0;   // Magnet circumferential width [mm]
MR  = 20.5;   // Magnet centre radius [mm]
NP  =  8;     // Poles per disc

// PCB stator
PD  = 72.0;   PT = 1.6;   PI = 16.0;
PCB_MOUNT_R   = 34.0;   // PCB alignment hole radius [mm] (4× holes at 0/90/180/270°)
                         // No fastener needed — PCB clamped by housing sandwich

AG  =  0.5;   // Air gap per side [mm]

// Rotor-to-shaft: grub screw hub
// One M4 radial tapped hole per rotor disc bears on a D-flat on the shaft.
// Assembly: align flat to hole, insert grub screw from disc OD, tighten to 2 Nm.
GS_TAP_D  = 3.3;   // M4 tap drill diameter [mm]
GS_FLAT_D = 1.5;   // D-flat depth below shaft surface [mm]
GS_FLAT_W = 7.0;   // Axial width of each flat [mm] (covers RT=5 mm disc + 1 mm each side)

// Housing ring
HOD = 82.0;   // OD [mm]
RID = 62.0;   // Inner bore [mm]
RH  = 20.0;   // Height [mm]
BPD = 72.0;   // Assembly bolt PCD [mm] (4× M4, 45° offset from NEMA bolts)
NB  =  4;

// Anti-rotation dowel pins — 2× at 0° and 180°, r = PCB_MOUNT_R
// Standard Ø3 h6 steel dowel pins (ISO 8734).
// Press-fit into rear half; clearance fit through PCB and front half.
// Pins at 0°/180° rather than 0°/90°/180°/270° so wire slots at 90°/270°
// are unobstructed, and 180° symmetry still provides a keying check
// (final orientation confirmed by castellation pad alignment in next pass).
//
// Tolerances:
//   Press fit (rear half): Ø 2.90 mm → ~50 µm interference per side on Ø3 h6 pin
//   Clearance (PCB hole):  Ø 3.20 mm → 0.1 mm radial clearance (existing holes)
//   Clearance (front half):Ø 3.20 mm → 0.1 mm radial clearance
//   Pin length:            10 mm standard
//     – 5.0 mm pressed into rear half
//     – 1.6 mm through PCB (PT)
//     – 3.4 mm into front half clearance hole
DOWEL_PRESS_D     = 2.9;    // Drill Ø for press-fit hole in rear half [mm]
DOWEL_CLEAR_D     = 3.2;    // Drill Ø for clearance hole in front half + PCB [mm]
DOWEL_PRESS_DEPTH = 5.0;    // Depth of press-fit hole from mating face [mm]
DOWEL_CLEAR_DEPTH = 3.4;    // Depth of clearance hole from mating face [mm]
                              // 5.0 + 1.6 (PCB) + 3.4 = 10.0 mm → standard ISO 8734 Ø3×10 pin
DOWEL_R           = PCB_MOUNT_R; // Radial position = existing PCB hole PCD [mm]

// Encoder mounting — 2 tapped holes on rear end cap
// ──────────────────────────────────────────────────
// Adjust ENC_MOUNT_PCD to match your encoder's bolt circle.
// Common 58 mm body encoders (Autonics E58, Omron E6C3, etc.)
// typically use a 2-hole pattern; consult your encoder datasheet.
// Holes are at ENC_MOUNT_ANG and ENC_MOUNT_ANG + 180°.
//
// Tap size guide (metric coarse):
//   M2.5 → ENC_TAP_D = 2.05 mm
//   M3   → ENC_TAP_D = 2.50 mm  ← default
//   M4   → ENC_TAP_D = 3.30 mm
//
// Tap depth: blind from rear (outer) face.  Must satisfy:
//   ENC_TAP_DEPTH < CAP_T – BW  at the hole's radial position, OR
//   ENC_MOUNT_PCD/2 > BD/2  (hole outside bearing pocket) — always
//   true for any sensible encoder PCD, so full CAP_T is available.
//   Default 8 mm gives 3.5 mm solid land at inner face.
//
// Constraint: ENC_MOUNT_PCD/2 must be < HOD/2 – 4 mm (clear of OD wall).
//   With HOD = 82 mm → max radius = 37 mm → max PCD = 74 mm.
ENC_MOUNT_PCD   = 50.0;   // Encoder bolt circle diameter [mm]  — EDIT TO MATCH ENCODER
ENC_MOUNT_N     =  2;     // Number of tapped holes              — 2=180° · 3=120° · 4=90°
ENC_MOUNT_ANG   =  0.0;   // Angle of first hole [degrees]       — rotate to suit wiring
ENC_TAP_D       =  2.5;   // Tap drill diameter [mm]             — M3 default
ENC_TAP_DEPTH   =  8.0;   // Blind tap depth from rear face [mm]
ENC_TAP_LABEL   = "M3";   // Thread label (documentation only)

// NEMA 34
N34_FRAME   = 86.36;
N34_BOLT    = 69.60;    // Bolt pattern square dimension
N34_BOSS_OD = 73.025;   // Pilot boss OD [mm]
N34_BOSS_H  =  1.60;    // Boss protrusion [mm]
N34_BOLT_D  =  5.5;     // M5 clearance hole [mm]

// ================================================================
//  DERIVED POSITIONS  (z = 0 → PCB mid-plane)
//  +Z = front/output/NEMA face   –Z = rear/encoder face
// ================================================================

PCB_HALF    = PT / 2;
MAG_FACE_Z  = PCB_HALF + AG;             //  1.3 mm
RTOP_CEN    = MAG_FACE_Z + RT / 2;       //  3.8 mm  front rotor centre
RTOP_BACK   = RTOP_CEN + RT / 2;         //  6.3 mm  front rotor back face
RBOT_CEN    = -(MAG_FACE_Z + RT / 2);    // -3.8 mm  rear rotor centre

BIF_Z       = RH / 2;                    // 10.0 mm  bearing inner face
BCT_Z       = BIF_Z + BW / 2;            // 14.5 mm  bearing centre

CAP_T       = BW + 2.5;                  // 11.5 mm  cap body thickness
CAPT_CEN    = BIF_Z + CAP_T / 2;         // 15.75 mm cap body centre

FRONT_FACE_Z = CAPT_CEN + CAP_T / 2;     // 21.5 mm  front cap outer face
BOSS_TIP_Z   = FRONT_FACE_Z + N34_BOSS_H;// 23.1 mm  pilot boss tip

// Stepped shaft derived geometry
// Main Ø10 body : z = –FRONT_FACE_Z  →  z = +SHAFT_FRONT_TIP
// Rear Ø8 stub  : z = –FRONT_FACE_Z  →  z = –(FRONT_FACE_Z + REAR_STUB_L)
SHAFT_MAIN_L   = SHAFT_FRONT_TIP + FRONT_FACE_Z;           // 66.5 mm
SHAFT_MAIN_CEN = (SHAFT_FRONT_TIP - FRONT_FACE_Z) / 2;     // +11.75 mm from PCB mid
REAR_STUB_CEN  = -(FRONT_FACE_Z + REAR_STUB_L / 2);        // –26.5 mm from PCB mid

// ================================================================
//  MODULES
// ================================================================

// Shaft — stepped, with D-flats for rotor grub screws.
// Machining from EN1A or Al 6082 round bar:
//   1. Turn main body Ø10 h6 full length first.
//   2. Step rear end to Ø8 h6 × 10 mm.  Shoulder flush with rear cap outer face.
//   3. Mill D-flat at z = +RTOP_CEN (front rotor seat) and z = –|RBOT_CEN| (rear).
//      Flat depth GS_FLAT_D = 1.5 mm below surface, axial width GS_FLAT_W = 7 mm.
//      Both flats at the same angular position (same mill setup — one rotary index).
//   4. Deburr flat edges — grub screw point must seat cleanly.
//   5. Add circlip grooves for bearing retention in final production design.
module shaft() {
    color([0.80, 0.80, 0.82])
    difference() {
        union() {
            // Main body Ø10 — through both bearings and front protrusion
            translate([0, 0, SHAFT_MAIN_CEN])
            cylinder(d = SD, h = SHAFT_MAIN_L, center = true);
            // Rear encoder stub Ø8 × 10 mm
            translate([0, 0, REAR_STUB_CEN])
            cylinder(d = REAR_STUB_D, h = REAR_STUB_L, center = true);
        }
        // D-flat at front rotor seat (z = RTOP_CEN)
        // Removes +Y half of shaft to depth GS_FLAT_D, axial width GS_FLAT_W.
        translate([0, SD / 2 - GS_FLAT_D + SD * 2, RTOP_CEN])
        cube([SD * 2, SD * 4, GS_FLAT_W], center = true);
        // D-flat at rear rotor seat (z = RBOT_CEN) — same angular position
        translate([0, SD / 2 - GS_FLAT_D + SD * 2, RBOT_CEN])
        cube([SD * 2, SD * 4, GS_FLAT_W], center = true);
    }
}

module bearing() {
    color([0.70, 0.70, 0.75])
    difference() {
        cylinder(d = BD, h = BW, center = true);
        cylinder(d = BB + 0.5, h = BW + 1, center = true);
    }
}

// Rotor disc — pocket face at local +Z.
// Top rotor assembled with rotate([180,0,0]) so pockets face PCB.
//
// Machining:
//   1. Turn OD 60 mm, bore Ø10 H7 (Ø10.000–10.015 mm), face both
//      sides ±0.05 mm (air gap critical).
//   2. Mill 8× magnet pockets 15×11×3 mm deep, r1.5 corners, on +Z face.
//   3. Mill 8× lightening holes Ø5.5 mm between poles (optional).
//   4. Drill Ø3.3 mm radially from OD through to bore, at mid-height
//      (local z=0) at 0°.  Tap M4.  This is the grub screw hole.
//      Align shaft flat to this hole before assembly.
//      Tighten grub screw to 2 Nm — do NOT over-tighten on Al shaft.
module rotor_disc() {
    color([0.40, 0.50, 0.62])
    difference() {
        cylinder(d = RD, h = RT, center = true);
        // Shaft bore
        cylinder(d = SD, h = RT + 1, center = true);
        // Magnet pockets
        for (i = [0:NP - 1]) {
            rotate([0, 0, i * 360 / NP])
            translate([MR, 0, RT / 2 - MT / 2 + 0.01])
            linear_extrude(MT + 0.02)
            offset(r = 1.5) offset(r = -1.5)
            square([ML, MW], center = true);
        }
        // Lightening holes
        for (i = [0:NP - 1]) {
            rotate([0, 0, i * 360 / NP + 180 / NP])
            translate([MR, 0, 0])
            cylinder(d = 5.5, h = RT - 1.5, center = true);
        }
        // M4 grub screw hole — radial, at mid-height (z=0), angle 0°.
        // Drilled from OD to bore (length = RD/2, centres at x = RD/4).
        // Aligns with D-flat on shaft.  Shown as through-hole for clarity;
        // tapping stops 2 mm short of bore wall in practice.
        rotate([0, 90, 0])
        translate([0, 0, RD / 4])
        cylinder(d = GS_TAP_D, h = RD / 2 + 1, center = true);
    }
}

module rotor_magnets() {
    for (i = [0:NP - 1]) {
        color(i % 2 == 0 ? [0.90, 0.15, 0.15] : [0.15, 0.25, 0.90])
        rotate([0, 0, i * 360 / NP])
        translate([MR, 0, RT / 2 - MT / 2])
        linear_extrude(MT)
        offset(r = 1.5) offset(r = -1.5)
        square([ML, MW], center = true);
    }
}

module rotor_asm() { rotor_disc(); rotor_magnets(); }

module pcb_stator() {
    color([0.13, 0.47, 0.13], 0.85)
    difference() {
        cylinder(d = PD, h = PT, center = true);
        cylinder(d = PI, h = PT + 1, center = true);
    }
    for (i = [0:11]) {
        color(i%3==0?[0.9,0.2,0.2]:i%3==1?[0.85,0.80,0.1]:[0.15,0.25,0.9],0.8)
        rotate([0,0,i*30]) translate([22,0,0]) rotate([0,0,90])
        linear_extrude(PT+0.3,center=true)
        difference(){
            offset(r=0.5)offset(r=-0.5)square([22,9.8],center=true);
            square([17,6.0],center=true);
        }
    }
    // 4× alignment holes at r=34 mm, 0/90/180/270°.
    // Holes at 0° and 180° accept Ø3 dowel pins pressed into housing_rear.
    // Holes at 90° and 270° are plain clearance (no pin, no fastener).
    // Together: positively locks PCB rotation; clamping handled by M4 bolts.
    for (i=[0:3]){
        color([0.1,0.1,0.1])
        rotate([0,0,i*90]) translate([PCB_MOUNT_R,0,0])
        cylinder(d=3.2,h=PT+0.3,center=true);
    }
}

// ── Split housing shared geometry ─────────────────────────────────────────────
RH_HALF     = RH / 2;                   //  10.0 mm  height of each half
PCB_RECESS  = (PT + 0.3) / 2;          //   0.95 mm recess depth per half
                                         //   Together: Ø72.3 × 1.9 mm pocket

// Housing — front half (+Z, mates at PCB plane z = 0)
// ──────────────────────────────────────────────────
// Module origin: mating face at local z = 0, solid extends to z = +RH_HALF.
// In assembly: translate to z = 0 (no shift needed — inner face already at z=0).
//
// This half sits between the PCB (z=0) and the front end cap (+Z).
// It has NO wire slots — rotor and bearing occupy the +Z space.
//
// Machining — Al 6061:
//   1. Face blank to RH_HALF (10 mm), square both faces ±0.05 mm.
//   2. Turn OD 82 mm.
//   3. Bore rotor clearance Ø62 mm through.
//   4. Bore PCB recess Ø72.3 mm × 0.95 mm from mating (inner) face.
//   5. Drill 4× Ø4.5 mm M4 clearance through at Ø72 PCD, 45°/135°/225°/315°.
//   6. Drill 2× Ø3.2 mm dowel clearance holes at r=34 mm, 0° and 180°,
//        depth DOWEL_CLEAR_DEPTH (4 mm) from mating face.
//        These accept the protruding ends of Ø3 h6 × 10 mm dowel pins
//        pressed into the rear half.
//
// FDM: mating face DOWN on build plate. Recess faces up — no overhang.
module housing_front() {
    color([0.42, 0.42, 0.42])
    difference() {
        cylinder(d = HOD, h = RH_HALF);
        // Rotor bore
        cylinder(d = RID, h = RH_HALF + 1);
        // PCB recess from mating face (z = 0)
        cylinder(d = PD + 0.3, h = PCB_RECESS);
        // 4× M4 assembly bolt clearance holes, Ø72 PCD, 45° offset
        for (i = [0:NB - 1])
            rotate([0, 0, i * 90 + 45])
            translate([BPD / 2, 0, 0])
            cylinder(d = 4.5, h = RH_HALF + 1);
        // 2× dowel pin clearance holes at 0° and 180°, r = DOWEL_R
        // Blind from mating face, depth DOWEL_CLEAR_DEPTH
        for (a = [0, 180])
            rotate([0, 0, a])
            translate([DOWEL_R, 0, 0])
            cylinder(d = DOWEL_CLEAR_D, h = DOWEL_CLEAR_DEPTH);
    }
}

// Housing — rear half (–Z, mates at PCB plane z = 0)
// ──────────────────────────────────────────────────
// Module origin: mating face at local z = 0, solid extends to z = +RH_HALF.
// In assembly: rotate([180,0,0]) so it extends to –Z (inner face still at z=0).
//
// This half carries:
//   • 4 wire exit slots at 0°/90°/180°/270° for Ph_A/B/C/Neutral.
//     Slots span from just outside PCB OD (r=36.5 mm) to housing OD (r=41 mm)
//     — clear of dowel positions at r=34 mm.
//     Second pass adds circumferential OD groove connecting all four slots.
//   • 2× press-fit dowel pin holes at 0° and 180° (anti-rotation).
//
// Machining — Al 6061:
//   1. Face blank to RH_HALF (10 mm), square both faces ±0.05 mm.
//   2. Turn OD 82 mm.
//   3. Bore rotor clearance Ø62 mm through.
//   4. Bore PCB recess Ø72.3 mm × 0.95 mm from mating (inner) face.
//   5. Drill 4× Ø4.5 mm M4 clearance through at Ø72 PCD, 45°/135°/225°/315°.
//   6. Mill 4× wire exit slots 5 × 5.5 mm at 0°/90°/180°/270°, full height.
//        Slot centres at r = 39 mm (wall between PCB OD and housing OD).
//        Verify clearance from dowel holes before milling — 1 mm radial gap.
//   7. Drill 2× Ø2.9 mm dowel PRESS-FIT holes at r=34 mm, 0° and 180°,
//        depth DOWEL_PRESS_DEPTH (5 mm) from mating face.
//        Press Ø3 h6 × 10 mm steel dowel pins flush to 0.5 mm below mating face.
//        Do NOT press pins until PCB is positioned in recess.
//
// FDM: outer (encoder-side) face DOWN on build plate. Mating face UP.
//   Print dowel holes undersized by 0.1 mm and ream to Ø2.9 mm before pressing.
module housing_rear() {
    // Wire slot geometry — centred at r = HOD/2 - 2 = 39 mm
    // Radial width 5 mm → spans r = 36.5 to 41.5 mm
    // Clears PCB OD at r = 36 mm and dowel at r = 34 mm + 1.45 mm = 35.45 mm
    SLOT_CX = HOD / 2 - 2;      // 39 mm — slot radial centre

    color([0.30, 0.30, 0.30])
    difference() {
        cylinder(d = HOD, h = RH_HALF);
        // Rotor bore
        cylinder(d = RID, h = RH_HALF + 1);
        // PCB recess from mating face (z = 0)
        cylinder(d = PD + 0.3, h = PCB_RECESS);
        // 4× M4 assembly bolt clearance holes, Ø72 PCD, 45° offset
        for (i = [0:NB - 1])
            rotate([0, 0, i * 90 + 45])
            translate([BPD / 2, 0, 0])
            cylinder(d = 4.5, h = RH_HALF + 1);
        // 4× wire exit slots — Ph_A(0°) Ph_B(90°) Ph_C(180°) Neutral(270°)
        // Slots in wall between PCB OD and housing OD, clear of dowel positions.
        // Second pass adds circumferential groove on OD connecting all four.
        for (i = [0:3])
            rotate([0, 0, i * 90])
            translate([SLOT_CX, 0, RH_HALF / 2])
            cube([5, 5.5, RH_HALF + 1], center = true);
        // 2× dowel pin PRESS-FIT holes at 0° and 180°, r = DOWEL_R
        // Blind from mating face, depth DOWEL_PRESS_DEPTH
        for (a = [0, 180])
            rotate([0, 0, a])
            translate([DOWEL_R, 0, 0])
            cylinder(d = DOWEL_PRESS_D, h = DOWEL_PRESS_DEPTH);
    }
}

// Front end cap — NEMA 34 square face.
// Origin: cap centre.  Inner face at local –CAP_T/2.
//
// Machining notes — Al 6061 plate:
//   1. Face blank to CAP_T (11.5 mm).
//   2. Mill square 86.36 × 86.36 mm outline.
//   3. Turn or mill pilot boss: Ø73.025 h6 × 1.60 mm on front face.
//      h6 tolerance: –0.000 / –0.019 mm.
//   4. Bore bearing pocket Ø30.000–30.021 (H7) × 9 mm from rear face.
//   5. Bore shaft clearance Ø12 mm through.
//   6. Drill 4× Ø5.5 at (±34.80, ±34.80) mm — NEMA 34 M5 mounting.
//   7. Drill 4× Ø4.5 at Ø72 PCD 45° off — M4 housing assembly bolts.
//   NEMA holes (radius 49.2 mm) and assembly holes (radius 36 mm)
//   do not conflict.
module front_end_cap() {
    color([0.68, 0.52, 0.32])
    difference() {
        union() {
            // Square body
            cube([N34_FRAME, N34_FRAME, CAP_T], center = true);
            // Pilot boss — protrudes from front face (+CAP_T/2)
            translate([0, 0, CAP_T / 2 + N34_BOSS_H / 2])
            cylinder(d = N34_BOSS_OD, h = N34_BOSS_H, center = true);
        }
        // Shaft clearance through everything
        cylinder(d = SD + 2.0, h = CAP_T + N34_BOSS_H + 1, center = true);
        // Bearing pocket from rear face
        translate([0, 0, -CAP_T / 2 + BW / 2])
        cylinder(d = BD + 0.021, h = BW, center = true);
        // 4× M5 NEMA 34 mounting holes
        for (sx = [-1, 1]) for (sy = [-1, 1])
            translate([sx * N34_BOLT / 2, sy * N34_BOLT / 2, 0])
            cylinder(d = N34_BOLT_D, h = CAP_T + N34_BOSS_H + 1, center = true);
        // 4× M4 housing assembly holes at Ø72 PCD 45° offset
        for (i = [0:NB - 1])
            rotate([0, 0, i * 90 + 45])
            translate([BPD / 2, 0, 0])
            cylinder(d = 4.5, h = CAP_T + 2, center = true);
    }
}

// Rear end cap — round 82 mm OD, encoder / secondary shaft end.
// Shaft protrudes for encoder magnet or secondary coupling.
// Optional: Ø14 × 3 mm counterbore on rear face for encoder magnet
//   (AS5048A diametrically magnetised Ø6 magnet, ~15 mm separation
//    from rotor magnets minimum — increase shaft length if needed).
// Machining: turn OD 82 mm, face to CAP_T, bore bearing pocket and
//   shaft clearance, drill 4× M4.
module rear_end_cap() {
    color([0.55, 0.55, 0.55])
    difference() {
        cylinder(d = HOD, h = CAP_T, center = true);
        // Shaft clearance — 9 mm (clears Ø8 encoder stub with 0.5 mm radial)
        // Ø10 main shaft is captured by bearing pocket; only stub exits here.
        cylinder(d = REAR_STUB_D + 1.0, h = CAP_T + 1, center = true);
        // Bearing pocket from inner face (–CAP_T/2), depth BW = 9 mm
        translate([0, 0, -CAP_T / 2 + BW / 2])
        cylinder(d = BD + 0.021, h = BW, center = true);
        // 4× M4 housing assembly holes at Ø72 PCD 45° offset
        for (i = [0:NB - 1])
            rotate([0, 0, i * 90 + 45])
            translate([BPD / 2, 0, 0])
            cylinder(d = 4.5, h = CAP_T + 1, center = true);
        // Encoder magnet counterbore — uncomment to machine
        // translate([0, 0, CAP_T / 2 - 1.5])
        //     cylinder(d = 14, h = 3, center = true);
        // 2× encoder mounting tapped holes on ENC_MOUNT_PCD
        // Drilled blind from outer (rear) face to ENC_TAP_DEPTH.
        // Tap to ENC_TAP_LABEL after drilling.
        // The Ø10 bearing pocket (r=15 mm) is well inside ENC_MOUNT_PCD/2
        // so full cap thickness is available at the hole positions.
        for (i = [0 : ENC_MOUNT_N - 1])
            rotate([0, 0, ENC_MOUNT_ANG + i * 360 / ENC_MOUNT_N])
            translate([ENC_MOUNT_PCD / 2, 0, CAP_T / 2 - ENC_TAP_DEPTH / 2])
            cylinder(d = ENC_TAP_D, h = ENC_TAP_DEPTH + 0.01, center = true);
    }
}

// ================================================================
//  ASSEMBLY
//  z = 0 → PCB mid-plane
//  +Z = front (NEMA 34 face, primary shaft output)
//  –Z = rear  (encoder / secondary shaft)
// ================================================================
module assembly() {

    shaft();
    pcb_stator();

    // Housing front half — mating face at z=0, extends to +Z
    // No explode offset: the split face is visible at z=0 in exploded view
    housing_front();

    // Housing rear half — flipped so mating face at z=0, extends to –Z
    // Wire exit slots face –Z (encoder side)
    rotate([180, 0, 0])
    housing_rear();

    // Front (top) rotor — rotate 180° X so pockets face –Z toward PCB
    translate([0, 0, RTOP_CEN + EXP])
    rotate([180, 0, 0])
    rotor_asm();

    // Rear (bottom) rotor — normal orientation, pockets face +Z
    translate([0, 0, RBOT_CEN - EXP])
    rotor_asm();

    // Front bearing
    translate([0, 0,  BCT_Z + EXP * 2]) bearing();

    // Rear bearing
    translate([0, 0, -BCT_Z - EXP * 2]) bearing();

    // Front end cap — NEMA 34 square face
    // Inner face at z = BIF_Z = 10 mm → cap centre at CAPT_CEN
    translate([0, 0, CAPT_CEN + EXP * 3])
    front_end_cap();

    // Rear end cap — flipped so inner face opens toward +Z
    translate([0, 0, -CAPT_CEN - EXP * 3])
    rotate([180, 0, 0])
    rear_end_cap();
}

// ================================================================
//  PART DISPATCH
//  Each branch orients the part for FDM printing (flat face on the
//  build plate, z ≥ 0) or natural machining reference (flat face
//  down).  The shaft is laid on its side to minimise layer-line
//  weakness along the bore axis; for a machined shaft ignore the
//  STL orientation.
// ================================================================

if (PART == "assembly") {
    // ── Full assembly (GUI view) ──────────────────────────────
    assembly();
    // Cross-section — uncomment to inspect bore / air gap stack:
    // intersection() { assembly(); cube([200, 200, 200]); }

} else if (PART == "shaft") {
    // ── Shaft ─────────────────────────────────────────────────
    // Print orientation: lying along X axis, flat on build plate.
    //   For FDM this gives round cross-sections on Z layers.
    //   For machining: mount between centres, turn from bar stock.
    // The stepped shaft extends from –FRONT_FACE_Z to +SHAFT_FRONT_TIP
    // in assembly space.  Here we re-centre on origin and lay flat.
    rotate([0, 90, 0])
    translate([0, 0, -SHAFT_MAIN_CEN])
    shaft();

} else if (PART == "rotor_disc") {
    // ── Rotor disc (both rotors are identical) ─────────────────
    // Print orientation: pocket face UP (–Z in assembly becomes
    //   local +Z here), flat back face on build plate.
    // For machining: clamp on back face, machine pocket face up.
    // Disc is RT=5 mm tall; translate up by RT/2 to sit on plate.
    translate([0, 0, RT / 2])
    rotor_disc();

} else if (PART == "housing_front") {
    // ── Housing front half (+Z, front/rotor side) ──────────────
    // Print orientation: mating face DOWN on build plate.
    //   PCB recess faces up — no overhangs, no support needed.
    //   M4 bolt holes are vertical — print cleanly.
    // For machining: clamp on OD, face and bore from mating face first.
    housing_front();

} else if (PART == "housing_rear") {
    // ── Housing rear half (–Z, encoder/wire side) ──────────────
    // Print orientation: outer (encoder-side) face DOWN, mating face UP.
    //   Wire slots print vertically — no support needed.
    //   PCB recess faces up — clean bridging over Ø72.3 mm.
    // For machining: clamp on OD, face mating face, bore, mill slots.
    //   Flip: face outer face, bore continuation.
    housing_rear();

} else if (PART == "front_end_cap") {
    // ── Front end cap (NEMA 34 square face) ────────────────────
    // Print orientation: NEMA face DOWN on build plate (boss tip
    //   at z=0), flat bearing-pocket face UP.  Puts the critical
    //   pilot boss dimension in the first layers against the glass/
    //   sheet for best dimensional accuracy.
    // For machining: clamp on square face, bore from rear; flip
    //   and face square, then turn boss on rotary.
    rotate([180, 0, 0])
    translate([0, 0, -(CAP_T / 2 + N34_BOSS_H)])
    front_end_cap();

} else if (PART == "rear_end_cap") {
    // ── Rear end cap ───────────────────────────────────────────
    // Print orientation: outer (encoder) face DOWN on build plate.
    //   Blind encoder tap holes print upward — no internal supports.
    //   Bearing pocket opening faces UP — bridges over the bore.
    // For machining: clamp on OD, bore bearing pocket and shaft
    //   clearance from inner face; flip and drill encoder taps
    //   from outer face.
    rotate([180, 0, 0])
    translate([0, 0, -CAP_T / 2])
    rear_end_cap();

} else {
    // ── Unknown part name — show warning geometry ───────────────
    color([1, 0, 0])
    translate([0, 0, 5])
    linear_extrude(2)
    text(str("Unknown PART: '", PART, "'"), size = 4, halign = "center");
    echo(str("ERROR: PART='", PART, "' is not recognised.  Valid values: ",
             "assembly | shaft | rotor_disc | housing_front | housing_rear | ",
             "front_end_cap | rear_end_cap"));
}

// ================================================================
//  CONSOLE SUMMARY
// ================================================================
echo("=== Pancake Motor — NEMA 34 Dual-Shaft (Stepped) ===");
echo(str("  NEMA 34 pilot boss OD    : ", N34_BOSS_OD, " mm (h6 tol: -0.000/-0.019)"));
echo(str("  NEMA 34 boss protrusion  : ", N34_BOSS_H, " mm"));
echo(str("  NEMA 34 bolt centres     : (±", N34_BOLT/2, ", ±", N34_BOLT/2, ") mm"));
echo(str("  Housing body OD          : ", HOD, " mm round"));
echo(str("  Air gap each side        : ", AG, " mm"));
echo(str("  Magnet face z            : ", MAG_FACE_Z, " mm from PCB mid"));
echo(str("  Front rotor back face z  : ", RTOP_BACK, " mm"));
echo(str("  Bearing centre z         : ±", BCT_Z, " mm"));
echo(str("  NEMA front face z        : ", FRONT_FACE_Z, " mm"));
echo(str("  Pilot boss tip z         : ", BOSS_TIP_Z, " mm"));
echo(str("  Shaft (front) Ø          : ", SD, " mm, protrudes ", SHAFT_FRONT_TIP - BOSS_TIP_Z, " mm beyond boss tip"));
echo(str("  Shaft (rear) Ø           : ", REAR_STUB_D, " mm stub, ", REAR_STUB_L, " mm long (58mm hollow-shaft encoder)"));
echo(str("  Rear shoulder z          : –", FRONT_FACE_Z, " mm (flush with rear cap outer face)"));
echo(str("  Overall body length      : ", 2 * FRONT_FACE_Z + N34_BOSS_H, " mm (exc. shaft)"));
echo(str("  Encoder mount PCD        : ", ENC_MOUNT_PCD, " mm (", ENC_TAP_LABEL, " tapped × ", ENC_MOUNT_N, ", every ", 360/ENC_MOUNT_N, "°)"));
echo(str("  Encoder hole angle       : ", ENC_MOUNT_ANG, "° and ", ENC_MOUNT_ANG + 180, "°"));
echo(str("  Tap drill Ø              : ", ENC_TAP_D, " mm → tap ", ENC_TAP_LABEL, " blind ", ENC_TAP_DEPTH, " mm deep"));
echo(str("  Radial land to OD wall   : ", HOD/2 - ENC_MOUNT_PCD/2, " mm (must be > 4 mm)"));
echo(str("  Housing split            : at z=0 (PCB mid-plane)"));
echo(str("  Housing half height      : ", RH/2, " mm each"));
echo(str("  PCB recess per half      : Ø", PD+0.3, " mm × ", (PT+0.3)/2, " mm deep"));
echo(str("  PCB retention            : sandwiched + clamped by 4× M4 assembly bolts"));
echo(str("  Anti-rotation dowels     : 2× Ø3 h6 × 10 mm steel pin at 0° and 180°, r=", DOWEL_R, " mm"));
echo(str("  Press-fit hole (rear)    : Ø", DOWEL_PRESS_D, " mm × ", DOWEL_PRESS_DEPTH, " mm deep — ~50 µm interference per side"));
echo(str("  Clearance hole (front)   : Ø", DOWEL_CLEAR_D, " mm × ", DOWEL_CLEAR_DEPTH, " mm deep — 0.1 mm radial clearance"));
echo(str("  PCB holes (0° + 180°)    : Ø", DOWEL_CLEAR_D, " mm clearance through PCB (existing holes reused)"));
echo(str("  Wire exit slots          : 4× in rear half at 0°/90°/180°/270°, r=39 mm centre, clear of dowels"));
echo(str("  Wire routing             : OD groove connecting all 4 slots — added in next pass"));
echo(str("  Rotor grub screw         : 1× M4 radial per disc, tap drill Ø", GS_TAP_D, " mm from OD"));
echo(str("  Shaft D-flat depth       : ", GS_FLAT_D, " mm, width ", GS_FLAT_W, " mm, at z=±", RTOP_CEN, " mm"));
