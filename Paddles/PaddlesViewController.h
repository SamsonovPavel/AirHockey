//
//  PaddlesViewController.h
//  Paddles
//
//  Created by Pavel Samsonov on 10.12.15.
//  Copyright (c) 2015 Samsonov Pavel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioToolbox.h"
#import "Paddle.h"
#import "Puck.h"

enum { AI_START, AI_WAIT, AI_BORED, AI_DEFENSE, AI_OFFENSE, AI_OFFENSE2 };

@interface PaddlesViewController : UIViewController
{
    Paddle *paddle1;
    Paddle *paddle2;
    Puck *puck;

    NSTimer *timer;
    UIAlertView *alert;
    
    SystemSoundID sounds[3];
    
    int state;
}

@property (strong, nonatomic) IBOutlet UIView *viewPaddle1;
@property (strong, nonatomic) IBOutlet UIView *viewPaddle2;
@property (strong, nonatomic) IBOutlet UIView *viewPuck;
@property (strong, nonatomic) IBOutlet UILabel *viewScore1;
@property (strong, nonatomic) IBOutlet UILabel *viewScore2;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel1;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel2;
@property (weak, nonatomic) IBOutlet UIButton *pausedButton;

@property (assign, nonatomic) int computer;

- (IBAction)pauseButton:(id)sender;
- (void)resume;
- (void)pause;

@end
