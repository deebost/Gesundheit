//
//  TAWeeklyForecastViewController.m
//  Gesundheit
//
//  Created by Jhaybie on 10/25/13.
//  Copyright (c) 2013 Jhaybie. All rights reserved.
//

#import "WeeklyForecastVC.h"
#import "UIImage+animatedGIF.h"


@interface WeeklyForecastVC ()

@property (weak, nonatomic) IBOutlet UILabel *cityAndStateLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextview;
@property (weak, nonatomic) IBOutlet UITableView *weeklyForecastTableView;
- (IBAction)onCloseButtonTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *gifBackRoundImage;

@end


@implementation WeeklyForecastVC
@synthesize gifBackRoundImage,
            descTextview,
            location,
            weeklyForecastTableView,
            cityAndStateLabel;


int     weekDayValue;
NSArray *week;
UIColor *darkGreenColor,
        *greenColor,
        *yellowColor,
        *orangeColor,
        *redColor;


- (void)viewDidAppear:(BOOL)animated {
    cityAndStateLabel.text = [NSString stringWithFormat:@"%@, %@", [location objectForKey:@"city"], [location objectForKey:@"state"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    week = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    [self changeAllergenLevelColors];
    weeklyForecastTableView.alpha = .85;
    descTextview.alpha = .85;
    [self getCurrentDate];
    [self showGifImage];
}

- (void)showGifImage {
    gifBackRoundImage.image = [UIImage imageNamed:@"skyBackRoundwithClouds.png"];
}

- (void) changeAllergenLevelColors {
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

- (void)getCurrentDate {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    NSString *day = [[[dateFormatter stringFromDate:[NSDate date]] componentsSeparatedByString:@","] firstObject];
    if ([day isEqualToString:@"Sunday"])
        weekDayValue = 0;
    else if ([day isEqualToString:@"Monday"])
        weekDayValue = 1;
    else if ([day isEqualToString:@"Tuesday"])
        weekDayValue = 2;
    else if ([day isEqualToString:@"Wednesday"])
        weekDayValue = 3;
    else if ([day isEqualToString:@"Thursday"])
        weekDayValue = 4;
    else if ([day isEqualToString:@"Friday"])
        weekDayValue = 5;
    else if ([day isEqualToString:@"Saturday"])
        weekDayValue = 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row <= 1) {
        descTextview.text = [[[location objectForKey:@"dayList"] objectAtIndex:indexPath.row] objectForKey:@"desc"];
    } else {
        descTextview.text = @"";
        descTextview.hidden = YES;
    }
}

- (IBAction)onCloseButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RxListVC *rvc = segue.destinationViewController;
    rvc.city = [location objectForKey:@"city"];
    rvc.state = [location objectForKey:@"state"];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"xxx"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
                                      reuseIdentifier: @"xxx"];
    }
    cell.textLabel.text = week[weekDayValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[[location objectForKey:@"dayList"] objectAtIndex:indexPath.row] objectForKey:@"level"]];
    UIColor *textColor;
    float level = cell.detailTextLabel.text.floatValue;
    if (level >= 0 && level < 2.5)
        textColor = darkGreenColor;
    else if (level >= 2.5 && level < 4.9)
        textColor = greenColor;
    else if (level >= 4.9 && level < 7.3)
        textColor = yellowColor;
    else if (level >= 7.3 && level < 9.6)
        textColor = orangeColor;
    else
        textColor = redColor;
    cell.detailTextLabel.textColor = textColor;
    if (weekDayValue == 6)
        weekDayValue = 0;
    else weekDayValue++;
    return cell;
}

@end
