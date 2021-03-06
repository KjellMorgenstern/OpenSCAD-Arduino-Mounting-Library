// Arduino connectors library
//
// Copyright (c) 2013 Kelly Egan
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
// and associated documentation files (the "Software"), to deal in the Software without restriction, 
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do 
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

use <pin_connectors/pins.scad>

//Constructs a roughed out arduino board
//Current only USB, power and headers
module arduino(boardType = UNO) {
  //The PCB with holes
  difference() {
    color("SteelBlue") 
      boardShape( boardType );
    translate([0,0,-pcbHeight * 0.5]) holePlacement(boardType = boardType)
      color("SteelBlue") cylinder(r = mountingHoleRadius[boardType], h = pcbHeight * 2, $fn=32);
  }
  //Add all components to board
  components( boardType = boardType, component = ALL );
}

//Creates a bumper style enclosure that fits tightly around the edge of the PCB.
module bumper( boardType = UNO, mountingHoles = false ) {
  bumperBaseHeight = 2;
  bumperHeight = bumperBaseHeight + pcbHeight + 0.5;
  dimensions = boardDimensions(boardType);

  difference() {
    union() {
      //Outer rim of bumper
      difference() {
        boardShape(boardType = boardType, offset=1.4, height = bumperHeight);
        translate([0,0,-0.1])
          boardShape(boardType = boardType, height = bumperHeight + 0.2);
      }

      //Base of bumper  
      difference() {
        boardShape(boardType = boardType, offset=1, height = bumperBaseHeight);
        translate([0,0, -0.1])
          boardShape(boardType = boardType, offset=-2, height = bumperHeight + 0.2);
      }

      //Board mounting holes
      holePlacement(boardType=boardType)
        cylinder(r = mountingHoleRadius[boardType] + 1.5, h = bumperBaseHeight, $fn = 32);

      //Bumper mounting holes (exterior)
      if( mountingHoles ) {
        difference() {  
          hull() {
            translate([-6, (dimensions[1] - 6) / 2, 0])
              cylinder( r = 6, h = pcbHeight + 2, $fn = 32 );
            translate([ -0.5, dimensions[1] / 2 - 9, 0])
              cube([0.5, 12, bumperHeight]);
          }
          translate([-6, (dimensions[1] - 6) / 2, 0])
            mountingHole(holeDepth = bumperHeight);
        }
        difference() {  
          hull() {
            translate([dimensions[0] + 6, (dimensions[1] - 6) / 2,0])
              cylinder( r = 6, h = pcbHeight + 2, $fn = 32 );
            translate([ dimensions[0], dimensions[1] / 2 - 9, 0]) 
              cube([0.5, 12, bumperHeight]);
          }
          translate([dimensions[0] + 6, (dimensions[1] - 6) / 2,0])
            mountingHole(holeDepth = bumperHeight);
        }
      }
    }
    translate([0,0,-0.5])
    holePlacement(boardType=boardType)
      cylinder(r = mountingHoleRadius[boardType], h = bumperHeight, $fn = 32);
    translate([0, 0, bumperBaseHeight]) {
      components(boardType = boardType, component = USB, offset = 1);
    }
    translate([0, 0, bumperBaseHeight]) {
      components(boardType = boardType, component = POWER, offset = 1);
    }
    translate([0, 0, bumperBaseHeight]) {
      components(boardType = boardType, component = RJ45, offset = 1);
    }

    // TODO : Boards are usually not flat on the downside, and pins
    // currently colide with the structure (resulting in a gap)
    //translate([0, 0, bumperBaseHeight]) {
    //  components(boardType = boardType, component = HEADER_M, offset = 0);
    //}
    //translate([0, 0, bumperBaseHeight]) {
    //  components(boardType = boardType, component = HEADER_F, offset = 0);
    //}
    // Cooling opening?
    translate([4,(dimensions[1] - dimensions[1] * 0.4)/2,-1])
      cube([dimensions[0] -8,dimensions[1] * 0.4,bumperBaseHeight + 2]);
  }
}

//Setting for enclosure mounting holes (Not Arduino mounting)
NOMOUNTINGHOLES = 0;
INTERIORMOUNTINGHOLES = 1;
EXTERIORMOUNTINGHOLES = 2;

//Create a board enclosure
module enclosure(boardType = UNO, wall = 3, offset = 3, heightExtension = 10, cornerRadius = 3, mountType = TAPHOLE, standOffHeight = 5) {
  

  dimensions = boardDimensions(boardType);
  boardDim = boardDimensions(boardType);
  pcbDim = pcbDimensions(boardType);

  enclosureWidth = pcbDim[0] + (wall + offset) * 2;
  enclosureDepth = pcbDim[1] + (wall + offset) * 2;
  enclosureHeight = boardDim[2] + wall + standOffHeight + heightExtension;

  union() {
    difference() {
      //Main box shape
      boundingBox(boardType = boardType, height = enclosureHeight, offset = wall + offset, include=PCB, cornerRadius = wall);
  
      translate([ 0, 0, wall]) {
        //Interior of box
        boundingBox(boardType = boardType, height = enclosureHeight, offset = offset, include=PCB, cornerRadius = wall);
  
        //Punch outs for USB and POWER
        translate([0, 0, standOffHeight]) {
          components(boardType = boardType, offset = 1, extension = wall + offset + 10);
        }
      }
      
      //Holes for lid clips
      translate([0, enclosureDepth * 0.75 - (offset + wall), enclosureHeight]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
        translate([offset + boardDim[0], 0, 0])
          rotate([0, 180, 270]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
      }
    
      translate([0, enclosureDepth * 0.25 - (offset + wall), enclosureHeight]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
        translate([offset + dimensions[0], 0, 0])
          rotate([0, 180, 270]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
      }   
    }
    translate([0, 0, wall]) {
      standoffs(boardType = boardType, height = standOffHeight, mountType = mountType);
    }
  }
}

//Create a snap on lid for enclosure
module enclosureLid( boardType = UNO, wall = 3, offset = 3, cornerRadius = 3, ventHoles = false) {
  dimensions = boardDimensions(boardType);
  boardDim = boardDimensions(boardType);
  pcbDim = pcbDimensions(boardType);

  enclosureWidth = pcbDim[0] + (wall + offset) * 2;
  enclosureDepth = pcbDim[1] + (wall + offset) * 2;

  difference() {
    union() {
      boundingBox(boardType = boardType, height = wall, offset = wall + offset, include=PCB, cornerRadius = wall);

      translate([0, 0, -wall * 0.5])
        boundingBox(boardType = boardType, height = wall * 0.5, offset = offset - 0.5, include=PCB, cornerRadius = wall);
    
      //Lid clips
      translate([0, enclosureDepth * 0.75 - (offset + wall), 0]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clip(clipHeight = 10);
        translate([offset + boardDim[0], 0, 0])
          rotate([0, 180, 270]) clip(clipHeight = 10);
      }
    
      translate([0, enclosureDepth * 0.25 - (offset + wall), 0]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clip(clipHeight = 10);
        translate([offset + dimensions[0], 0, 0])
          rotate([0, 180, 270]) clip(clipHeight = 10);
      }

    }
  }
}

//Offset from board. Negative values are insets
module boardShape( boardType = UNO, offset = 0, height = pcbHeight ) {
  dimensions = boardDimensions(boardType);

  xScale = (dimensions[0] + offset * 2) / dimensions[0];
  yScale = (dimensions[1] + offset * 2) / dimensions[1];

  translate([-offset, -offset, 0])
    scale([xScale, yScale, 1.0])
      linear_extrude(height = height) 
        polygon(points = boardShapes[boardType]);
}

//Create a bounding box around the board
//Offset - will increase the size of the box on each side,
//Height - overrides the boardHeight and offset in the z direction

BOARD = 0;        //Includes all components and PCB
PCB = 1;          //Just the PCB
COMPONENTS = 2;   //Just the components

module boundingBox(boardType = UNO, offset = 0, height = 0, cornerRadius = 0, include = BOARD) {
  //What parts are included? Entire board, pcb or just components.
  pos = ([boardPosition(boardType), pcbPosition(boardType), componentsPosition(boardType)])[include];
  dim = ([boardDimensions(boardType), pcbDimensions(boardType), componentsDimensions(boardType)])[include];

  //Depending on if height is set position and dimensions will change
  position = [
        pos[0] - offset, 
        pos[1] - offset, 
        (height == 0 ? pos[2] - offset : pos[2] )
        ];

  dimensions = [
        dim[0] + offset * 2, 
        dim[1] + offset * 2, 
        (height == 0 ? dim[2] + offset * 2 : height)
        ];

  translate( position ) {
    if( cornerRadius == 0 ) {
      cube( dimensions );
    } else {
      roundedCube( dimensions, cornerRadius=cornerRadius );
    }
  }
}

//Creates standoffs for different boards
TAPHOLE = 0;
PIN = 1;
NOTCH = 2;  // Recommended for small radius (< 1.5mm) on FDM printers.

module standoffs(
  boardType = UNO,
  height = 10,
  mountType = TAPHOLE
  ) {

  topRadius = mountingHoleRadius[boardType] + 1;
  bottomRadius =  mountingHoleRadius[boardType] + 2;
  holeRadius = mountingHoleRadius[boardType];

  holePlacement(boardType = boardType)
    union() {
      difference() {
        cylinder(r1 = bottomRadius, r2 = topRadius, h = height, $fn=32);
        if( mountType == TAPHOLE ) {
          cylinder(r =  holeRadius, h = height * 4, center = true, $fn=32);
        }
      }
      if( mountType == PIN ) {
        translate([0, 0, height -1])
        pintack( h=pcbHeight + 3, r = holeRadius, lh=3, lt=1, bh=1, br=topRadius );
      }
      if( mountType == NOTCH ) {
        $fn = 16;
        translate([0, 0, height]) {
          cylinder(r= holeRadius *0.9 , h=pcbHeight+0.1);
          translate([0, 0, pcbHeight+0.1]) cylinder(r1 = holeRadius + 0.15, r2 = holeRadius * 0.7, h=0.8);
        }
      }
    }
}

//This is used for placing the mounting holes and for making standoffs
//child elements will be centered on that chosen boards mounting hole centers
module holePlacement(boardType = UNO ) {
  for(i = boardHoles[boardType] ) {
    translate(i)
      children(0);
  }
}

//Places components on board
//  compenent - the data set with a particular component (like boardHeaders)
//  extend - the amount to extend the component in the direction of its socket
//  offset - the amount to increase the components other two boundaries

//Component IDs
ALL = -1;
HEADER_F = 0;
HEADER_M = 1;
USB = 2;
POWER = 3;
RJ45 = 4;
HEADER_BI = 5;

module header(dimensions, headerType ) {
  // zb : height of plastic part of the header: 2.54 for male
  // zg : height of pin below the board.
  zb = headerType==HEADER_M?2.54:dimensions[2];
  zg = headerType==HEADER_BI?dimensions[2]:0.8+pcbHeight;

  color("black") cube( [dimensions[0],dimensions[1],zb] );
  for (m = [0:dimensions[0]/2.54 -1]) {
    for (n = [0:dimensions[1]/2.54 -1]) {
      translate([0.95 + m*2.54, 0.95 + n*2.54, -zg-0.01]) color("yellow") cube([0.64, 0.64,dimensions[2] + zg] );
    }
  }
}

module components( boardType = UNO, component = ALL, extension = 0, offset = 0 ) {
  translate([0, 0, pcbHeight]) {
    for( i = [0:len(components[boardType]) - 1] ){
      if( components[boardType][i][3] == component || component == ALL) {
          //Calculates position + adjustment for offset and extention  
          position = components[boardType][i][0] 
            - (([1,1,1] - components[boardType][i][2]) * offset)
            + [  min(components[boardType][i][2][0],0), min(components[boardType][i][2][1],0), min(components[boardType][i][2][2],0) ] 
            * extension;
          //Calculates the full box size including offset and extention
          dimensions = components[boardType][i][1] 
            + ((components[boardType][i][2] * [1,1,1]) 
              * components[boardType][i][2]) * extension
            + ([1,1,1] - components[boardType][i][2]) * offset * 2;        
          translate( position )
            if(components[boardType][i][3] == HEADER_M || components[boardType][i][3] == HEADER_F || components[boardType][i][3] == HEADER_BI) {
              header(dimensions, components[boardType][i][3]);
            } else {
             color( components[boardType][i][4] ) cube( dimensions );
            }
      }
    }
  }
}

module roundedCube( dimensions = [10,10,10], cornerRadius = 1, faces=32 ) {
  hull() cornerCylinders( dimensions = dimensions, cornerRadius = cornerRadius, faces=faces ); 
}

module cornerCylinders( dimensions = [10,10,10], cornerRadius = 1, faces=32 ) {
  translate([ cornerRadius, cornerRadius, 0]) {
    cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
    translate([dimensions[0] - cornerRadius * 2, 0, 0]) cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
    translate([0, dimensions[1] - cornerRadius * 2, 0]) {
      cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
      translate([dimensions[0] - cornerRadius * 2, 0, 0]) cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
    }
  }
}

//Create a clip that snapps into a clipHole
module clip(clipWidth = 5, clipDepth = 5, clipHeight = 5, lipDepth = 1.5, lipHeight = 3) {
  translate([-clipWidth/2,-(clipDepth-lipDepth),0]) rotate([90, 0, 90])
  linear_extrude(height = clipWidth, convexity = 10)
    polygon(  points=[  [0, 0], 
            [clipDepth - lipDepth, 0],
            [clipDepth - lipDepth, clipHeight - lipHeight],
            [clipDepth - 0.25, clipHeight - lipHeight],
            [clipDepth, clipHeight - lipHeight + 0.25],
            [clipDepth - lipDepth * 0.8, clipHeight],
            [(clipDepth - lipDepth) * 0.3, clipHeight] 
            ], 
        paths=[[0,1,2,3,4,5,6,7]]
      );
}

//Hole for clip
module clipHole(clipWidth = 5, clipDepth = 5, clipHeight = 5, lipDepth = 1.5, lipHeight = 3, holeDepth = 5) {
  offset = 0.1;
  translate([-clipWidth/2,-(clipDepth-lipDepth),0])
  translate([-offset, clipDepth - lipDepth-offset, clipHeight - lipHeight - offset])
    cube( [clipWidth + offset * 2, holeDepth, lipHeight + offset * 2] );
}

module mountingHole(screwHeadRad = woodscrewHeadRad, screwThreadRad = woodscrewThreadRad, screwHeadHeight = woodscrewHeadHeight, holeDepth = 10) {
  union() {
    translate([0, 0, -0.01])
      cylinder( r = screwThreadRad, h = 1.02, $fn = 32 );
    translate([0, 0, 1])
      cylinder( r1 = screwThreadRad, r2 = screwHeadRad, h = screwHeadHeight, $fn = 32 );
    translate([0, 0, screwHeadHeight - 0.01 + 1])
      cylinder( r = screwHeadRad, h = holeDepth - screwHeadHeight + 0.02, $fn = 32 );
  }
}

/******************************** UTILITY FUNCTIONS *******************************/

//Return the length side of a square given its diagonal
function sides( diagonal ) = sqrt(diagonal * diagonal  / 2);

//Return the minimum values between two vectors of either length 2 or 3. 2D Vectors are treated as 3D vectors who final value is 0.
function minVec( vector1, vector2 ) =
  [min(vector1[0], vector2[0]), min(vector1[1], vector2[1]), min((vector1[2] == undef ? 0 : vector1[2]), (vector2[2] == undef ? 0 : vector2[2]) )];

//Return the maximum values between two vectors of either length 2 or 3. 2D Vectors are treated as 3D vectors who final value is 0.
function maxVec( vector1, vector2 ) =
  [max(vector1[0], vector2[0]), max(vector1[1], vector2[1]), max((vector1[2] == undef ? 0 : vector1[2]), (vector2[2] == undef ? 0 : vector2[2]) )];

//Determine the minimum point on a component in a list of components
function minCompPoint( list, index = 0, minimum = [10000000, 10000000, 10000000] ) = 
  index >= len(list) ? minimum : minCompPoint( list, index + 1, minVec( minimum, list[index][0] ));

//Determine the maximum point on a component in a list of components
function maxCompPoint( list, index = 0, maximum = [-10000000, -10000000, -10000000] ) = 
  index >= len(list) ? maximum : maxCompPoint( list, index + 1, maxVec( maximum, list[index][0] + list[index][1]));

//Determine the minimum point in a list of points
function minPoint( list, index = 0, minimum = [10000000, 10000000, 10000000] ) = 
  index >= len(list) ? minimum : minPoint( list, index + 1, minVec( minimum, list[index] ));

//Determine the maximum point in a list of points
function maxPoint( list, index = 0, maximum = [-10000000, -10000000, -10000000] ) = 
  index >= len(list) ? maximum : maxPoint( list, index + 1, maxVec( maximum, list[index] ));

//Returns the pcb position and dimensions
function pcbPosition(boardType = UNO) = minPoint(boardShapes[boardType]);
function pcbDimensions(boardType = UNO) = maxPoint(boardShapes[boardType]) - minPoint(boardShapes[boardType]) + [0, 0, pcbHeight];

//Returns the position of the box containing all components and its dimensions
function componentsPosition(boardType = UNO) = minCompPoint(components[boardType]) + [0, 0, pcbHeight];
function componentsDimensions(boardType = UNO) = maxCompPoint(components[boardType]) - minCompPoint(components[boardType]);

//Returns the position and dimensions of the box containing the pcb board
function boardPosition(boardType = UNO) = 
  minCompPoint([[pcbPosition(boardType), pcbDimensions(boardType)], [componentsPosition(boardType), componentsDimensions(boardType)]]);
function boardDimensions(boardType = UNO) = 
  maxCompPoint([[pcbPosition(boardType), pcbDimensions(boardType)], [componentsPosition(boardType), componentsDimensions(boardType)]]) 
  - minCompPoint([[pcbPosition(boardType), pcbDimensions(boardType)], [componentsPosition(boardType), componentsDimensions(boardType)]]);

/******************************* BOARD SPECIFIC DATA ******************************/
//Board IDs
NG = 0;
DIECIMILA = 1;
DUEMILANOVE = 2;
UNO = 3;
LEONARDO = 4;
MEGA = 5;
MEGA2560 = 6;
DUE = 7;
YUN = 8; 
INTELGALILEO = 9;
TRE = 10;
ETHERNET = 11;
NANO = 12;
MKR_WIFI_1010 = 13;

/********************************** MEASUREMENTS **********************************/
pcbHeight = 1.7;
headerWidth = 2.54;
headerHeight = 9;

ngWidth = 53.34;
leonardoDepth = 68.58 + 1.1;           //PCB depth plus offset of USB jack (1.1)
ngDepth = 68.58 + 6.5;
megaDepth = 101.6 + 6.5;               //Coding is my business and business is good!
dueDepth = 101.6 + 1.1;

arduinoHeight = 11 + pcbHeight + 0;

/********************************* MOUNTING HOLES *********************************/

//Duemilanove, Diecimila, NG and earlier
ngHoles = [
  [  2.54, 15.24 ],
  [  17.78, 66.04 ],
  [  45.72, 66.04 ]
  ];

//Uno, Leonardo holes
unoHoles = [
  [  2.54, 15.24 ],
  [  17.78, 66.04 ],
  [  45.72, 66.04 ],
  [  50.8, 13.97 ]
  ];

//Due and Mega 2560
dueHoles = [
  [  2.54, 15.24 ],
  [  17.78, 66.04 ],
  [  45.72, 66.04 ],
  [  50.8, 13.97 ],
  [  2.54, 90.17 ],
  [  50.8, 96.52 ]
  ];

// Original Mega holes
megaHoles = [
  [  2.54, 15.24 ],
  [  50.8, 13.97 ],
  [  2.54, 90.17 ],
  [  50.8, 96.52 ]
  ];

// Original nano holes
nanoHoles = [
  [  1.27, 1.27 ],
  [  1.27, 41.91 ],
  [  16.51, 41.91 ],
  [  16.51, 1.27 ]
  ];

mkrHoles = [
  [ 2.2, 2.2],
  [ 22.8, 2.2],
  [ 2.2, 59.3],
  [ 22.8, 59.3]
  ];

boardHoles = [ 
  ngHoles,        //NG
  ngHoles,        //Diecimila
  ngHoles,        //Duemilanove
  unoHoles,       //Uno
  unoHoles,       //Leonardo
  megaHoles,      //Mega
  dueHoles,       //Mega 2560
  dueHoles,       //Due
  0,              //Yun
  0,              //Intel Galileo
  0,              //Tre
  unoHoles,       //Ethernet
  nanoHoles,      //Nano
  mkrHoles        //MKR WIFI 1010
  ];

mountingHoleRadius = [
  1.6,        //NG
  1.6,        //Diecimila
  1.6,        //Duemilanove
  1.6,        //Uno
  1.6,        //Leonardo
  1.6,        //Mega
  1.6,        //Mega 2560
  1.6,        //Due
  1.6,        //Yun
  1.6,        //Intel Galileo
  1.6,        //Tre
  1.6,        //Ethernet
  0.92,       //Nano
  1.2         //MKR WIFI 1010
  ];

/********************************** BOARD SHAPES **********************************/
ngBoardShape = [ 
  [  0.0, 0.0 ],
  [  53.34, 0.0 ],
  [  53.34, 66.04 ],
  [  50.8, 66.04 ],
  [  48.26, 68.58 ],
  [  15.24, 68.58 ],
  [  12.7, 66.04 ],
  [  1.27, 66.04 ],
  [  0.0, 64.77 ]
  ];

megaBoardShape = [ 
  [  0.0, 0.0 ],
  [  53.34, 0.0 ],
  [  53.34, 99.06 ],
  [  52.07, 99.06 ],
  [  49.53, 101.6 ],
  [  15.24, 101.6 ],
  [  12.7, 99.06 ],
  [  2.54, 99.06 ],
  [  0.0, 96.52 ]
  ];

 nanoBoardShape = [
  [  0.0, 0.0 ],
  [  17.78, 0.0 ],
  [  17.78, 43.18 ],
  [  0.0, 43.18]
  ];

 mkr_wifi_1010BoardShape = [
  [  0.0, 0.0 ],
  [  25.0, 0.0 ],
  [  25.0, 61.5 ],
  [  0.0, 61.5]
  ];

boardShapes = [   
  ngBoardShape,   //NG
  ngBoardShape,   //Diecimila
  ngBoardShape,   //Duemilanove
  ngBoardShape,   //Uno
  ngBoardShape,   //Leonardo
  megaBoardShape, //Mega
  megaBoardShape, //Mega 2560
  megaBoardShape, //Due
  0,              //Yun
  0,              //Intel Galileo
  0,              //Tre
  ngBoardShape,   //Ethernet
  nanoBoardShape, //Nano
  mkr_wifi_1010BoardShape  //MKR WIFI 1010
  ];  

/*********************************** COMPONENTS ***********************************/

//Component data. 
//[position, dimensions, direction(which way would a cable attach), type(header, usb, etc.), color]
ngComponents = [
  [[1.27, 17.526, 0], [headerWidth, headerWidth * 10, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[1.27, 44.45, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 26.67, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 49.53, 0], [headerWidth, headerWidth * 6, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[9.34, -6.5, 0],[12, 16, 11],[0, -1, 0], USB, "LightGray" ],
  [[40.7, -1.8, 0], [9.0, 13.2, 10.9], [0, -1, 0], POWER, "Black" ]
  ];

etherComponents = [
  [[1.27, 17.526, 0], [headerWidth, headerWidth * 10, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[1.27, 44.45, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 26.67, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 49.53, 0], [headerWidth, headerWidth * 6, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[7.20, -4.4, 0],[16, 22, 13],[0, -1, 0], RJ45, "Green" ],
  [[40.7, -1.8, 0], [9.0, 13.2, 10.9], [0, -1, 0], POWER, "Black" ]
  ];

leonardoComponents = [
  [[1.27, 17.526, 0], [headerWidth, headerWidth * 10, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[1.27, 44.45, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 26.67, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 49.53, 0], [headerWidth, headerWidth * 6, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[11.5, -1.1, 0],[7.5, 5.9, 3],[0, -1, 0], USB, "LightGray" ],
  [[40.7, -1.8, 0], [9.0, 13.2, 10.9], [0, -1, 0], POWER, "Black" ]
  ];

megaComponents = [
  [[1.27, 22.86, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[1.27, 44.45, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[1.27, 67.31, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[49.53, 31.75, 0], [headerWidth, headerWidth * 6, headerHeight ], [0, 0, 1], HEADER_F, "Black"],
  [[49.53, 49.53, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[49.53, 72.39, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[1.27, 92.71, 0], [headerWidth * 18, headerWidth * 2, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[9.34, -6.5, 0],[12, 16, 11],[0, -1, 0], USB, "LightGray"],
  [[40.7, -1.8, 0], [9.0, 13.2, 10.9], [0, -1, 0], POWER, "Black" ]
  ];

mega2560Components = [
  [[1.27, 17.526, 0], [headerWidth, headerWidth * 10, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[1.27, 44.45, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[1.27, 67.31, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 26.67, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 49.53, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[49.53, 72.39, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[1.27, 92.71, 0], [headerWidth * 18, headerWidth * 2, headerHeight], [0, 0, 1], HEADER_F, "Black" ],
  [[9.34, -6.5, 0],[12, 16, 11],[0, -1, 0], USB, "LightGray" ],
  [[40.7, -1.8, 0], [9.0, 13.2, 10.9], [0, -1, 0], POWER, "Black" ]
  ];

dueComponents = [
  [[1.27, 17.526, 0], [headerWidth, headerWidth * 10, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[1.27, 44.45, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[1.27, 67.31, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[49.53, 26.67, 0], [headerWidth, headerWidth * 8, headerHeight ], [0, 0, 1], HEADER_F, "Black"],
  [[49.53, 49.53, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[49.53, 72.39, 0], [headerWidth, headerWidth * 8, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[1.27, 92.71, 0], [headerWidth * 18, headerWidth * 2, headerHeight], [0, 0, 1], HEADER_F, "Black"],
  [[11.5, -1.1, 0], [7.5, 5.9, 3], [0, -1, 0], USB, "LightGray" ],
  [[27.365, -1.1, 0], [7.5, 5.9, 3], [0, -1, 0], USB, "LightGray" ],
  [[40.7, -1.8, 0], [9.0, 13.2, 10.9], [0, -1, 0], POWER, "Black" ]
  ];

nanoComponents = [
  [[0, 2.54, 0], [headerWidth, headerWidth * 15, headerHeight], [0, 0, 1], HEADER_M, "Black"],
  [[15.24, 2.54, 0], [headerWidth, headerWidth * 15, headerHeight], [0, 0, 1], HEADER_M, "Black"],
  [[4.9, -1.1, 0], [8, 9, 3], [0, -1, 0], USB, "LightGray" ],
  ];

mkr_wifi_1010Components = [
  [[1, 20.5, 0], [headerWidth, headerWidth * 14, headerHeight], [0, 0, 1], HEADER_BI, "Black"],
  [[21.46, 20.5, 0], [headerWidth, headerWidth * 14, headerHeight], [0, 0, 1], HEADER_BI, "Black"],
  [[9.5, -1.1, 0], [8, 6, 3], [0, -1, 0], USB, "LightGray" ],
  [[19, 11.25, 0], [6.0, 8, 5.25], [1, 0, 0], POWER, "White" ]
  ];


components = [
  ngComponents,         //NG
  ngComponents,         //Diecimila
  ngComponents,         //Duemilanove
  ngComponents,         //Uno
  leonardoComponents,   //Leonardo
  megaComponents,       //Mega
  mega2560Components,   //Mega 2560
  dueComponents,        //Due
  0,                    //Yun
  0,                    //Intel Galileo
  0,                    //Tre
  etherComponents,      //Ethernet
  nanoComponents,       //Nano
  mkr_wifi_1010Components //MKR WIFI 1010
  ];

/****************************** NON-BOARD PARAMETERS ******************************/

//Mounting holes
woodscrewHeadRad = 4.6228;  //Number 8 wood screw head radius
woodscrewThreadRad = 2.1336;    //Number 8 wood screw thread radius
woodscrewHeadHeight = 2.8448;  //Number 8 wood screw head height
