
$fn = 120;
HOD=82; RID=62; RH_HALF=10; PD=72; PT=1.6; BPD=72; NB=4;
PCB_RECESS=(PT+0.3)/2;
DOWEL_PRESS_D=2.9; DOWEL_CLEAR_D=3.2;
DOWEL_PRESS_DEPTH=5.0; DOWEL_CLEAR_DEPTH=3.4; DOWEL_R=34;
SLOT_CX=39; SLOT_W=5; SLOT_H=5.5;
PART="__PART__";

module housing_front(){
    difference(){
        cylinder(d=HOD,h=RH_HALF);
        cylinder(d=RID,h=RH_HALF+1);
        cylinder(d=PD+0.3,h=PCB_RECESS);
        for(i=[0:NB-1])
            rotate([0,0,i*90+45])translate([BPD/2,0,0])
            cylinder(d=4.5,h=RH_HALF+1);
        for(a=[0,180])
            rotate([0,0,a])translate([DOWEL_R,0,0])
            cylinder(d=DOWEL_CLEAR_D,h=DOWEL_CLEAR_DEPTH);
    }
}

module housing_rear(){
    difference(){
        cylinder(d=HOD,h=RH_HALF);
        cylinder(d=RID,h=RH_HALF+1);
        cylinder(d=PD+0.3,h=PCB_RECESS);
        for(i=[0:NB-1])
            rotate([0,0,i*90+45])translate([BPD/2,0,0])
            cylinder(d=4.5,h=RH_HALF+1);
        for(i=[0:3])
            rotate([0,0,i*90])translate([SLOT_CX,0,RH_HALF/2])
            cube([SLOT_W,SLOT_H,RH_HALF+1],center=true);
        for(a=[0,180])
            rotate([0,0,a])translate([DOWEL_R,0,0])
            cylinder(d=DOWEL_PRESS_D,h=DOWEL_PRESS_DEPTH);
    }
}

if(PART=="housing_front") housing_front();
else if(PART=="housing_rear") housing_rear();
