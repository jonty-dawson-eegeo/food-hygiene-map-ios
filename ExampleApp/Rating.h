
@interface Rating : NSObject

@property (nonatomic, copy) NSNumber *ratingId;

@property (nonatomic, copy) NSString *ratingName;

@property (nonatomic, copy) NSString *ratingKey;

@property (nonatomic, copy) NSString *ratingKeyName;

@property (nonatomic, copy) NSNumber *schemeTypeId;



- (id) initWithJson: (NSDictionary *) json;

@end