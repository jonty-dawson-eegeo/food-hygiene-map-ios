#import "EGPointAnnotation.h"
#import <CoreLocation/CLLocation.h>

@interface Establishment : EGPointAnnotation

@property (nonatomic, copy) NSNumber *foodHygieneRatingSchemeID;

@property (nonatomic, copy) NSString *localAuthorityBusinessID;

@property (nonatomic, copy) NSString *businessName;

@property (nonatomic, copy) NSString *businessType;

@property (nonatomic, copy) NSNumber *businessTypeID;

@property (nonatomic, copy) NSString *schemeType; // "FHIS" in Scotland or "FHRS" elsewhere in UK

@property (nonatomic, copy) NSString *ratingValue;

@property (nonatomic, copy) NSString *ratingKey;

@property (nonatomic, copy) NSString *ratingName;

@property (nonatomic, copy) NSDate *ratingDate;

//@property (nonatomic) CLLocationCoordinate2D location;

@property (nonatomic, copy) NSNumber *localAuthorityCode;

@property (nonatomic, copy) NSString *localAuthorityName;

@property (nonatomic, copy) NSString *iconName;



- (id) initWithJson: (NSDictionary *) json;

@end