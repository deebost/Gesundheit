//
//  TAViewController.m
//  Gesundheit
//
//  Created by Jhaybie on 10/23/13.
//  Copyright (c) 2013 Jhaybie. All rights reserved.
//

#import "TAViewController.h"
#import "TALocation.h"
#import "TALegendViewController.h"

@interface TAViewController ()
@property (weak, nonatomic) IBOutlet UILabel *allergenLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityAndStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *predominantTypeLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@end


@implementation TAViewController
@synthesize allergenLevelLabel,
            cityAndStateLabel,
            currentDateLabel,
            descriptionTextView,
            predominantTypeLabel;


NSArray *weeklyForecast;
NSString *zip;
TALocation *location;
UIColor *darkGreenColor;
UIColor *greenColor;
UIColor *yellowColor;
UIColor *orangeColor;
UIColor *redColor;


- (void)getCurrentDate {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    currentDateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)viewDidAppear:(BOOL)animated {
    [self getCurrentDate];
    [self getCurrentLocationZip];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    location = [[TALocation alloc] init];
    darkGreenColor = [UIColor colorWithRed:34.0f/255.0f
                                     green:139.0f/255.0f
                                      blue:34.0f/255.0f
                                     alpha:1];
    greenColor = [UIColor colorWithRed:124.0f/255.0f
                                 green:252.0f/255.0f
                                  blue:0.0f/255.0f
                                 alpha:1];
    yellowColor = [UIColor colorWithRed:255.0f/255.0f
                                  green:215.0f/255.0f
                                   blue:0.0f/255.0f
                                  alpha:1.0];
    orangeColor = [UIColor colorWithRed:255.0f/255.0f
                                  green:140.0f/255.0f
                                   blue:0.0f/255.0f
                                  alpha:1.0];
    redColor = [UIColor colorWithRed:255.0f/255.0f
                               green:0.0f/255.0f
                                blue:0.0f/255.0f
                               alpha:1.0];
}

-(NSArray *) fetchPollenData {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://direct.weatherbug.com/DataService/GetPollen.ashx?zip=%@", zip]]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary *initialDump = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:0
                                                                                             error:&connectionError];
                               weeklyForecast = [initialDump objectForKey:@"dayList"];
                               location.city = [initialDump objectForKey:@"city"];
                               location.state = [initialDump objectForKey:@"state"];
                               location.predominantType = [initialDump objectForKey:@"predominantType"];
                               [self showResults];
                           }];
    return weeklyForecast;
}

- (void) allergenLevelChangeFontColor {
    float level = allergenLevelLabel.text.floatValue;
    UIColor *backgroundColor;

    if (level >= 0.1 && level <= 2.4)
        backgroundColor = darkGreenColor;
    else if (level >= 2.5 && level <= 4.8)
        backgroundColor = greenColor;
    else if (level >= 4.9 && level >= 7.2)
        backgroundColor = yellowColor;
    else if (level >= 7.3 && level <= 9.6)
        backgroundColor = orangeColor;
    else
        backgroundColor = redColor;
    allergenLevelLabel.backgroundColor = backgroundColor;
    descriptionTextView.backgroundColor = backgroundColor;
}

- (void) showResults {
    if (weeklyForecast.count > 0) {
        allergenLevelLabel.text = [NSString stringWithFormat:@"%@",[weeklyForecast[0] objectForKey:@"level"]];
        cityAndStateLabel.text = [NSString stringWithFormat:@"%@, %@", location.city, location.state.uppercaseString];
        descriptionTextView.text = [weeklyForecast[0] objectForKey:@"desc"];
        predominantTypeLabel.text = location.predominantType;
    }
    [self allergenLevelChangeFontColor];
}

- (void) labelFonts {
    UIFont *jandaAppleFont = [UIFont fontWithName:@"JandaAppleCobbler"
                                             size:55];
    UIFont *airplaneFont = [UIFont fontWithName:@"Airplanes in the Night Sky"
                                           size:17];

    allergenLevelLabel.font = jandaAppleFont;
    cityAndStateLabel.font = airplaneFont;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"Location changed [%i] %@", locations.count, [locations objectAtIndex:0]);
}

- (void)getCurrentLocationZip {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    CLLocation *currentLocation = locationManager.location;
    //NSLog(@"%@, ", locationManager.location);
    CLGeocoder *test;
    weeklyForecast = [self fetchPollenData];
    [test reverseGeocodeLocation:currentLocation
               completionHandler:^(NSArray *placemarks, NSError *error) {
        //if (!error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@",[placemark description]);
            weeklyForecast = [self fetchPollenData];
        //}
    }];
}

@end
