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
        self.ratingName = [Establishment ratingNameFromValue:_ratingValue withSchemeType: _schemeType];
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
        
        self.iconName = [Establishment iconNameFromBusinessTypeId: _businessTypeID];
        self.title = _businessName;
        self.subtitle = _ratingName;
    }
    
    return self;
}


+(NSString*) ratingNameFromValue:(NSString*) ratingValue withSchemeType:(NSString*) schemeType
{
    // not available through Rating api results, values here taken from text in ratings images
    NSDictionary *ratingNameLookup = @{
                                       @"0": @"Urgent Improvement Necessary",
                                       @"1": @"Major Improvement Necessary",
                                       @"2": @"Improvement Necessary",
                                       @"3": @"Generally Satisfactory",
                                       @"4": @"Good",
                                       @"5": @"Very Good"
                                       };
    
    
    if ([schemeType isEqual: @"FHRS"])
    {
        NSString* name = ratingNameLookup[ratingValue];
        if (name)
        {
            return name;
        }
        else
        {
            return [NSString stringWithFormat:@"Rating: %@", ratingValue];
        }
    }
    else
    {
        return ratingValue;
    }
}

+(NSString*) iconNameFromBusinessTypeId:(NSNumber*) businessTypeId
{
    NSDictionary *iconNameLookup = @{
                                       @7: @"icon1_transport", // Distributors/Transporters
                                       @7838: @"icon1_farm",    // Farmers/growers
                                       @5: @"icon1_health",    // Hospitals/Childcare/Caring Premises
                                       @7842: @"icon1_bed_breakfast",    // Hotel/bed & breakfast/guest house
                                       @14: @"icon1_misc",    //  Importers/Exporters
                                       @7839: @"icon1_misc",    // Manufacturers/packers
                                       @7846: @"icon1_burgers",    // Mobile caterer
                                       @7841: @"icon1_misc",    // Other catering premises
                                       @7843: @"icon1_cocktail",    // Pub/bar/nightclub
                                       @1: @"icon1_food_drink",    // Restaurant/Cafe/Canteen
                                       @4613: @"icon1_groceries",    // Retailers - other
                                       @7840: @"icon1_groceries",    // Retailers - supermarkets/hypermarkets
                                       @7845: @"icon1_education",    // School/college/university
                                       @7844: @"icon1_pizza"    // Takeaway/sandwich shop

                                       };
    NSString* name = iconNameLookup[businessTypeId];
    return name;
}

@end