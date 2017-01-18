// Copyright eeGeo Ltd (2012-2014), All Rights Reserved

#import "EegeoMapsContainerViewController.h"
#import "EGApi.h"
#import "EegeoCustomAnnotationView.h"

@import CoreLocation;

@interface EegeoMapsContainerViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@interface EegeoMapsContainerViewController () <EGMapDelegate>
@property (strong, nonatomic) id<EGMapApi> eegeoMapApi;
@end

@interface EegeoMapsContainerViewController ()
@property (strong, nonatomic) EGMapView* eegeoMapView;

@property (strong, nonatomic) id<EGPrecacheOperation> precacheOperation;
@property (strong, nonatomic) id<EGPolygon> geoFencePoly;

@property (strong, nonatomic) EGPointAnnotation* marker1;
@property (strong, nonatomic) EGPointAnnotation* marker2;
@property (strong, nonatomic) EGPointAnnotation* marker3;


@end


@implementation EegeoMapsContainerViewController
{
    bool m_mapMode;
    CLLocationCoordinate2D m_homeLocation;
    double m_homeDist;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eegeoMapApi = nil;
    self.precacheOperation = nil;
    self.geoFencePoly = nil;
    self.marker1 = nil;
    self.marker2 = nil;
    self.marker3 = nil;
    
    m_mapMode = false;
    m_homeLocation = CLLocationCoordinate2DMake(56.459930, -2.978064);
    m_homeDist = 2000.0;
    
    self.eegeoMapView = [[[EGMapView alloc] initWithFrame:self.view.bounds] autorelease];
    self.eegeoMapView.eegeoMapDelegate = self;
    self.eegeoMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view insertSubview:self.eegeoMapView atIndex:0];
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
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
    
    if(self.precacheOperation != nil)
    {
        [self.precacheOperation cancel];
        self.precacheOperation = nil;
    }
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [self.eegeoMapApi removeAnnotation: self.marker1];
    [self.eegeoMapApi removeAnnotation: self.marker2];
    [self.eegeoMapApi removeAnnotation: self.marker3];
    self.marker1 = nil;
    self.marker2 = nil;
    self.marker3 = nil;
    
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
    //[self addGeofencePolygon];
    //[self addAnnotations];
    //[self precacheBounds];
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

-(void)setCoordinateBounds
{
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(37.797818, -122.407015),
        CLLocationCoordinate2DMake(37.798886, -122.398238),
        CLLocationCoordinate2DMake(37.798547, -122.397831),
        CLLocationCoordinate2DMake(37.795482, -122.396736),
        CLLocationCoordinate2DMake(37.794159, -122.395116),
        CLLocationCoordinate2DMake(37.786647, -122.404697)
    };
    NSUInteger numberOfCoordinates = sizeof(coordinates) / sizeof(CLLocationCoordinate2D);
    
    EGCoordinateBounds bounds = EGCoordinateBoundsFromCoordinatesMake(coordinates, numberOfCoordinates);
    
    [self.eegeoMapApi setVisibleCoordinateBounds:bounds animated:YES];
}

- (void)addGeofencePolygon
{
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(37.797818, -122.407015),
        CLLocationCoordinate2DMake(37.798886, -122.398238),
        CLLocationCoordinate2DMake(37.798547, -122.397831),
        CLLocationCoordinate2DMake(37.795482, -122.396736),
        CLLocationCoordinate2DMake(37.794159, -122.395116),
        CLLocationCoordinate2DMake(37.786647, -122.404697)
    };
    NSUInteger numberOfCoordinates = sizeof(coordinates) / sizeof(CLLocationCoordinate2D);
    
    self.geoFencePoly = [self.eegeoMapApi polygonWithCoordinates:coordinates count:numberOfCoordinates];
    
    [self.geoFencePoly setColor:1.0f g:0.0f b:0.0f a:0.2f];
    
    [self.eegeoMapApi addPolygon:self.geoFencePoly];
}

- (void)addAnnotations
{
    self.marker1 = [[[EGPointAnnotation alloc] init] autorelease];
    self.marker1.coordinate = CLLocationCoordinate2DMake(37.794851, -122.402650);
    [self.eegeoMapApi addAnnotation:self.marker1];
    
    // Set data after adding Annotation to test KVO.
    self.marker1.title = @"Downtown";
    self.marker1.subtitle = @"(Custom Annotation)";
    
    self.marker2 = [[[EGPointAnnotation alloc] init] autorelease];
    self.marker2.coordinate = CLLocationCoordinate2DMake(37.792064, -122.403784);
    self.marker2.title = @"California Street";
    self.marker2.subtitle = @"(Default Callout)";
    [self.eegeoMapApi addAnnotation:self.marker2];
    
    self.marker3 = [[[EGPointAnnotation alloc] init] autorelease];
    self.marker3.coordinate = CLLocationCoordinate2DMake(37.795141, -122.397669);
    self.marker3.title = @"Three Embarcadero";
    self.marker3.subtitle = @"(Default Callout)";
    [self.eegeoMapApi addAnnotation:self.marker3];
    
    // Test programmatic selection.
    [self.eegeoMapApi selectAnnotation:self.marker1 animated:NO];
    [self.eegeoMapApi selectAnnotation:self.marker3 animated:NO];
}

- (void)precacheBounds
{
    EGCoordinateBounds bounds = EGCoordinateBoundsMake(CLLocationCoordinate2DMake(37.794771, -122.400929),
                                                       CLLocationCoordinate2DMake(37.792440, -122.396369));
    
    id<EGPrecacheOperation> precacheCancelExample = [self.eegeoMapApi precacheMapDataInCoordinateBounds:bounds];
    
    [precacheCancelExample cancel];
    
    self.precacheOperation = [self.eegeoMapApi precacheMapDataInCoordinateBounds:bounds];
}

- (void)precacheOperationCompleted:(id<EGPrecacheOperation>)precacheOperation
{
    BOOL cancelled = [precacheOperation cancelled];
    BOOL completed = [precacheOperation completed];
    
    printf("%s\n", cancelled ? "Cancelled" : "Not cancelled");
    printf("%s\n", completed ? "Completed" : "Not completed");
    printf("Percent: %d\n", [precacheOperation percentComplete]);
    
    if(precacheOperation == self.precacheOperation)
    {
        self.precacheOperation = nil;
    }
}

- (EGAnnotationView*)viewForAnnotation:(id<EGAnnotation>)annotation
{
    // Custom view for marker one that always shows data, no callout as always showing data.
    if(annotation == self.marker1)
    {
        // XIB defined in app, code-behind extends EGAnnotationView.
        EegeoCustomAnnotationView* pCustomView = [[[NSBundle mainBundle]
                                                   loadNibNamed:@"EegeoCustomAnnotationView"
                                                   owner:self
                                                   options:nil] lastObject];
        
        pCustomView.canShowCallout = NO;
        
        // Manually (re)bind the annotation, intially nil for custom view.
        pCustomView.annotation = annotation;
        pCustomView.imageView.image = [UIImage imageNamed:@"custom_annotation_image"];
        
        pCustomView.centerOffset = CGPointMake(-pCustomView.frame.size.width * 0.5f,
                                               -pCustomView.frame.size.height);
        
        return pCustomView;
    }
    
    // For other pins use default view.
    return nil;
}

- (void)didSelectAnnotation:(id<EGAnnotation>)annotation
{
    // Add a nice left callout accessory.
    EGAnnotationView* view = [self.eegeoMapApi viewForAnnotation:annotation];
    view.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    printf("Selected annotation with title: %s\n", [[annotation title] UTF8String]);
}

- (void)didDeselectAnnotation:(id<EGAnnotation>)annotation
{
    printf("Deselected annotation with title: %s\n", [[annotation title] UTF8String]);
    
    // Remove the left callout accessory.
    EGAnnotationView* view = [self.eegeoMapApi viewForAnnotation:annotation];
    view.leftCalloutAccessoryView = nil;
}

- (BOOL)shouldUseEegeoPinTextureAnnotation:(id<EGAnnotation>)annotation eegeoPinTexturePageIndex:(NSInteger*)eegeoPinTexturePageIndex;
{
    // No pin for annotation 1 (with the custom view).
    if(annotation == self.marker1)
    {
        return NO;
    }
    
    // Specify annotation texture index for annotation 3.
    if(annotation == self.marker3)
    {
        *eegeoPinTexturePageIndex = 4;
    }
    
    // Use default value for other annotations.
    return YES;
}

@end


