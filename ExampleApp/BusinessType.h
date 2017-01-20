
@interface BusinessType : NSObject

@property (nonatomic, copy) NSNumber *businessTypeId;

@property (nonatomic, copy) NSString *businessTypeName;

- (id) initWithJson: (NSDictionary *) json;

@end