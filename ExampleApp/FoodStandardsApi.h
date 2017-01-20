#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>


@interface FoodStandardsApi : NSObject

+ (FoodStandardsApi *) sharedInstance;

- (void) fetchEstablishmentsAroundLocation: (CLLocationCoordinate2D) location withMaxRadiusMiles:(int) maxRadiusMiles andExecuteBlock: ( void (^) (BOOL success, NSArray * entries) ) block;

- (void) fetchRatings: ( void (^) (BOOL success, NSArray * entries) ) block;

- (void) fetchAuthorities: ( void (^) (BOOL success, NSArray * entries) ) block;

- (void) fetchBusinessTypes: ( void (^) (BOOL success, NSArray * entries) ) block;

@end