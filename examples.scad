include <arduino.scad>

//Arduino boards
//You can create a boxed out version of a variety of boards by calling the arduino() module
//The default board for all functions is the Uno

dueDimensions = boardDimensions( DUE );
unoDimensions = boardDimensions( UNO );

//Board mockups
arduino();

translate( [unoDimensions[0] + 50, 0, 0] )
	arduino(DUE);

translate( [-(unoDimensions[0] + 50), 0, 0] )
	arduino(LEONARDO);

translate([0, 0, -75]) {
	enclosure();

	translate( [unoDimensions[0] + 50, 0, 0] )
		bumper(DUE);

	translate( [-(unoDimensions[0] + 50), 0, 0] ) union() {
		standoffs(LEONARDO, mountType=PIN);
		boardShape(LEONARDO, offset = 3);
	}
}

translate([0, 0, 75]) {
	enclosureLid();
}

translate([-140,0,0]) {
  translate([0,0,2.2]) arduino(NANO);
  translate([0,100, 0]) bumper(NANO, mountingHoles = true);
  translate([0,0,-75]) enclosure(NANO);
  translate([0,0,75]) enclosureLid(NANO);

  translate([0,100,-75]) {
    standoffs(NANO, mountType=NOTCH);
	boardShape(NANO, offset = 3);
  }
}

translate([-200,0,0]) {
  translate([0,0,2.2]) arduino(MKR_WIFI_1010);
  translate([0,100, 0]) bumper(MKR_WIFI_1010, mountingHoles = true);
  translate([0,0,-75]) enclosure(MKR_WIFI_1010, standOffHeight=10);
  translate([0,0,75]) enclosureLid(MKR_WIFI_1010);

  translate([0,100,-75]) {
    standoffs(MKR_WIFI_1010, mountType=NOTCH);
	boardShape(MKR_WIFI_1010, offset = 3);
  }
}
