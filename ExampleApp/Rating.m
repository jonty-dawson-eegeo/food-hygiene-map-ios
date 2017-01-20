#import "Rating.h"

@implementation Rating


- (id) initWithJson: (NSDictionary *) json
{
    self = [super init];
    if (self)
    {
        self.ratingId = json[@"ratingId"];
        self.ratingName = json[@"ratingName"];
        self.ratingKey = json[@"ratingKey"];
        self.ratingKeyName = json[@"ratingKeyName"];
        self.schemeTypeId = json[@"schemeTypeId"];
    }
    
    return self;
}
@end
