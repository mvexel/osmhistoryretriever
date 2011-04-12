//
//  BoundingBox.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "BoundingBox.h"


@implementation BoundingBox

@synthesize leftBottom, rightTop;

+(BoundingBox *)BoundingBoxWithCenterCoordinate:(Coordinate *)center andDistance:(int)meters {
	id newBBox = [[BoundingBox alloc] init];
	double latLen = [BoundingBox degreesLatDeltaFromDistance:meters*2 atLatitude:center.lat];
	double lonLen = [BoundingBox degreesLonDeltaFromDistance:meters*2 atLatitude:center.lat];
	double lonDelta = meters / lonLen;
	double latDelta = meters / latLen;
	[newBBox setLeftBottom:[Coordinate coordinateWithLongitude:(center.lon - lonDelta / 2) andLatitude:(center.lat - latDelta / 2)]];
	[newBBox setRightTop:[Coordinate coordinateWithLongitude:(center.lon + lonDelta / 2) andLatitude:(center.lat + latDelta / 2)]];
	return [newBBox autorelease];
}

+(double)degreesLatDeltaFromDistance:(int)meters atLatitude:(double)lat {
	double lat_rad = lat * (2.0 * pi) / 360;
	
	double m1 = 111132.92;		// latitude calculation term 1
	double m2 = -559.82;		// latitude calculation term 2
	double m3 = 1.175;			// latitude calculation term 3
	double m4 = -0.0023;		// latitude calculation term 4
	double latlen = m1 + (m2 * cos(2 * lat_rad)) + (m3 * cos(4 * lat_rad)) + (m4 * cos(6 * lat_rad));	
	return latlen;
}

+(double)degreesLonDeltaFromDistance:(int)meters atLatitude:(double)lat {
	double lat_rad = lat * (2.0 * pi) / 360;
	double p1 = 111412.84;		// longitude calculation term 1
	double p2 = -93.5;			// longitude calculation term 2
	double p3 = 0.118;			// longitude calculation term 3
	double longlen = (p1 * cos(lat_rad)) + (p2 * cos(3 * lat_rad)) + (p3 * cos(5 * lat_rad));
	return longlen;
}

@end
