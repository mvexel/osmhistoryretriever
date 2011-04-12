//
//  BoundingBox.h
//  OSMHistoryRetriever
//
//  Created by Martijn van Exel on 13-07-10.
//  Copyright 2010 Geodan S&R. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Coordinate.h"

@interface BoundingBox : NSObject {
	Coordinate *leftBottom;
	Coordinate *rightTop;
}

@property (nonatomic,retain) Coordinate *leftBottom;
@property (nonatomic,retain) Coordinate *rightTop;

+(BoundingBox *)BoundingBoxWithCenterCoordinate:(Coordinate *)center andDistance:(int)meters;
+(double)degreesLatDeltaFromDistance:(int)meters atLatitude:(double)lat;
+(double)degreesLonDeltaFromDistance:(int)meters atLatitude:(double)lat;


@end
