#import "BusinessType.h"

@implementation BusinessType

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (ID: %@)", self.businessTypeName, self.businessTypeId];
}


- (id) initWithJson: (NSDictionary *) json
{
    self = [super init];
    if (self)
    {
        self.businessTypeId = json[@"BusinessTypeId"];
        self.businessTypeName = json[@"BusinessTypeName"];
    }
    
    return self;
}
@end