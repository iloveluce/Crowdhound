//
//  ViewController.h
//  Frontrunner
//
//  Created by Luciano Arango on 8/8/13.
//  Copyright (c) 2013 Luciano Arango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate> {
    IBOutlet UISegmentedControl  *control;

}
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
extern UIColor *thecolor[];
extern NSString *plist ;
-(IBAction)switchlocation:(id)sender;

@end

