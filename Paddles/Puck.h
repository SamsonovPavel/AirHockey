//
//  Puck.h
//  AirHockey
//
//  Created by Pavel Samsonov on 09.01.16.
//  Copyright (c) 2016 Samsonov Pavel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paddle.h"

@interface Puck : NSObject
{
    UIView *view;       //  вид шайбы, управляемый данныйм объектом,
    CGRect rect[3];     //  содержит ограничивающие прямоугольники,
                        //  а также ворота goal1 и goal2
    int box;            //  рамка, к которой относится шайба (индекс в rect)
    float maxSpeed;     //  максимальная скорость шайбы
    float speed;        //  текущая скорость шайбы
    float dx, dy;       //  текущее направление шайбы
    int winner;         //  объявленный победитель
                        //  (0 - победитель отсутствует, 1 - очко заработал 1 - й игрок,
                        //  2 - очко заработал 2 - й игрок)
}
//  свойства шайбы, доступные только для чтения
@property (readonly, nonatomic) float maxSpeed;
@property (readonly, nonatomic) float speed;
@property (readonly, nonatomic) float dx;
@property (readonly, nonatomic) float dy;
@property (readonly, nonatomic) int winner;

//  инициализация объекта
- (id)initWithPuck:(UIView *)puck
          Boundary:(CGRect)boundary
             Goal1:(CGRect)goal1
             Goal2:(CGRect)goal2
          MaxSpeed:(float)max;

//  сбрасываем положение шайбы, устанавливаем ее в
//  центре ограничивающего прямоугольника
- (void)reset;

//  возвращаем актуальную центральную позицию шайбы
- (CGPoint)center;

//  анимируем шайбу и возвращаем true, если шайба ударилась о стенку
- (BOOL)animate;

//  проверяем, произошло ли соударение с клюшкой, если так -
//  изменяем направление движения шайбы
- (BOOL)handleCollision:(Paddle *)paddle;

@end

























