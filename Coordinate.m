//
//  Coordinate.m
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import "Coordinate.h"


@implementation Coordinate

@synthesize lon,lat;

-(NSString *)description {
	return [NSString stringWithFormat:@"%.5f,%.5f",lon,lat];
}

+(Coordinate *)coordinateWithLongitude:(double)lon andLatitude:(double)lat {
	id newCoord = [[Coordinate alloc] init];
	[newCoord setLon:lon];
	[newCoord setLat:lat];
	return [newCoord autorelease];
}

@end
