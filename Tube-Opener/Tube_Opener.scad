// Assistive Paint_Tube Opener - scruss, 2019-12,
// for Makers Making Change
// designed for _ at Rumsey CP group.
// modified 2020-10 to be properly manifold

// NB - this isn't a very parametric design so
// it may be hard to understand what each module does.
// You can scale the STL up for larger tubes, though.

$fn=64;
eps=1e-4;

/*

 *** Paint Tube Cap Dimensions (woo!)
 
 Brand  Size    Diameter    Depth   Note
 ================================================
 W&N    50 ml   21           5.5    
 W&N    14 ml   17           4      
 Nobel  12 ml   11 - 13     12      tapered; say 12 mm
 ??     ??      16           9      small glass vial
 
 let's say working range 10 - 25 mm
 */

module leg_profile() {
    translate([0,4])offset(r=1)square([3,6], center=true);
}

module vert_flange() {
    translate([1.5,6])offset(r=1)square([1,10], center=true);
}

module flange_leg_pro() {
    union() {
        translate([2.5, 0])leg_profile();
        vert_flange();
    }
}

module serration(size, spacing, length) {
    translate([0,-(size/2)*cos(30)])for (i=[0:(length/spacing)-1]) {
        translate([i*spacing, 0])rotate(-30)circle(d=size, $fn=3);
    }
}

teeth=3;

module hinge() {
    // this previously wasn't quite intersecting and caused problems
    translate([eps,0,0])rotate([0,0,88])rotate_extrude(angle=184)translate([6,0])leg_profile();
}


module serrated_leg() {
    translate([0,-6,0])union() {
        translate([0,-2.5,0])rotate([90,0,90])linear_extrude(height=105)flange_leg_pro();
        translate([teeth,1.2*teeth,3-eps])linear_extrude(height=5)serration(teeth, teeth, 105-teeth);
    }
}

module guard_profile() {
    translate([1.5,10])offset(r=1)square([1,18], center=true);
}

module new_guard_profile() {
    translate([eps, eps])offset(r=1)offset(r=-1)square([3,20]);
}

module guard() {
    // rotate_extrude must be above x-axis, I learn today
    translate([101,25-(100*sin(9))+0.5,0])rotate([0,0,-15-90-5])rotate_extrude(angle=30, convexity=10)translate([25,eps])new_guard_profile();
}


module button() {
    translate([0,0,1.5])intersection() {
        sphere(d=5);
        cube([20,20,3], center=true);
    }
}

module safety() {
    hull() {
        translate([2,-2.5-2,0])button();
        translate([100,-2.5-2,0])button();
        translate([105,-2.5-2-(105*sin(6)),0])button();
    }
}

module angled_leg() {
    union() {
        rotate([0,0,-5])serrated_leg();
        safety();
    }
}


module tongs() {
    union() {
        hinge();
        angled_leg();
        mirror([0,1,0])angled_leg();
    }
}

union() {
    tongs();
    translate([0,0,1])guard();
}
