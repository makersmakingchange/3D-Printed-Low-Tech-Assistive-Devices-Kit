// palm pen holder - scruss,  -customizable!

// 2021-01 - increased max pen size to 22 mm
// 2020-02 - revised nut catch - a bit snug before

//CUSTOMIZER VARIABLES
// Hand Width - mm
hand_width = 110; // [70:150]
// Hand Thickness - thumb side - mm
thumb_thick = 35; // [20:50]
// Hand Thickness - pinkie side - mm
pinkie_thick = 26; // [15:35]
// Device Width - mm
strap_width = 24; // [16:36]
// Maximum Pen Diameter - mm
pen_dia = 12.5; // [5:22]
// Your text here (<= 35 letters)
engr_text="Makers Making Change"; // 24
// Left handed user?
lefty=false;
//CUSTOMIZER VARIABLES END

module naff() { /* naff all to see here */ }

delta_thick = (thumb_thick - pinkie_thick)/2;
axis_width = hand_width - (thumb_thick + pinkie_thick)/2;
angle = atan2(delta_thick, axis_width);
strap_thick = 5;
pen_block_width = pen_dia+4;
block_start = strap_thick/6-(thumb_thick+strap_thick)/2;
extra_snout = 15;   // for screw
nut_tol=0.3;
m4head_max=8.13 + nut_tol;
m4head_deep=8;
m4_dia=4+nut_tol;
font_size=strap_width/5;


sides=12;    // for when we need a small roundish hole
eps=1e-3;

function dist(k)=sqrt(pow(k.x, 2) + pow(k.y, 2));
function rot_pt(k, a) = [dist(k) * cos(a), dist(k) * sin(a)];

thumb_centre = [0, 0];
pinkie_centre = rot_pt([axis_width, 0], -angle);

module full_profile() {
    translate([strap_thick/2, 0])translate([0, strap_width/2])scale([1, strap_width/strap_thick])rotate(360/(sides*2))circle(r=(strap_thick/2)/cos(180/sides), $fn=sides);
}

module half_profile_outer() {
    intersection() {
        translate([-strap_thick/2, 0])full_profile();
        square([strap_thick/2, strap_width]);
    }
}

module half_profile_inner() {
    intersection() {
        full_profile();
        square([strap_thick/2, strap_width]);
    }
}

module blob() {
    translate([0, strap_thick/2, 0])rotate_extrude($fn=sides)half_profile_outer();
}

module arm() {
    union() {
        translate([-eps, 0,0])rotate([90,0,90])linear_extrude(height=axis_width+2*eps)full_profile();
        translate([axis_width, 0, 0])blob();
    }
}

/*
engr_text="STEWART";
lefty=0;
font_size=strip_width/5;
*/

module engraved_arm() {
    difference() {
    //union() {
        arm();
        translate([axis_width/2, strap_thick, strap_width/2])rotate([-90,0,0])linear_extrude(height=strap_thick/4, center=true)rotate(180*((lefty)?1:0))scale([0.95,1])text(engr_text, size=font_size, halign="center", valign="center",font="Calibri:style=Light");
    }
}

module tongs() {
    union() {
        arm();
        translate([0, thumb_thick+strap_thick, 0])rotate([0,0,-2*angle])engraved_arm();
        translate([0, thumb_thick/2 + strap_thick, 0])difference() {
            rotate_extrude()translate([thumb_thick/2, 0])half_profile_inner();
            linear_extrude(height=strap_width)polygon([
                [eps, -thumb_thick],
                [eps, 0],
                [thumb_thick * cos(90-2*angle), thumb_thick * sin(90-2*angle)],
                [thumb_thick, thumb_thick],
                [thumb_thick, -thumb_thick]
            ]);
        }
    blob();
    translate([0, thumb_thick+strap_thick, 0])blob();
    }
}
 // This section changes the part where the the bolt goes in. (2*thumb_thick/2) changed from /3 to /2 
module pen_block() {
    translate([block_start-pen_block_width, 0, 0])union() {
        cube([pen_block_width, 2 * thumb_thick, strap_width]);
        translate([-extra_snout,2*strap_thick,0])cube([pen_block_width+extra_snout, m4_dia*3.5, strap_width]);
    }
}

blob_coords = [
    [block_start, thumb_thick+strap_thick + abs(block_start) * sin(2*angle), 0],   // TR corner
    [block_start, 0, 0],   // BR corner
    [block_start - pen_block_width, 0, 0],   // B middle
    [block_start - pen_block_width - 2*extra_snout/3, strap_thick, 0],   // B near snout
    [block_start - pen_block_width - extra_snout +strap_thick/2, 2*strap_thick, 0],   // B at snout
    [block_start - pen_block_width - extra_snout +strap_thick/2, 2*strap_thick+m4head_max, 0],   // top of snout
    [block_start - pen_block_width - 2*extra_snout/3, 7*thumb_thick/8, 0],   // backing off  snout
    [block_start - pen_block_width, thumb_thick+strap_thick + abs(block_start) * sin(2*angle), 0],   // T corner
    [block_start, thumb_thick+strap_thick + abs(block_start) * sin(2*angle), 0]   // TR corner AGAIN LAST
];

module snout_path() {
    for (i=[0:len(blob_coords)-2]) {
        hull() {
            translate(blob_coords[i])blob();
            translate(blob_coords[i+1])blob();
        }
    }
}

module trimmed_block() {
    intersection() {
        pen_block();
        hull()snout_path();
    }
}

module stays() {
    union() {
        hull() {
            translate([0, thumb_thick+strap_thick, 0])blob();
            translate(blob_coords[0])blob();
        }
        hull() {
            blob();
            translate(blob_coords[1])blob();
        }
    }
}

module holder() {
    union() {
        tongs();
        stays();
        snout_path();
        trimmed_block();
    }
}

module pen_hole() {
    translate([block_start-pen_block_width/2,thumb_thick,strap_width/2])rotate([90,0,0])linear_extrude(height=4*thumb_thick, center=true)circle(r=(pen_dia/2)/cos(180/sides), $fn=sides);
}

module screw_bore() {
    translate([blob_coords[4].x-strap_thick/2, strap_thick/2+(blob_coords[4].y + blob_coords[5].y)/2, strap_width/2])rotate([0,90,0])union() {
        linear_extrude(height=m4head_deep+strap_thick/4)circle(r=(m4head_max/2)/cos(180/sides), $fn=sides);
        linear_extrude(height=extra_snout+strap_thick)circle(r=(m4_dia/2)/cos(180/sides), $fn=sides);
    }
}

module m4nut() {
    rotate([0,90,0])linear_extrude(height=3.2 + nut_tol, center=true)circle(r=((7/2)/(sqrt(3)/2)) + (nut_tol/2), $fn=6);
}

module m4nut_catch() {
    translate([block_start-pen_block_width-(3.2 + nut_tol)/2,strap_thick/2+(blob_coords[4].y + blob_coords[5].y)/2,strap_width/2])hull() {
        translate([0,0,-nut_tol])m4nut();
        translate([0,0,strap_width])m4nut();
    }
}

module holes() {
    union() {
        pen_hole();
        screw_bore();
        m4nut_catch();
    }
}

// projection(cut=true)
translate([-blob_coords[4].x+strap_thick/2,0,0])difference() {
    holder();
    holes();
}
