//
//  TitleViewController.m
//  AirHockey
//
//  Created by Pavel Samsonov on 17.01.16.
//  Copyright (c) 2016 Samsonov Pavel. All rights reserved.
//

#import "TitleViewController.h"
#import "PaddlesAppDelegate.h"

@interface TitleViewController ()

@end

@implementation TitleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onPlay:(id)sender
{
    PaddlesAppDelegate *app = (PaddlesAppDelegate *)[UIApplication sharedApplication].delegate;
    UIButton *button = (UIButton *)sender;
    [app playGame:(int)button.tag];
}

@end


































