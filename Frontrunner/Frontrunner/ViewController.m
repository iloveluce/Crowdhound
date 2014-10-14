//
//  ViewController.m
//  Frontrunner
//
//  Created by Luciano Arango on 8/8/13.
//  Copyright (c) 2013 Luciano Arango. All rights reserved.
//


#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import "AFHTTPClient.h"

@implementation ViewController

@synthesize coordinateLabel;
@synthesize mapView;

UIColor * thecolor[];
UIColor *defaultcolor;
NSString *places = @"regions";
CLLocationCoordinate2D color_coord;
int coloroverlay = 0;
int colorindex = 0;

CLLocationManager *_locationManager;
NSArray *_regionArray;

-(IBAction)switchlocation:(id)sender {
    
    if (control.selectedSegmentIndex == 0){
        
        [self showInfoMessage:@"Entering Harvard"];
        CLLocationCoordinate2D changedcoord;
        changedcoord.latitude = 42.372506;
        changedcoord.longitude = -71.116639;
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(changedcoord, 600, 600) animated:YES];
        
    }
    if (control.selectedSegmentIndex == 1 ){
        
        [self showInfoMessage:@"Entering Yale"];
        CLLocationCoordinate2D changedcoord;
        changedcoord.latitude = 41.307332;
        changedcoord.longitude = -72.930662;
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(changedcoord, 600, 600) animated:YES];
    }
    
}



- (void)viewDidLoad
{
    defaultcolor= [UIColor greenColor];
    [super viewDidLoad];
    [self initializeMap];
    CLLocationCoordinate2D initialCoordinate;
    initialCoordinate.latitude = 42.377760;
    initialCoordinate.longitude = -71.116624;
    //self.mapView.centerCoordinate = initialCoordinate;
    [self initializeLocationManager];
    [self addspots];
    NSArray *geofences = [self buildGeofenceData];
    [self initializeRegionMonitoring:geofences];
    [self initializeLocationUpdates];
       
}

- (void)viewDidUnload
{
    [self setCoordinateLabel:nil];
    [self setMapView:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)initializeMap {
    CLLocationCoordinate2D initialCoordinate;
    //initialCoordinate.latitude = 42.377760;
    //initialCoordinate.longitude = -71.116624;
    [self.mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(initialCoordinate, 400, 400) animated:YES];
    //self.mapView.centerCoordinate = initialCoordinate;
    
    
    
    /* Define an overlay for fly.
    CLLocationCoordinate2D  points[6];
    
    points[0] = CLLocationCoordinate2DMake(42.371491, -71.117598);
    points[1] = CLLocationCoordinate2DMake(42.371425, -71.117635);
    points[2] = CLLocationCoordinate2DMake(42.371468, -71.117782);
    points[3] = CLLocationCoordinate2DMake(42.371332, -71.117868);
    points[4] = CLLocationCoordinate2DMake(42.371368, -71.117972);
    points[5] = CLLocationCoordinate2DMake(42.371581, -71.117842);
 
    MKPolygon* poly = [MKPolygon polygonWithCoordinates:points count:6];
    poly.title = @"fly";
    
    [self.mapView addOverlay:poly];
    
    */
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)initializeLocationManager {
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled]) {
        [self showAlertWithMessage:@"You need to enable location services to use this app."];
        return;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
}


- (void) initializeRegionMonitoring:(NSArray*)geofences {
    
    if (_locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
    }
    
    if(![CLLocationManager regionMonitoringAvailable]) {
        [self showAlertWithMessage:@"This app requires region monitoring features which are unavailable on this device."];
        return;
    }
    
    for(CLRegion *geofence in geofences) {
        [_locationManager startMonitoringForRegion:geofence];
    }
    
}

- (NSArray*) buildGeofenceData {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:places ofType:@"plist"];
    _regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray *geofences = [NSMutableArray array];
    for(NSDictionary *regionDict in _regionArray) {
        CLRegion *region = [self mapDictionaryToRegion:regionDict];
        [geofences addObject:region];
    }
    
    return [NSArray arrayWithArray:geofences];
}

- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary {
    NSString *title = [dictionary valueForKey:@"title"];
    
    CLLocationDegrees latitude = [[dictionary valueForKey:@"mid_lat"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"mid_long"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    //NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    //CGPoint midPoint = CGPointFromString([dictionary valueForKey:@"midpoint"]);
    
    //CGPoint midPoint = [[dictionary valueForKey:@"midpoint"] ];

    //CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(midPoint.x, midPoint.y);
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    return [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                   radius:regionRadius
                                               identifier:title];
}

- (void)initializeLocationUpdates {
    [_locationManager startUpdatingLocation];
}

#pragma mark - Location Manager - Region Task Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered Region - %@", region.identifier);
  
    [self Lognewlocation:region.center];
    [self showRegionAlert:@"Entering Region" forRegion:region.identifier];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited Region - %@", region.identifier);
    
    [self Logexitlocation:region.center];
    [self showRegionAlert:@"Exiting Region" forRegion:region.identifier];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region", region.identifier);
}

#pragma mark - Location Manager - Standard Task Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.coordinateLabel.text = [NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude];
}
#pragma mark - Alert Methods

- (void) showRegionAlert:(NSString *)alertText forRegion:(NSString *)regionIdentifier {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:alertText
                                                      message:regionIdentifier
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

- (void)showAlertWithMessage:(NSString*)alertText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Error"
                                                        message:alertText
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)showInfoMessage:(NSString*)alertText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:alertText
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}
- (void)Lognewlocation:(CLLocationCoordinate2D)coordinate {
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *uniqueIdentifier = [device identifierForVendor];
    NSString *loc_lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *loc_long = [NSString stringWithFormat:@"%f",coordinate.longitude];

    //POST beginning
    NSURL *url = [NSURL URLWithString:@"http://crowdhoundapp.com"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            loc_lat, @"loc_lat",
                            loc_long, @"loc_long",
                            uniqueIdentifier, @"device_id",
                            nil];
    [httpClient postPath:@"/checkin/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)Logexitlocation:(CLLocationCoordinate2D)coordinate {
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *uniqueIdentifier = [device identifierForVendor];
    NSString *loc_lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *loc_long = [NSString stringWithFormat:@"%f",coordinate.longitude];
    
    //POST beginning
    NSURL *url = [NSURL URLWithString:@"http://crowdhoundapp.com"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            loc_lat, @"loc_lat",
                            loc_long, @"loc_long",
                            uniqueIdentifier, @"device_id",
                            nil];
    [httpClient postPath:@"/checkout/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>) overlay
{
    if ([overlay isKindOfClass:MKPolygon.class]) {
            MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
            polygonView.fillColor = [thecolor[coloroverlay] colorWithAlphaComponent:0.2];
            polygonView.strokeColor = [thecolor[coloroverlay] colorWithAlphaComponent:0.7];
            polygonView.lineWidth = 3;
            coloroverlay++;
            return polygonView;
    }    
    return nil;
}


- (void)addspots {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    NSArray *locations = [NSArray arrayWithContentsOfFile:plistPath];
    for (NSDictionary *location in locations) {
       
            CLLocationCoordinate2D  points[4];
            CGPoint Rect1 = CGPointFromString([location valueForKey:@"Rect1"]);
            points[0] = CLLocationCoordinate2DMake(Rect1.x, Rect1.y);
            CGPoint Rect2 = CGPointFromString([location valueForKey:@"Rect2"]);
            points[1] = CLLocationCoordinate2DMake(Rect2.x, Rect2.y);
            CGPoint Rect3 = CGPointFromString([location valueForKey:@"Rect3"]);
            points[2] = CLLocationCoordinate2DMake(Rect3.x, Rect3.y);
            CGPoint Rect4 = CGPointFromString([location valueForKey:@"Rect4"]);
            points[3] = CLLocationCoordinate2DMake(Rect4.x, Rect4.y);
        
        MKPolygon* polygon = [MKPolygon polygonWithCoordinates:points count:4];
        CLLocationDegrees latitude = [[location valueForKey:@"mid_lat"] doubleValue];
        CLLocationDegrees longitude =[[location valueForKey:@"mid_long"] doubleValue];
        color_coord = CLLocationCoordinate2DMake(latitude, longitude);
        [self heat:color_coord];
        [self.mapView addOverlay:polygon];
        colorindex++;
    
    }
    colorindex = 0;
    coloroverlay = 0;
}

-(void) heat:(CLLocationCoordinate2D)coordinate{
    
    
    NSString *loc_lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *loc_long = [NSString stringWithFormat:@"%f",coordinate.longitude];

   
    //POST beginning
    NSURL *url = [NSURL URLWithString:@"http://crowdhoundapp.com"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            loc_lat, @"loc_lat",
                            loc_long, @"loc_long",
                            nil];
       [httpClient postPath:@"/color/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
        NSString *newStr;
        newStr = [responseStr substringToIndex:[responseStr length]-8];
        NSLog(@"Request Successful, response '%@'", newStr);

        NSDictionary *colorTable = @{
                                        @"Bluecolor" : [UIColor blueColor],
                                        @"Redcolor" : [UIColor redColor],
                                        @"Orangecolor" : [UIColor orangeColor],
                                        @"Purplecolor" : [UIColor purpleColor],
                                        @"Blackcolor": [UIColor blackColor],
                                        @"Yellowcolor": [UIColor yellowColor]
                                        
                                        };
           
           
           UIColor *myConvertedColor = [colorTable objectForKey:newStr];
           thecolor[colorindex]=myConvertedColor;

    }
        
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
    }

@end