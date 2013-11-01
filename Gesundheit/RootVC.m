//
//  TAViewController.m
//  Gesundheit
//
//  Created by Jhaybie on 10/23/13.
//  Copyright (c) 2013 Jhaybie. All rights reserved.
//

#import "FavoriteLocationsVC.h"
#import "RootVC.h"
#import "WeeklyForecastVC.h"
#import "RxListVC.h"
#import "UIColor+ColorCategory.h"
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)


@interface RootVC ()
@property (weak, nonatomic) IBOutlet UIButton *changeDefaultCityButton;
@property (weak, nonatomic) IBOutlet UILabel     *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel     *currentDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UILabel     *predominantTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dandelionGifImage;
@property (weak, nonatomic) IBOutlet UITextView  *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *enterZipTextField;
@property (weak, nonatomic) IBOutlet UIButton *allergenLevelButton;
@property (weak, nonatomic) IBOutlet UIImageView *dandelionImage;
@property (weak, nonatomic) IBOutlet UIButton *rootVCDisabledButton;
@property (weak, nonatomic) IBOutlet UIButton *weeklyForecastVCActiveButton;
@property (weak, nonatomic) IBOutlet UIButton *rxListVCActiveButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)onTapGoGoRxListVC:(id)sender;
- (IBAction)onSwipeGestureActivated:(id)sender;

- (IBAction)onTapGoGoWeeklyForecastVC:(id)sender;
- (IBAction)swipingPageControlMotion:(id)sender;






- (IBAction)onChangeDefaultCityButtonTap:(id)sender;
- (IBAction)onGoButtonTap:(id)sender;
@end


@implementation RootVC
@synthesize cityLabel,
            rxListVCActiveButton,
            weeklyForecastVCActiveButton,
            rootVCDisabledButton,
            dandelionImage,
            changeDefaultCityButton,
            currentDateLabel,
            dandelionGifImage,
            descriptionTextView,
            enterZipTextField,
            goButton,
            pageControl,
            predominantTypeLabel,
            allergenLevelButton;


BOOL              isShown;
CLGeocoder        *geocoder;
CLLocationManager *locationManager;
int               currentLocationIndex,
                  weekDayValue;
NSArray           *week;
NSDictionary      *location;
NSMutableArray    *locations;
NSString          *city,
                  *state,
                  *zip,
                  *predominantType;


- (void)loadPList {
    locations = [[[NSUserDefaults standardUserDefaults] objectForKey:@"locations"] ?: @[] mutableCopy];
}

- (void)savePList {
    [[NSUserDefaults standardUserDefaults] setObject:locations forKey:@"locations"];
}

- (void)getCurrentLocationZip {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)rotateDandy:(UIImageView *)image
//        aroundPoint:(CGPoint)rotationPoint
           duration:(NSTimeInterval)duration
            degrees:(CGFloat)degrees {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, 200, 400, M_1_PI, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(9), YES);

    CAKeyframeAnimation *dandyAnimation;

    dandyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    dandyAnimation.path = path;
    CGPathRelease(path);

//    CGPoint transportPoint = CGPointMake(dand, <#CGFloat y#>)

    dandyAnimation.duration = duration;
    dandyAnimation.removedOnCompletion = NO;
    dandyAnimation.autoreverses = YES;
    dandyAnimation.rotationMode = kCAAnimationRotateAutoReverse;
    dandyAnimation.speed = 20;
    dandyAnimation.fillMode = kCAFillModeForwards;

    [dandelionImage.layer addAnimation:dandyAnimation forKey:@"position"];

}

- (void)fetchPollenDataFromZip:(NSString *)zipCode {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://direct.weatherbug.com/DataService/GetPollen.ashx?zip=%@", zipCode]]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               location = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:&connectionError];
                               cityLabel.text = [location objectForKey:@"city"];
                               descriptionTextView.text = [[[location objectForKey:@"dayList"] objectAtIndex:0] objectForKey:@"desc"];
                               predominantTypeLabel.text = [location objectForKey:@"predominantType"];
                               [allergenLevelButton setTitle:[NSString stringWithFormat:@"%@", [[[location objectForKey:@"dayList"] objectAtIndex:0] objectForKey:@"level"]] forState:UIControlStateNormal];
                               [locationManager stopUpdatingLocation];
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               [self allergenLevelChangeFontColor];
                           }];
}

//- (id)path {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths firstObject];
//    return [documentsDirectory stringByAppendingPathComponent:@"Gesundheit.plist"];
//}

- (void)allergenLevelChangeFontColor {
    float level = allergenLevelButton.currentTitle.floatValue;
    UIColor *textColor;
    if (level >= 0 && level < 2.5)
        textColor = [UIColor lowColor];
    else if (level >= 2.5 && level < 4.9)
        textColor = [UIColor lowMedColor];
    else if (level >= 4.9 && level < 7.3)
        textColor = [UIColor mediumColor];
    else if (level >= 7.3 && level < 9.6)
        textColor = [UIColor medHighColor];
    else
        textColor = [UIColor highColor];
    [allergenLevelButton setTitleColor:textColor forState:UIControlStateNormal];
    descriptionTextView.textColor = [UIColor blackColor];
}

- (void)showGifImage {
    dandelionGifImage.image = [UIImage imageNamed:@"skyBackRound2.png"];
    dandelionImage.image = [UIImage imageNamed:@"testDandyDan.png"];
    [dandelionImage setAlpha:.50];

}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    currentLocationIndex++;
//    location = locations[currentLocationIndex];
//    cityLabel.text = [location objectForKey:@"city"];
//    descriptionTextView.text = [[[location objectForKey:@"dayList"] objectAtIndex:0] objectForKey:@"desc"];
//    predominantTypeLabel.text = [location objectForKey:@"predominantType"];
//    [allergenLevelButton setTitle:[NSString stringWithFormat:@"%@", [[[location objectForKey:@"dayList"] objectAtIndex:0] objectForKey:@"level"]] forState:UIControlStateNormal];
//    if ([segue.identifier isEqualToString:@"forecastSegue"]) {
//        WeeklyForecastVC *wfvc = segue.destinationViewController;
//        wfvc.location = location;
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    geocoder = [[CLGeocoder alloc] init];
    currentLocationIndex = 0;
    [self buttonBorder];
    [self showGifImage];
    isShown = NO;
    NSString *defaultLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLocation"];
    if (!defaultLocation) {
        locationManager = [[CLLocationManager alloc] init];
        [self getCurrentLocationZip];
    } else {
        [self fetchPollenDataFromZip:defaultLocation];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadPList];
    [pageControl sizeForNumberOfPages:locations.count];
    [self rotateDandy:dandelionImage duration:100 degrees:5];
    [self makeShadowsOnButton];
}

- (void) makeShadowsOnButton {
    allergenLevelButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    allergenLevelButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    allergenLevelButton.layer.shadowOpacity = .85f;
    allergenLevelButton.layer.shadowRadius = 3.0f;
}

- (void) buttonBorder {
    float corner = 10.0f;

    [[allergenLevelButton layer] setCornerRadius:40.0f];
    [[allergenLevelButton layer] setOpacity:0.85f];
    [[allergenLevelButton layer] setBorderWidth:4.0f];
    [[allergenLevelButton layer] setBorderColor:[UIColor whiteColor].CGColor];

    [[rxListVCActiveButton layer] setCornerRadius:corner];
    [[rxListVCActiveButton layer] setBorderWidth:1.0f];
    [[rxListVCActiveButton layer] setOpacity:1.0f];
    [[rxListVCActiveButton layer] setBorderColor:[UIColor blueColor].CGColor];

    [[weeklyForecastVCActiveButton layer] setCornerRadius:corner];
    [[weeklyForecastVCActiveButton layer] setBorderWidth:1.0f];
    [[weeklyForecastVCActiveButton layer] setOpacity:1.0f];
    [[weeklyForecastVCActiveButton layer] setBorderColor:[UIColor blueColor].CGColor];

    [[rootVCDisabledButton layer] setCornerRadius:corner];
    [[rootVCDisabledButton layer] setBorderWidth:1.0f];
    [[rootVCDisabledButton layer] setOpacity:.85f];
    [[rootVCDisabledButton layer] setBorderColor:[UIColor whiteColor].CGColor];

    [[goButton layer] setCornerRadius:15.0f];
    [[goButton layer] setBorderWidth:1.0];
    [[goButton layer] setBorderColor:[UIColor blueColor].CGColor];

}



#pragma mark CLLocationManagerDelegate

//Ask Don or Max about replacing this deprecated method

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    CLLocation *currentLocation = newLocation;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray* placemarks, NSError* error) {
                       if (error == nil && placemarks.count > 0) {
                           CLPlacemark *placemark = [placemarks lastObject];
                           zip = [NSString stringWithFormat:@"%@", placemark.postalCode];
                           [self fetchPollenDataFromZip:zip];
                       }
                   }];
}

- (IBAction)onTapGoGoRxListVC:(id)sender {
    RxListVC *rlvc = [self.storyboard instantiateViewControllerWithIdentifier:@"RxListVC"];
    rlvc.location = [location objectForKey:@"city"];
    rlvc.location = [location objectForKey:@"state"];
    [self presentViewController:rlvc animated:NO completion:nil];
}

- (IBAction)onSwipeGestureActivated:(id)sender {
    currentLocationIndex++;
    location = locations[currentLocationIndex];
    cityLabel.text = [location objectForKey:@"city"];
    descriptionTextView.text = [[[location objectForKey:@"dayList"] objectAtIndex:0] objectForKey:@"desc"];
    predominantTypeLabel.text = [location objectForKey:@"predominantType"];
    [allergenLevelButton setTitle:[NSString stringWithFormat:@"%@", [[[location objectForKey:@"dayList"] objectAtIndex:0] objectForKey:@"level"]] forState:UIControlStateNormal];
}

- (IBAction)onTapGoGoWeeklyForecastVC:(id)sender {
    WeeklyForecastVC *wfvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WeeklyForecastVC"];
    wfvc.location = location;
    [self presentViewController:wfvc
                       animated:NO
                     completion:nil];
}

//- (IBAction)swipingPageControlMotion:(id)sender {
//    pageControl.c
//}

- (IBAction)onChangeDefaultCityButtonTap:(id)sender {
    changeDefaultCityButton.hidden = YES;
    enterZipTextField.hidden = NO;
    [enterZipTextField becomeFirstResponder];
    goButton.hidden = NO;
}

- (IBAction)onGoButtonTap:(id)sender {
    [enterZipTextField resignFirstResponder];
    enterZipTextField.hidden = YES;
    goButton.hidden = YES;
    changeDefaultCityButton.hidden = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (enterZipTextField.text.length == 5) {
        [[NSUserDefaults standardUserDefaults] setObject: enterZipTextField.text forKey:@"defaultLocation"];
        [self fetchPollenDataFromZip:enterZipTextField.text];
    }
}

@end
