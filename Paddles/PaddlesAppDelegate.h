//
//  PaddlesAppDelegate.h
//  Paddles
//
//  Created by Pavel Samsonov on 10.12.15.
//  Copyright (c) 2015 Samsonov Pavel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaddlesViewController;
@class TitleViewController;

@interface PaddlesAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PaddlesViewController *gameController;
@property (strong, nonatomic) TitleViewController *viewController;

- (void)showTitle;
- (void)playGame:(int)computer;

@end
