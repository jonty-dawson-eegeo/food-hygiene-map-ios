// Copyright eeGeo Ltd (2012-2014), All Rights Reserved

#import "EegeoMapsContainerViewController.h"
#import "EGApi.h"
#import "EegeoCustomAnnotationView.h"
#import "FoodStandardsApi.h"
#import "BusinessType.h"
#import "Establishment.h"

@import CoreLocation;

@interface EegeoMapsContainerViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@interface EegeoMapsContainerViewController () <EGMapDelegate>
@property (strong, nonatomic) id<EGMapApi> eegeoMapApi;
@end

@interface EegeoMapsContainerViewController ()
@property (strong, nonatomic) EGMapView* eegeoMapView;

@property (nonatomic, strong) NSArray * ratings;

@property (nonatomic, strong) NSArray * businessTypes;

@property (nonatomic, strong) NSArray * authorities;

@property (nonatomic, strong) NSArray * establishments;

@property (strong, nonatomic) id<EGPolygon> geoFencePoly;

@end


@implementation EegeoMapsContainerViewController
{
    bool m_mapMode;
    CLLocationCoordinate2D m_homeLocation;
    double m_homeDist;
//    UITapGestureRecognizer* m_gestureTap;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eegeoMapApi = nil;
    self.geoFencePoly = nil;
    
    m_mapMode = false;
    m_homeLocation = CLLocationCoordinate2DMake(56.459930, -2.978064);
    m_homeDist = 2000.0;
    
    self.eegeoMapView = [[[EGMapView alloc] initWithFrame:self.view.bounds] autorelease];
    self.eegeoMapView.eegeoMapDelegate = self;
    self.eegeoMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view insertSubview:self.eegeoMapView atIndex:0];
    
    //[self fetchRagings];
    //[self fetchAuthorities];
    //[self fetchBusinessTypes];
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    
    
//    m_gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTap_Callback:)];
//    //[m_gestureTap setDelegate:*m_pGestureRecognizer];
//    m_gestureTap.cancelsTouchesInView = FALSE;

}

//-(void)gestureTap_Callback:(UITapGestureRecognizer*)recognizer
//{
//    NSLog(@"here");
//}

- (void) setEstablishments:(NSArray *)establishments
{
    for (id establishment in _establishments)
    {
        [self.eegeoMapApi removeAnnotation:establishment];
        
    }
    
    _establishments = [establishments copy];
   
    
    for (id establishment in establishments)
    {
        [self.eegeoMapApi addAnnotation:establishment];

    }
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear :animated];
    
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:(BOOL)animated];
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;

    [self setEstablishments: @[]];
    
    [self.eegeoMapApi removePolygon:self.geoFencePoly];
    self.geoFencePoly = nil;

    
    self.eegeoMapApi = nil;
    
    [self.eegeoMapView removeFromSuperview];
    self.eegeoMapView.eegeoMapDelegate = nil;
    self.eegeoMapView = nil;
}

- (void)eegeoMapReady:(id<EGMapApi>)api
{
    self.eegeoMapApi = api;
    [self handleMapAvailable];

}

-(void)refreshResults
{
    if(self.eegeoMapApi != nil)
    {
        [self fetchEstablishments ];
    }
}

-(void)goHome
{
    if(self.eegeoMapApi != nil)
    {
        [self moveTo:m_homeLocation distanceMetres:m_homeDist ];
    }
}

-(void)toggleFlatten
{
    if(self.eegeoMapApi != nil)
    {
        [self toggleMapMode];
    }
}

- (void)handleMapAvailable
{
    [self setLocation:m_homeLocation distanceMetres:m_homeDist ];
    [self fetchEstablishments];
    [self updateTheme];
}

- (void)toggleMapMode
{
    m_mapMode = !m_mapMode;
    [self updateTheme];
}

- (void)updateTheme
{
    EGMapTheme* mapTheme = nil;
    
    [self.eegeoMapApi setEnvironmentFlatten:false];
    
    if (m_mapMode)
    {
        mapTheme = [[[EGMapTheme alloc] initWithSeason: EGMapThemeSeasonSummer
                                     andThemeStateName: @"MapMode"] autorelease];
        
        [self.eegeoMapApi setEnvironmentFlatten:true];
        [self.geoFencePoly setColor:0.1f g:0.1f b:0.1f a:0.3f];

    }
    else
    {
        mapTheme = [[[EGMapTheme alloc] initWithSeason: EGMapThemeSeasonSummer
                                               andTime: EGMapThemeTimeDay
                                            andWeather: EGMapThemeWeatherClear] autorelease];
        [self.geoFencePoly setColor:1.0f g:0.f b:0.f a:0.2f];
    }
    
    [self.eegeoMapApi setMapTheme: mapTheme];
}

- (void)flattenEnvironment
{
    [self.eegeoMapApi setEnvironmentFlatten:false];
}


- (void)setLocation:(CLLocationCoordinate2D)location
             distanceMetres:(double)distanceMetres
{
    [self.eegeoMapApi setCenterCoordinate:location
                           distanceMetres:(float)distanceMetres
                       orientationDegrees:0.f
                                 animated:NO];
}


- (void)moveTo:(CLLocationCoordinate2D)location
        distanceMetres:(double)distanceMetres
{
    [self.eegeoMapApi setCenterCoordinate:location
                           distanceMetres:(float)distanceMetres
                       orientationDegrees:0.f
                                 animated:YES];
}





- (EGAnnotationView*)viewForAnnotation:(id<EGAnnotation>)annotation
{
//    Establishment* establishment = (Establishment*)annotation;
//    if (establishment)
//    {
//        return [self customViewForEstablishmentAnnotation:establishment];
//    }
    // use default view.
    return nil;
}

- (EGAnnotationView*)customViewForEstablishmentAnnotation:(Establishment*)establishment
{
        // XIB defined in app, code-behind extends EGAnnotationView.
        EegeoCustomAnnotationView* pCustomView = [[[NSBundle mainBundle]
                                                   loadNibNamed:@"EegeoCustomAnnotationView"
                                                   owner:self
                                                   options:nil] lastObject];
        
        pCustomView.canShowCallout = NO;
        
        // Manually (re)bind the annotation, intially nil for custom view.
        pCustomView.annotation = establishment;
        pCustomView.imageView.image = [UIImage imageNamed:@"fhis_pass.jpg"];
        pCustomView.title.text = establishment.title;
        pCustomView.businessType.text = establishment.businessType;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        pCustomView.ratingDate.text = [NSString stringWithFormat:@"Rated: %@",[dateFormat stringFromDate:establishment.ratingDate]];
        
        
        pCustomView.centerOffset = CGPointMake(-pCustomView.frame.size.width * 0.5f,
                                               -pCustomView.frame.size.height);
        
        
        pCustomView.hidden = YES;
        return pCustomView;
    
    
    // For other pins use default view.
    return nil;
}

- (void)didSelectAnnotation:(id<EGAnnotation>)annotation
{
    EGAnnotationView* view = [self.eegeoMapApi viewForAnnotation:annotation];
    view.userInteractionEnabled = YES;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    button.userInteractionEnabled = YES;
    view.rightCalloutAccessoryView = button;
    
    //view.rightCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fhis_pass.jpg"]];
   
//    [button addTarget:self
//               action:@selector(onRightCalloutAccessoryTouchUpInside:)
//     forControlEvents: UIControlEventTouchDown];
//    
//    [button addGestureRecognizer: m_gestureTap];
    
    printf("Selected annotation with title: %s\n", [[annotation title] UTF8String]);
}

//-(void)onRightCalloutAccessoryTouchUpInside:(id)sender{
//    
//    NSLog(@"TouchUpInside");
//}

//- (void)mapView:(EGMapView *)mapView annotationView:(EGAnnotationView*)view calloutAccessoryControlTapped:(UIControl *)control {
//    NSLog(@"here");
//}

- (void)didDeselectAnnotation:(id<EGAnnotation>)annotation
{
    printf("Deselected annotation with title: %s\n", [[annotation title] UTF8String]);
    
    EGAnnotationView* view = [self.eegeoMapApi viewForAnnotation:annotation];
    view.rightCalloutAccessoryView = nil;
}





- (BOOL)shouldUseEegeoPinTextureAnnotation:(id<EGAnnotation>)annotation eegeoPinTexturePageIndex:(NSInteger*)eegeoPinTexturePageIndex;
{
    Establishment* establishment = (Establishment*)annotation;
    
    if (establishment)
    {
        int pinIndex = 1;
        
        if ([establishment.schemeType isEqual: @"FHRS"])
        {
            if ([establishment.ratingValue  isEqual: @"5"] ||
                [establishment.ratingValue  isEqual: @"4"])
            {
                pinIndex = 0;
            }
            else if ([establishment.ratingValue  isEqual: @"0"] ||
                     [establishment.ratingValue  isEqual: @"1"])
            {
                pinIndex = 2;
            }
        }
        else
        {
            if ([establishment.ratingValue  isEqual: @"Pass"])
            {
                pinIndex = 0;
            }
            else if ([establishment.ratingValue  isEqual: @"Improvement Required"])
            {
                pinIndex = 2;
            }
            else if ([establishment.ratingValue  isEqual: @"Exempt"])
            {
                pinIndex = 1;
            }
        }
        
        *eegeoPinTexturePageIndex = pinIndex;
        return YES;
    }

    *eegeoPinTexturePageIndex = 0;

    
    return NO;
}


- (void)fetchBusinessTypes
{
    [[FoodStandardsApi sharedInstance] fetchBusinessTypes:^(BOOL success, NSArray *businessTypesJson)
    {
        if (success)
        {
            NSMutableArray * businessTypes = [NSMutableArray arrayWithCapacity:businessTypesJson.count];
            for (NSDictionary * json in businessTypesJson)
            {
                BusinessType * businessType = [[BusinessType alloc] initWithJson: json];
                if (businessType)
                {
                    [businessTypes addObject:businessType];
                }
            }
            
            _businessTypes = [businessTypes copy];

        }
        else
        {
            _businessTypes = @[];
        }
    }];
}


- (void)fetchRatings
{
    [[FoodStandardsApi sharedInstance] fetchRatings:^(BOOL success, NSArray *ratings)
     {
         if (success)
         {
             _ratings = ratings;
         }
         else
         {
             _ratings = @[];
         }
     }];
    
}

- (void)fetchAuthorities
{
    [[FoodStandardsApi sharedInstance] fetchAuthorities:^(BOOL success, NSArray *authorities)
     {
         if (success)
         {
             _authorities = authorities;
         }
         else
         {
             _authorities = @[];
         }
     }];
    
}

// data set looks like latlong was derived from reverse geocode from Post Code, nudge coincident points apart
- (void) hackNudgeCoords:(NSArray*) establishments
{
    for (Establishment * a in establishments)
    {
        for (Establishment * b in establishments)
        {
            if (a == b)
            {
                continue;
            }
            if (a.coordinate.latitude == b.coordinate.latitude &&
                a.coordinate.longitude == b.coordinate.longitude)
            {
                b.coordinate = CLLocationCoordinate2DMake(b.coordinate.latitude, b.coordinate.longitude + 0.00005);
            }
        }
    }
}

- (void) fetchEstablishments
{
    CLLocationCoordinate2D location = [self.eegeoMapApi getCenterCoordinate];
    
    [[FoodStandardsApi sharedInstance] fetchEstablishmentsAroundLocation:location withMaxRadiusMiles:1 andExecuteBlock:^(BOOL success, NSArray *establishmentsJson) {
        if (success) {
            NSArray *filteredEstablishmentsJson = [establishmentsJson filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id establishment, NSDictionary *bindings) {
                    NSString *ratingValue = [establishment objectForKey:@"RatingValue"];
                if ([ratingValue  isEqual: @"Exempt"])
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }]];
            
            
            NSMutableArray * establishments = [NSMutableArray arrayWithCapacity:filteredEstablishmentsJson.count];
            for (NSDictionary * json in filteredEstablishmentsJson)
            {
                Establishment * establishment = [[[Establishment alloc] initWithJson: json] autorelease];
                if (establishment)
                {
                    //NSLog(@"%@;%@;%@", establishment.businessName, establishment.businessType, establishment.ratingValue);
                    
                    
                    [establishments addObject:establishment];
                }
            }
            

            [self hackNudgeCoords:establishments];

            
            [self setEstablishments:establishments];
        }
        else
        {
            [self setEstablishments: @[] ];
        }
    }];
}



@end


