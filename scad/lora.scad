$fn = 20;

/* wall thickness */
wt = 1.5;
dx = 2.5;
dy = 1.82;
dz = .6;
sp = .4;

module device () {

    module switch(x, y) {
    translate(v = [dx + 2.54 * x, dy + 2.54 * y, dz]) {
            color(c = [.2, .2, .2]) {
                cube(size = [12.7, 12.7, 9.3], center = false);
            }   
            color(c = [.8, .8, .8]) {
                translate(v = [.5 * (12.7 - 10.2), .5 * (12.7 - 10.2), 9.3]) {
                    cube(size = [10.2, 10.2, 2.1], center = false);
                }
            }
        }
    }

    module platina() {
    difference() {
        cube(size = [50, 90, dz], center = false);
            for (i = [0: 18]) {
                for (j = [0:34]) {
                    translate( v = [dx + 2.54 *i, dy + 2.54 * j, 0]) {
                        cylinder(h = 10, r = .4, center = true);
                    }
                }
            }
        }
    }

    module pinheader(x, y) {
        translate(v= [dx - 1.27 + x * 2.54, dy -1.27 + y * 2.54, dz]) {
            color(c = [.2, .2, .2]) {
                cube(size = [x  +18 * 2.54, 1 * 2.54 , 14.5 - 1.8 - dz], center = false);
            }
        }
    }

    module carrier(x, y) {
        translate(v= [dx - 1.27 - 2.54 + x * 2.54, dy -1.27 + y * 2.54, 14.5 - 1.8]) {
            color(c = [.8, .8, .8]) {
                cube(size = [20 * 2.54, 10 * 2.54 , 1.8], center = false);
            }
        }
    }

    module display(x, y) {
        translate(v= [dx - 1.27 + x * 2.54, dy -1.27 + y * 2.54, 14.5 ]) {
            color(c = [.2, .2, .2]) {
                cube(size = [13 * 2.54, 8 * 2.54 , 5.2], center = false);
            }
        }
    }

    platina();
    switch(3, 2);
    switch(10, 2);
    switch(3, 9);
    switch(10, 9);
    pinheader(0, 23);
    pinheader(0, 32);
    carrier(0, 23);
    display(5, 24);
}

module snapper() {
    
   Points = [
        [ 0,  0,  0 ],
        [ 2.0,  0,  0 ],
        [ 0,  5,  0 ],
        [ 2.0,  5,  0 ], 

        [ 0,  0,  4 ],
        [ 0.7,  0,  4 ],
        [ 2.0,  0,  1 ],
    
        [ 0,  5,  4 ],
        [ 0.7,  5,  4 ],
        [ 2.0,  5,  1]];
  
    Faces = [
        [0, 1, 3, 2],
        [4, 7, 8, 5],
        [5, 8, 9, 6],
        [1, 6, 9, 3],
        [0, 2, 7, 4],
        [0, 4, 5, 6, 1],
        [2, 3, 9, 8, 7]
    ];
    
    polyhedron( Points, Faces );    
}

/*
 * column() - column with fillet
 *
 * h  - height above fillet bottom
 * hs - height of socket below fillet bottom
 *      socket redius is (r + rf)
 * r -  column radius above fillet
 * rf - fillet radius
 */
module column(h, hs, r, rf) {
    difference () {
        union () {
            translate([0, 0, -hs]) {
                cylinder(h = hs + rf, r = r + rf, center = false);
            }
            cylinder(h = h, r = r , center = false);
        };
        rotate_extrude() {
            translate([r + rf, rf, 0]) {
                circle(rf);
            }
        };
    }
}

/*
 * fillet() - fillet
 *
 * d - wall thickness
 * l - length
 * r - fillet radius
 */
module fillet(d, l, r) {
    difference () {
        translate([-d, -d, 0]) {
            cube([d + r, d + r, l]);
        }
        translate([r, r, -1]) {
            linear_extrude(height=l + 2) {
                circle(r);
            }
        };
    }
}

module support() {
    
    hs = 9.3 - .4;
    di = 2;
    difference () {
        union () {
        translate( [0, 0, -4.3]) {
            column(h = hs - wt, hs = wt, r = .5 * di + wt, rf = 2 * wt);
        }
    }
        cylinder(h = 16, d = di, center = true);
    }
}    

module bottom() {

    /* bottom wall */
    translate(v= [-.3 - wt, -.3 - wt, -9.3 - wt]) {
        cube(size = [65.9 + 3 * wt, 90.6 + 2 * wt, wt], center = false);
    };

    difference () {
        union () {
            /* left wall */
            translate(v= [-.3 - wt, -.3 - wt, -9.3 - wt]) {
                cube(size = [wt, 90.6 + 2 * wt, 14.3 + wt], center = false);
            };
            /* middle wall */
            translate(v= [50.3, -.3 - wt, -10]) {
                cube(size = [wt, 90.6 + 2 * wt, 15], center = false);
            };
        };

        union () {
            /* slits for snappers */
            translate(v= [ -1.3 - wt, 9.3, -9.0]) {
                cube(size = [52.6 + 2 * wt, .7, 15], center = false);
            };
            translate(v= [ -1.3 - wt, 15,  -9.0]) {
                cube(size = [52.6 + 2 * wt, .7, 15], center = false);
            }
            translate(v= [ -1.3 - wt, 71.3, -9.0]) {
                cube(size = [52.6 + 2 * wt, .7, 15], center = false);
            };
            translate(v= [ -1.3 - wt, 77,  -9]) {
                cube(size = [52.6 + 2 * wt, .7, 15], center = false);
            }
        }
    };

    /* right wall */
    translate(v= [65.7 + wt, -.3 - wt, -10]) {
        cube(size = [wt, 90.6 + 2 * wt, 15], center = false);
    };

    difference() {
        union () {
            /* front wall */
            translate(v= [-.3 - wt, -.3 - wt, -10]) {
                cube(size = [65.9 + 3 * wt, wt, 15], center = false);
            };

            /* rear wall */
            translate(v= [-.3 - wt, 90.3, -10]) {
                cube(size = [65.9 + 3 * wt, wt, 15], center = false);
            };
        };
        translate(v = [30, -2.3 - wt, -9]) {
            cube(size = [6, 98.4 + 2 * wt, 5], center = false);
        }
    }
    difference () {
        /* antenna wall */
        translate(v= [50.3, 60, -10]) {
            cube(size = [15.4 + 2 * wt, wt, 15], center = false);
        };
        /* hole for antenna */
        translate(v= [58 + 1 * wt, 60, -2.5]) {
            rotate (a = 90, v = [1, 0, 0]) {
                cylinder(h = 10, d = 7, center = true);
            }
        }
    };

    translate(v= [-1, 10, 1]) {
        snapper();
        translate(v=[1, 5, -1 - 9.3])
        rotate([90, 0, 0])
        fillet(1, 5, 2 * wt);
    };

    translate(v= [-1, 72, 1]) {
        snapper();
        translate(v=[1, 5, -1 - 9.3])
        rotate([90, 0, 0])
        fillet(1, 5, 2 * wt);
    };

    translate(v= [51,  15, 1]) {
        rotate (a = 180, v = [0, 0, 1]) {
            snapper();
            translate(v=[1, 5, -1 - 9.3])
            rotate([90, 0, 0])
            fillet(1, 5, 2 * wt);
        }
    };

    translate(v= [51,  77, 1]) {
        rotate (a = 180, v = [0, 0, 1]) {
            snapper();
            translate(v=[1, 5, -1 - 9.3])
            rotate([90, 0, 0])
            fillet(1, 5, 2 * wt);
        }
    };
 
    translate(v= [10, 13, -5]) {
        support();
    };
    translate(v= [10, 75, -5]) {
        support();
    };
    translate(v= [39, 13, -5]) {
        support();
    };
    translate(v= [39, 75, -5]) {
        support();
    }
}

module top2() {
    module switchhole(x, y) {
        translate(v = [dx + 2.54 * x - sp, dy + 2.54 * y - sp, dz]) {
            cube(size = [12.7 + 2 * sp , 12.7 + 2 * sp, 20], center = false);
        }
    }

    difference () {
        /* lower top */
        translate(v= [-.3 - sp - 2 * wt, -.3 -sp - 2 * wt, 9.4 + dz - wt]) {
            cube(size = [65.9 + 2 * sp + 5 * wt, 50.6 + sp + 2 * wt, wt], center = false);
        };
        union () {
            switchhole(3, 2);
            switchhole(10, 2);
            switchhole(3, 9);
            switchhole(10, 9);
        };
    }

    /* front wall */
    translate(v= [-.3 - sp - 2 * wt, -.3 -sp - 2 * wt, -9.3 - wt]) {
        cube(size = [65.9 + 2 * sp + 5 * wt, wt, 18.7 + dz + wt], center = false);
    };

    translate(v= [30.5, -wt - sp - .7, -4 - sp]) {
            rotate (a = 180, v = [0, 1, 0]) {
        rotate (a = 90, v = [0, 0, 1]) {
                snapper();
            }
        }
    };

    translate(v= [35.5, 90.3 + wt + .7 + sp, -4 - sp]) {
            rotate (a = 180, v = [0, 1, 0]) {
        rotate (a = 270, v = [0, 0, 1]) {
                snapper();
            }
        }
    };

    /* middle wall */
    translate(v= [-.3 - sp - 2 * wt, 50.3 - wt, 5 + sp]) {
        cube(size = [65.9 + 2 * sp + 5 * wt, wt, 4.4 -sp + dz ], center = false);
    };

    /* support */
    translate(v= [-.3 - sp - 2 * wt, 5 - wt, 5 + sp]) {
        cube(size = [2 * wt + sp, wt, 4.4 -sp + dz ], center = false);
    };
    translate(v= [65.6 + wt, 5 - wt, 5 + sp]) {
        cube(size = [2 * wt + sp , wt, 4.4 -sp + dz ], center = false);
    };
    
    /* support */
    translate(v= [-.3 - sp - 2 * wt, 85.3, 5 + sp]) {
        cube(size = [2 * wt + sp, wt, 4.4 -sp + dz ], center = false);
    };
    translate(v= [65.6 + wt, 85.3, 5 + sp]) {
        cube(size = [2 * wt + sp , wt, 4.4 -sp + dz ], center = false);
    };
    
    /* rear wall */
    difference () {
        translate(v= [-.3 - sp - 2 * wt, 90.3 + wt + sp, -9.3 - wt]) {
            cube(size = [65.9 + 2 * sp + 5 * wt, wt, 18.7 + wt + dz], center = false);
        };
        translate(v = [30, -2.3 - wt, -.6 -sp + dz]) {
            cube(size = [6, 98.4 + 2 * wt, 5], center = false);
        }
    };

    /* side wall */
    difference () {
        translate(v= [-.3 - sp - 2 * wt, -.3 - 2 * wt - sp , -9.3 - wt]) {
            cube(size = [65.9 + 2 * sp + 5 * wt, 90.3 + 2 * sp + 4 * wt, 18.7 + dz + wt], center = false);
        };
        translate(v= [-.3 - sp - wt, -1.3 - 2 * wt - sp , -10 - wt]) {
            cube(size = [65.9 + 2 * sp + 3 * wt, 92.3 + 2 * sp + 4 * wt, 34 + wt], center = false);
        };
    };
}

module top1() {

    module displayhole(x, y, d) {
        translate(v= [dx - 1.27 + x * 2.54 - d, dy -1.27 + y * 2.54 - d, 14.5 ]) {
            cube(size = [13 * 2.54 + 2 * d, 8 * 2.54 + 2 * d , 30], center = false);
        }
    }
    


    intersection () {
        translate(v = [0, 0, 19.7 - wt]) {
            cube(size = [100, 100, 3 + wt], center = false);
        };
        difference () {
            displayhole(5, 24, 5 + wt);
            displayhole(5, 24, 5);
        }
    }

    difference () {
        /* upper top */
        translate(v= [-.3 - sp - 2 * wt, 50.3 - wt, 22.7 - wt]) {
            cube(size = [65.9 + 2 * sp + 5 * wt, 40 + sp + 3 * wt, wt], center = false);
        };
        displayhole(5, 24, 5);
    }
    intersection () {
        difference () {
            translate(v= [-.3 - wt, 50.6 - wt, 19.7 - wt]) {
                cube(size = [65.9 + 3 * wt, 40.6 + 3 * wt, wt], center = false);
            };
        displayhole(5, 24, 3);
            };
        displayhole(5, 24, 5 + wt);
    }

    /* middle wall */
    translate(v= [-.3 - sp - 2 * wt, 50.3 - wt, 9.4 + dz - wt]) {
        cube(size = [65.9 + 2 * sp + 5 * wt, wt, 13.3 - dz +  wt], center = false);
    };

    /* rear wall */
    translate(v= [-.3 - sp - 2 * wt, 90.3 + wt + sp, -9.3 - wt]) {
        cube(size = [65.9 + 2 * sp + 5 * wt, wt, 32 + wt], center = false);
    };

    /* side wall */
    difference () {
        translate(v= [-.3 - sp - 2 * wt, -.3 - 2 * wt - sp , -9.3 - wt]) {
            cube(size = [65.9 + 2 * sp + 5 * wt, 90.3 + 2 * sp + 4 * wt, 32 + wt], center = false);
        };
        translate(v= [-.3 - sp - wt, -1.3 - 2 * wt - sp , -10 - wt]) {
            cube(size = [65.9 + 2 * sp + 3 * wt, 92.3 + 2 * sp + 4 * wt, 34 + wt], center = false);
        };
        translate(v= [-2.3 - sp - 2 * wt, -1 -sp - 2 *  wt, 9.4 + dz]) {
            cube(size = [69.9 + 2 * sp + 5 * wt, sp + 51.3 + wt , 13.3 - dz +  wt], center = false);
        };
        
    }
}

// device( );

color(c = [.8, .3, .3]) {
    top2();
}

color(c = [.2, .5, .5]) {
    bottom();
}


