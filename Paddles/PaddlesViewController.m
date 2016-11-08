//
//  PaddlesViewController.m
//  Paddles
//
//  Created by Pavel Samsonov on 10.12.15.
//  Copyright (c) 2015 Samsonov Pavel. All rights reserved.
//

#import "PaddlesViewController.h"
#import "PaddlesAppDelegate.h"

#define MAX_SCORE_1 3
#define MAX_SCORE_2 10

#define SOUND_WALL   0
#define SOUND_PADDLE 1
#define SOUND_SCORE  2

#define MAX_SPEED 15

struct CGRect gPlayerBox[] =
{
    { 40, 37, 320 - 80, 213 },     //  рамка первого игрока
    { 40, 319, 320 - 80, 213 }     //  рамка второго игрока
};

struct CGRect gPuckBox =
{
    23, 23, 320 - 46, 568 - 46
};

struct CGRect gGoalBox[] =
{
    { 102, -20, 116, 49 },
    { 102, 539, 116, 49 }
};

@interface PaddlesViewController ()
@property (assign, nonatomic) BOOL paused;
@end

@implementation PaddlesViewController

#pragma mark - APIMethods

- (void)loadSound:(NSString *)name Slot:(int)slot
{
    if (sounds[slot] != 0) return;
    NSString *sndPath = [[NSBundle mainBundle] pathForResource:name
                                                         ofType:@"wav"
                                                    inDirectory:@"/"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:sndPath], &sounds[slot]);
}

- (void)initSounds
{
    [self loadSound:@"wall" Slot:SOUND_WALL];
    [self loadSound:@"paddle" Slot:SOUND_PADDLE];
    [self loadSound:@"score" Slot:SOUND_SCORE];
}

- (void)playSound:(int)slot
{
    AudioServicesPlaySystemSound(sounds[slot]);
}

- (void)reset
{
    [paddle1 reset];
    [paddle2 reset];
    [puck reset];
    state = 0;
}

- (void)start
{
    if (timer == nil)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                 target:self
                                               selector:@selector(animate)
                                               userInfo:NULL
                                                repeats:YES];
    }
//    self.viewPuck.hidden = NO;
}

- (void)stop
{
    if (timer != nil)
    {
        [timer invalidate];
        timer = nil;
    }
//    self.viewPuck.hidden = YES;
}

- (void)displayMessage:(NSString *)msg
{
    if (alert) return;
    [self stop];
    alert = [[UIAlertView alloc] initWithTitle:@"Game"
                                       message:msg
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil];
    [alert show];
}

- (void)newGame
{
    [self reset];
    self.viewScore1.text = [NSString stringWithFormat:@"0"];
    self.viewScore2.text = [NSString stringWithFormat:@"0"];
    [self displayMessage:@"Ready to play?"];
}

- (int)gameOver
{
    if (self.computer < 4)
    {
        if ([self.viewScore1.text intValue] >= MAX_SCORE_1) return 1;
        if ([self.viewScore2.text intValue] >= MAX_SCORE_1) return 2;
    }
    else
    {
        if ([self.viewScore1.text intValue] >= MAX_SCORE_2) return 1;
        if ([self.viewScore2.text intValue] >= MAX_SCORE_2) return 2;
    }
    return 0;
}

- (BOOL)checkGoal
{
    if (puck.winner != 0) {
        int s1 = [self.viewScore1.text intValue];
        int s2 = [self.viewScore2.text intValue];
        
        if (puck.winner == 2) ++s2; else ++s1;
        
        self.viewScore1.text = [NSString stringWithFormat:@"%u", s1];
        self.viewScore2.text = [NSString stringWithFormat:@"%u", s2];
        
        if ([self gameOver] == 1) [self displayMessage:@"Player 1 has won!"];
        else if ([self gameOver] == 2) [self displayMessage:@"Player 2 has won!"];
        else [self reset];
        
        return TRUE;
    }
    return FALSE;
}

- (void)computerAI
{
    if (state == AI_START)
    {
        self.stateLabel1.text = @"Старт";
        if (paddle2.speed > 0 || (arc4random_uniform(100/self.computer)) == 1)
        {
            state = AI_WAIT;
        }
    }
    else if (state == AI_WAIT)
    {
        //  исправление, исключающее ситуацию, в которой
        //  компьютер блокирует шайбу в углу
        if ([paddle1 intersects:self.viewPuck.frame])
        {
            state = AI_BORED;
            return;
        }
        if (paddle1.speed == 0)
        {
            paddle1.maxSpeed = MAX_SPEED;
            
            int r = 0;
            if (self.computer < 4)
            {
                r = arc4random_uniform((4 - self.computer) * 4);
            }
            else
            {
                r = arc4random_uniform((10 - self.computer) * 4);
            }
            
            if (r == 1)
            {
                if (puck.center.y <= 284 && puck.speed < self.computer)
                {
                    if (self.computer == 1) state = AI_OFFENSE2;
                    else state = AI_OFFENSE;
                }
                else if (puck.speed >= 1 && puck.dy < 0)
                {
                    state = AI_DEFENSE;
                }
                else
                {
                    state = AI_BORED;
                }
            }
        }
    }
    else if (state == AI_OFFENSE)
    {
        if (self.computer < 3)
        {
            paddle1.maxSpeed = MAX_SPEED / 2;
        }
        float x = puck.center.x - 64 + arc4random_uniform(129);
        float y = puck.center.y - 64 - arc4random_uniform(65);
        [paddle1 move:CGPointMake(x, y)];
        state = AI_OFFENSE2;
    }
    else if (state == AI_OFFENSE2)
    {
        self.stateLabel1.text = @"Бью";
        if (self.computer == 1)
        {
            paddle1.maxSpeed = MAX_SPEED / 2;
        }
        else if (self.computer == 2)
        {
            paddle1.maxSpeed = MAX_SPEED * 3/4;
        }
        [paddle1 move:puck.center];
        state = AI_WAIT;
    }
    else if (state == AI_DEFENSE)
    {
        self.stateLabel1.text = @"Защищаюсь";
        float offset  = ((puck.center.x - 160.0) / 160.0) * 40;
        [paddle1 move:CGPointMake(puck.center.x - offset, puck.center.y / 2)];
        if (puck.speed < 1 || puck.dy > 0)
        {
           state = AI_WAIT;
        }
        if (self.computer == 1 || self.computer == 4)
        {
            paddle1.maxSpeed = MAX_SPEED / 3;
        }
        else if (self.computer == 2)
        {
            paddle1.maxSpeed = MAX_SPEED * 2/5;
        }
        else if (self.computer == 3)
        {
            paddle1.maxSpeed = MAX_SPEED / 2;
        }
    }
    else if (state == AI_BORED)
    {
        if (paddle1.speed == 0)
        {
            self.stateLabel1.text = @"Жду";
            
            if (self.computer == 1 || self.computer == 4)
            {
                paddle1.maxSpeed = MAX_SPEED / 3;
            }
            else if (self.computer == 2)
            {
                paddle1.maxSpeed = MAX_SPEED * 2/3;
            }
            else if (self.computer == 3)
            {
                paddle1.maxSpeed = MAX_SPEED;
            }
            
            int inset = 0;
            if (self.computer < 4)
            {
                inset = (self.computer - 1) * 20;
            }
            else
            {
                inset = (self.computer - 2) * 20;
            }

            float x = (gPlayerBox[0].origin.x + inset) + arc4random_uniform((int)gPlayerBox[0].size.width - inset * 2);
            float y = gPlayerBox[0].origin.y + arc4random_uniform((int)gPlayerBox[0].size.height - inset);
            [paddle1 move:CGPointMake(x, y)];
            state = AI_WAIT;
        }
    }
}

- (void)computerAII
{
    if (state == AI_START)
    {
        self.stateLabel2.text = @"Старт";
        if (paddle1.speed > 0 || (arc4random_uniform(100/self.computer)) == 1)
        {
            state = AI_WAIT;
        }
    }
    else if (state == AI_WAIT)
    {
        //  исправление, исключающее ситуацию, в которой
        //  компьютер блокирует шайбу в углу
        if ([paddle2 intersects:self.viewPuck.frame])
        {
            state = AI_BORED;
            return;
        }
        if (paddle2.speed == 0)
        {
            paddle2.maxSpeed = MAX_SPEED;
            
            int r = arc4random_uniform((10 - self.computer) * 4);
            
            if (r == 1)
            {
                if (puck.center.y >= 284 && puck.speed < self.computer)
                {
                    state = AI_OFFENSE;
                }
                else if (puck.speed >= 1 && puck.dy > 0)
                {
                    state = AI_DEFENSE;
                }
                else
                {
                    state = AI_BORED;
                }
            }
        }
    }
    else if (state == AI_OFFENSE)
    {
        float x = puck.center.x - 64 + arc4random_uniform(129);
        float y = puck.center.y + 64 + arc4random_uniform(65);
        [paddle2 move:CGPointMake(x, y)];
        state = AI_OFFENSE2;
    }
    else if (state == AI_OFFENSE2)
    {
        self.stateLabel2.text = @"Бью";
        [paddle2 move:puck.center];
        state = AI_WAIT;
    }
    else if (state == AI_DEFENSE)
    {
        self.stateLabel2.text = @"Защищаюсь";
        float offset  = ((puck.center.x - 160.0) / 160.0) * 40;
        [paddle2 move:CGPointMake(puck.center.x - offset, ((CGRectGetHeight(self.view.frame) - puck.center.y) / 2) + puck.center.y)];
        if (puck.speed < 1 || puck.dy < 0)
        {
            state = AI_WAIT;
        }
        paddle2.maxSpeed = MAX_SPEED / 3;
    }
    else if (state == AI_BORED)
    {
        if (paddle2.speed == 0)
        {
            self.stateLabel2.text = @"Жду";
            
            paddle2.maxSpeed = MAX_SPEED / 3;
            int inset = (self.computer - 2) * 20;
            
            float x = (gPlayerBox[1].origin.x + inset) + arc4random_uniform((int)gPlayerBox[1].size.width - inset * 2);
            float y = gPlayerBox[1].origin.y + inset + arc4random_uniform((int)gPlayerBox[1].size.height - inset);
            [paddle2 move:CGPointMake(x, y)];
            state = AI_WAIT;
        }
    }
}

- (void)animate
{
    if (self.computer)
    {
        [self computerAI];
        if (self.computer == 4)
        {
            [self computerAII];
        }
    }
    [paddle1 animate];
    [paddle2 animate];
    if ([puck handleCollision:paddle1] || [puck handleCollision:paddle2])
        [self playSound:SOUND_PADDLE];
    
    if ([puck animate])
        [self playSound:SOUND_WALL];
    
    if ([self checkGoal])
        [self playSound:SOUND_SCORE];
}

- (void)pause
{
    [self stop];
}

- (void)resume
{
    [self displayMessage:@"Game paused"];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSounds];
 
    for (int i = 0; i < 2; i++)
    {
        // отладочный код для отображения рамки,
        // в которой может действовать игрок
        UIView *viewBoxPaddle = [[UIView alloc] initWithFrame:gPlayerBox[i]];
        viewBoxPaddle.backgroundColor = [UIColor blueColor];
        viewBoxPaddle.alpha = 0.05;
        [self.view addSubview:viewBoxPaddle];
        
        // отладочный код для отображения рамки ворот
        UIView *viewBoxPuck = [[UIView alloc] initWithFrame:gGoalBox[i]];
        viewBoxPuck.backgroundColor = [UIColor blueColor];
        viewBoxPuck.alpha = 0.05;
        [self.view addSubview:viewBoxPuck];
    }
    //  создаем вспомогательные контроллеры клюшек
    paddle1 = [[Paddle alloc] initWithView:self.viewPaddle1
                                  Boundary:gPlayerBox[0]
                                  MaxSpeed:MAX_SPEED];
    
    paddle2 = [[Paddle alloc] initWithView:self.viewPaddle2
                                  Boundary:gPlayerBox[1]
                                  MaxSpeed:MAX_SPEED];
    
    puck = [[Puck alloc] initWithPuck:self.viewPuck
                             Boundary:gPuckBox
                                Goal1:gGoalBox[0]
                                Goal2:gGoalBox[1]
                             MaxSpeed:MAX_SPEED];
    [self newGame];
    if (self.computer == 0)
    {
        self.stateLabel1.enabled = NO;
        self.stateLabel1.hidden = YES;
    }
    self.paused = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    for (int i = 0; i < 3; i++)
    {
        AudioServicesDisposeSystemSoundID(sounds[i]);
    }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self.view];
        
        if (paddle1.touch == nil && touchPoint.y < 284 && self.computer == 0)
        {
            touchPoint.y += 48;
            paddle1.touch = touch;
            [paddle1 move:touchPoint];
            
        } else if (paddle2.touch == nil && touchPoint.y > 284)
        {
            touchPoint.y -= 32;
            paddle2.touch = touch;
            [paddle2 move:touchPoint];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (paddle1.touch == touch)
        {
            touchPoint.y += 48;
            [paddle1 move:touchPoint];
        } else if (paddle2.touch == touch)
        {
            touchPoint.y -= 32;
            [paddle2 move:touchPoint];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if (paddle1.touch == touch) paddle1.touch = nil;
            else if (paddle2.touch == touch) paddle2.touch = nil;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        [self pause];
        [self resume];
    }
}
/*
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        NSLog(@"motionEnded");
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake) 
    {
        NSLog(@"motionCancelled");
    }
}
*/
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alert = nil;
    if ([self gameOver])
    {
        PaddlesAppDelegate *app = (PaddlesAppDelegate *)[UIApplication sharedApplication].delegate;
        [app showTitle];
        return;
    }
    [self reset];
    [self start];
}

#pragma mark - IBAction

- (IBAction)pauseButton:(id)sender
{
    if (self.paused == NO)
    {
        self.paused = YES;
        UIImage *imagePressed = [UIImage imageNamed:@"pausepressed.png"];
        [self.pausedButton setImage:imagePressed forState:UIControlStateNormal];
        [self stop];
    }
    else
    {
        self.paused = NO;
        UIImage *imageNormal = [UIImage imageNamed:@"pausenormal.png"];
        [self.pausedButton setImage:imageNormal forState:UIControlStateNormal];
        [self start];
    }
}
@end

































