#import "FoodStandardsApi.h"

@implementation FoodStandardsApi

const NSString* apiBaseUrl = @"http://api.ratings.food.gov.uk/";

+ (FoodStandardsApi *) sharedInstance
{
    static dispatch_once_t oneTimeInit = 0;
    __strong static FoodStandardsApi * _sharedObject = nil;
    dispatch_once(&oneTimeInit, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

NSURLRequest* buildApiRequest(NSURL *url)
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest addValue:@"2" forHTTPHeaderField:@"x-api-version"];
    
    request = [mutableRequest copy];
    
    NSLog(@"%@", request.allHTTPHeaderFields);
    return request;
}



- (void) fetchEstablishmentsAroundLocation: (CLLocationCoordinate2D) location withMaxRadiusMiles:(int) maxRadiusMiles andExecuteBlock: ( void (^) (BOOL success, NSArray * entries) ) block
{
    NSURL * url = [self composeEstablishmentsAroundLocationURL:location withMaxRadiusMiles:maxRadiusMiles];
   
    [self fetchEntriesForUrl:url withKey:@"establishments" andExecuteBlock:block];
}

- (void) fetchEntriesForUrl:(NSURL *) url withKey:entityKey andExecuteBlock:( void (^) (BOOL success, NSArray * entries) ) block
{
    NSURLRequest * urlRequest = buildApiRequest(url);
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * responseDict = (NSDictionary *) responseObject;
            NSArray *entities = [responseDict objectForKey:entityKey];
            if (entities && ([entities isKindOfClass:[NSArray class]]))
            {
                
                block(YES, entities);
            }
            else
            {
                block(NO, nil);
            }
        }
        else
        {
            block(NO, nil);
        }
    }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         block(NO, nil);
     }];
    [requestOperation start];
}

- (void) fetchRatings: ( void (^) (BOOL success, NSArray * entries) ) block
{
    NSURL * url = [self composeRatingsURL];
    
    [self fetchEntriesForUrl:url withKey:@"ratings" andExecuteBlock:block];
}

- (void) fetchAuthorities: ( void (^) (BOOL success, NSArray * entries) ) block
{
    NSURL * url = [self composeAuthoritiesURL];
    
    [self fetchEntriesForUrl:url withKey:@"authorities" andExecuteBlock:block];
}

- (void) fetchBusinessTypes: ( void (^) (BOOL success, NSArray * entries) ) block
{
    NSURL * url = [self composeBusinessTypesURL];
    
    [self fetchEntriesForUrl:url withKey:@"businessTypes" andExecuteBlock:block];
}

- (NSURL*) composeEstablishmentsAroundLocationURL: (CLLocationCoordinate2D) location withMaxRadiusMiles:(int) maxRadiusMiles
{
    NSString *const endpoint = [NSString stringWithFormat:@"%@%@", apiBaseUrl, @"Establishments"];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:endpoint];
    
    NSURLQueryItem *latitude = [NSURLQueryItem queryItemWithName:@"latitude" value:[[NSNumber numberWithDouble:location.latitude] stringValue]];
    NSURLQueryItem *longitude = [NSURLQueryItem queryItemWithName:@"longitude" value:[[NSNumber numberWithDouble:location.longitude] stringValue]];
    //NSURLQueryItem *maxDistanceLimit = [NSURLQueryItem queryItemWithName:@"maxDistanceLimit" value:maxRadiusMiles];
    // maxDistanceLimit appears to only accept integers in miles
    NSURLQueryItem *maxDistanceLimit = [NSURLQueryItem queryItemWithName:@"maxDistanceLimit" value:[[NSNumber numberWithInt:maxRadiusMiles] stringValue]];
    // sortOptionKey param doesn't appear to be working
    //NSURLQueryItem *sortOptionKey = [NSURLQueryItem queryItemWithName:@"sortOptionKey" value:@"Distance"];
    //NSURLQueryItem *pageNumber = [NSURLQueryItem queryItemWithName:@"pageNumber" value:@"0"];
    //NSURLQueryItem *pageSize = [NSURLQueryItem queryItemWithName:@"pageSize" value:@"20"];
    
    //components.queryItems = @[ latitude, longitude, maxDistanceLimit, sortOptionKey, pageNumber, pageSize ];
    //components.queryItems = @[ latitude, longitude, maxDistanceLimit, pageSize ];
    
    components.queryItems = @[ latitude, longitude, maxDistanceLimit ];
    
    NSURL *url = components.URL;
    
    NSLog(@"%@", url);
    return url;
}


- (NSURL*) composeRatingsURL
{
    NSString *const endpoint = [NSString stringWithFormat:@"%@%@", apiBaseUrl, @"Ratings"];
    return [NSURL URLWithString:endpoint];
}

- (NSURL*) composeBusinessTypesURL
{
    NSString *const endpoint = [NSString stringWithFormat:@"%@%@", apiBaseUrl, @"BusinessTypes/basic"];
    return [NSURL URLWithString:endpoint];
}

- (NSURL*) composeAuthoritiesURL
{
    NSString *const endpoint = [NSString stringWithFormat:@"%@%@", apiBaseUrl, @"Authorities"];
    return [NSURL URLWithString:endpoint];
}

@end
