//
//  Paddle.h
//  AirHockey
//
//  Created by Pavel Samsonov on 06.01.16.
//  Copyright (c) 2016 Samsonov Pavel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Paddle : NSObject
{
    UIView *view;                           //  вид клюшки с текущей позиции
    CGRect boundary;                        //  граница
    CGPoint pos;                            //  позиция, в которую передвинется клюшка
    float maxSpeed;                         //  максимальная скорость
    float speed;                            //  актуальная  скорость
    __unsafe_unretained UITouch *touch;     //  касание, присвоенное данной клюшке
}
@property (assign, nonatomic) UITouch *touch;
@property (readonly, nonatomic) float speed;
@property (assign, nonatomic) float maxSpeed;

//  инициализируем объект
- (id)initWithView:(UIView *)paddle Boundary:(CGRect)rect MaxSpeed:(float)max;

//  сбрасываем позицию до середины границы
- (void)reset;

//  указываем, куда должна попасть шайба
- (void)move:(CGPoint)pt;

//  центральная точка клюшки
- (CGPoint)center;

//  проверяем, пересекается ли клюшка с прямоугольником
- (BOOL)intersects:(CGRect)rect;

//  получаем расстояние между актуальной позицией клюшки и точкой
- (float)distance:(CGPoint)pt;

//  анимируем вид шайбы - она летит к указанной точке
//  не превышая максимальной скорости
- (void)animate;

@end
