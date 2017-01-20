#import "Establishment.h"
#import <Foundation/Foundation.h>

@implementation Establishment

- (id) initWithJson: (NSDictionary *) json
{
    self = [super init];
    if (self)
    {
        self.foodHygieneRatingSchemeID = json[@"FHRSID"];
        self.localAuthorityBusinessID = json[@"LocalAuthorityBusinessID"];
        self.businessName = json[@"BusinessName"];
        
        self.businessType = json[@"BusinessType"];
        self.businessTypeID = json[@"BusinessTypeID"];
        self.schemeType = json[@"SchemeType"];
        self.ratingValue = json[@"RatingValue"];
        self.ratingKey = json[@"RatingKey"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        
        NSString *dateString = json[@"RatingDate"];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        self.ratingDate = [dateFormatter dateFromString:dateString];
        NSDictionary* geocode = [json objectForKey:@"geocode"];
        if (geocode && ([geocode isKindOfClass:[NSDictionary class]]))
        {
            double latitude = [[geocode objectForKey:@"latitude"] doubleValue];
            double longitude = [[geocode objectForKey:@"longitude"] doubleValue];
            self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        }
        
        self.localAuthorityCode = json[@"LocalAuthorityCode"];
        self.localAuthorityName = json[@"LocalAuthorityName"];
        
        self.title = _businessName;
        self.subtitle = _ratingValue;

    }
    
    return self;
}

@end