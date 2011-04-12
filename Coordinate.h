//
//  Coordinate.h
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Coordinate : NSObject {
	double lon;
	double lat;
}

@property (nonatomic) double lon;
@property (nonatomic) double lat;

+(Coordinate *)coordinateWithLongitude:(double)lon andLatitude:(double)lat;

@end
