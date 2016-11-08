//
//  Puck.m
//  AirHockey
//
//  Created by Pavel Samsonov on 09.01.16.
//  Copyright (c) 2016 Samsonov Pavel. All rights reserved.
//

#import "Puck.h"

@implementation Puck

@synthesize maxSpeed, speed, dx, dy, winner;

- (id)initWithPuck:(UIView *)puck
          Boundary:(CGRect)boundary
             Goal1:(CGRect)goal1
             Goal2:(CGRect)goal2
          MaxSpeed:(float)max
{
    self = [super init];
    if (self)
    {
        view = puck;
        rect[0] = boundary;
        rect[1] = goal1;
        rect[2] = goal2;
        maxSpeed = max;
    }
    return self;
}

//  сброс к начальной позиции
- (void)reset
{
    float x = rect[1].origin.x + arc4random_uniform((int)rect[1].size.width);
    float y = rect[0].origin.y + rect[0].size.height / 2;
    view.center = CGPointMake(x, y);
    box = 0;
    speed = 0;
    dx = 0;
    dy = 0;
    winner = 0;
}

- (CGPoint)center
{
    return view.center;
}

- (BOOL)animate
{
    if (winner != 0) return false;
    BOOL hit = false;
    
    if (speed > 0)
    {
        speed = speed * 0.99;
        if(speed < 0.1) speed = 0.1;
    }
    CGPoint pos = CGPointMake(view.center.x + dx * speed,
                              view.center.y + dy * speed);
    
    if (box == 0 && CGRectContainsPoint(rect[1], pos))
    {
        box = 1;
    }
    else if (box == 0 && CGRectContainsPoint(rect[2], pos))
    {
        box = 2;
    }
    else if (CGRectContainsPoint(rect[box], pos) == false)
    {
        if (pos.x < rect[box].origin.x)
        {
            pos.x = rect[box].origin.x;
            dx = fabs(dx);
            hit = true;
        }
        else if (pos.x > rect[box].origin.x + rect[box].size.width)
        {
            pos.x = rect[box].origin.x + rect[box].size.width;
            dx = - fabs(dx);
            hit = true;
        }
        if (pos.y < rect[box].origin.y)
        {
            pos.y = rect[box].origin.y;
            dy = fabs(dy);
            hit = true;
            if (box == 1) winner = 2;
        }
        else if (pos.y > rect[box].origin.y + rect[box].size.height)
        {
            pos.y = rect[box].origin.y + rect[box].size.height;
            dy = - fabs(dy);
            hit = false;
            if (box == 2) winner = 1;
        }
    }
    view.center = pos;
    return hit;
}

- (BOOL)handleCollision:(Paddle *)paddle
{
    static float maxDistance = 52.0;
    float currentDistance = [paddle distance:view.center];
    if (currentDistance <= maxDistance)
    {
        dx = (view.center.x - paddle.center.x) / 32.0;
        dy = (view.center.y - paddle.center.y) / 32.0;
        speed = 0.2 + speed / 2 + paddle.speed;
        if (speed > maxSpeed) speed = maxSpeed;
        float r = atan2(dy, dx);
        float x = paddle.center.x + cos(r) * (maxDistance + 1);
        float y = paddle.center.y + sin(r) * (maxDistance + 1);
        view.center = CGPointMake(x, y);
        return true;
    }
    return false;
}

@end
































