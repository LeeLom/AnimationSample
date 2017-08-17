//
//  CircleLayer.m
//  AnimationSample
//
//  Created by LeeLom on 2017/8/17.
//  Copyright © 2017年 LeeLom. All rights reserved.
//

#import "CircleLayer.h"
#import <UIKit/UIKit.h>

// 定义了移动点
typedef enum MovingPoint {
    POINT_D,
    POINT_B,
} MovingPoint;

// 定义了外接举行的长宽
#define outsideRectSize 90

@interface CircleLayer()

@property (nonatomic, assign) CGRect outsideRect; // 外接矩形
@property (nonatomic, assign) CGFloat lastProgress; // 记录上次的progress, 方便做差得出滑动方向
@property (nonatomic, assign) MovingPoint movePoint; // 实时记录滑动方向

@end

@implementation CircleLayer

- (id)init {
    self = [super init];
    if (self) {
        _lastProgress = 0.5;
    }
    return self;
}

- (id)initWithLayer:(CircleLayer *)layer {
    self = [super initWithLayer:layer];
    if (self) {
        _progress = layer.progress;
        _outsideRect = layer.outsideRect;
        _lastProgress = layer.lastProgress;
    }
    return self;
}


/**
 重写progress的设置方法。通过正方形的原点位置的来自控制曲线的变化

 @param progress UISlider的值
 */
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    // 确定移动的点。
    // 理解：左边滑动，相当于往左边拽皮球，则球的右边会发生形变，那么移动的点当时就是右边的点（B点）
    if (progress <= 0.5) {
        _movePoint = POINT_B;
    } else {
        _movePoint = POINT_D;
    }
    
    // 保存上次设置的progress
    _lastProgress = progress;
    
    // 设置正方形的坐标位置(不是外接矩形)
    CGFloat origin_x = self.position.x - outsideRectSize/2 + (progress - 0.5) * (self.frame.size.width - outsideRectSize);
    CGFloat origin_y = self.position.y - outsideRectSize/2;
    _outsideRect = CGRectMake(origin_x, origin_y, outsideRectSize, outsideRectSize);
    
    [self setNeedsDisplay];// 由于调用了setNeedsDisplay，因此会执行drawInContext:方法
}


/**
 覆盖该方法，实时显示变化

 @param ctx 对象
 */
- (void)drawInContext:(CGContextRef)ctx {
    // 设置offset 以及每次都会变化的movedDistance
    CGFloat offset = _outsideRect.size.width / 3.6;
    CGFloat movedDistance = (_outsideRect.size.width * 1 / 6) * fabs(_progress - 0.5) * 2;
    
    // 现在，开始计算外接矩形坐标，也就是每次都会变化的内部矩形
    CGPoint rectCenter = CGPointMake(_outsideRect.origin.x + _outsideRect.size.width/2,
                                     _outsideRect.origin.y + _outsideRect.size.height/2);// 其实是就是正方形的长宽
    CGPoint pointA = CGPointMake(rectCenter.x, _outsideRect.origin.y + movedDistance);
    CGPoint pointB = CGPointMake(_movePoint == POINT_D ?
                                 rectCenter.x + _outsideRect.size.width/2 :
                                 rectCenter.x + _outsideRect.size.width/2 + movedDistance*2,
                                 rectCenter.y);
    CGPoint pointC = CGPointMake(rectCenter.x,
                                 rectCenter.y + _outsideRect.size.height/2 - movedDistance);
    CGPoint pointD = CGPointMake(_movePoint == POINT_D ?
                                 rectCenter.x - _outsideRect.size.width/2 - movedDistance*2 :
                                 rectCenter.x - _outsideRect.size.width/2,
                                 rectCenter.y);
    
    CGPoint c1 = CGPointMake(pointA.x + offset, pointA.y);
    CGPoint c2 = CGPointMake(pointB.x,
                             _movePoint == POINT_D ?
                             pointB.y - offset :
                             pointB.y - offset + movedDistance);
    CGPoint c3 = CGPointMake(pointB.x,
                             _movePoint == POINT_D ?
                             pointB.y + offset :
                             pointB.y + offset - movedDistance);
    
    CGPoint c4 = CGPointMake(pointC.x + offset, pointC.y);
    CGPoint c5 = CGPointMake(pointC.x - offset, pointC.y);
    CGPoint c6 = CGPointMake(pointD.x,
                             _movePoint == POINT_D ?
                             pointD.y + offset - movedDistance:
                             pointD.y + offset);
    CGPoint c7 = CGPointMake(pointD.x,
                             _movePoint == POINT_D ?
                             pointD.y - offset + movedDistance:
                             pointD.y - offset);
    CGPoint c8 = CGPointMake(pointA.x - offset, pointA.y);
    
    // 开始画正方形
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:_outsideRect];
    CGContextAddPath(ctx, rectPath.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGFloat dash[] = {5.0, 5.0};
    CGContextSetLineDash(ctx, 0.0, dash, 2);
    CGContextStrokePath(ctx);
    
    // 开始椭圆
    UIBezierPath *ovalPath = [UIBezierPath bezierPath];
    [ovalPath moveToPoint:pointA];
    [ovalPath addCurveToPoint:pointB controlPoint1:c1 controlPoint2:c2];
    [ovalPath addCurveToPoint:pointC controlPoint1:c3 controlPoint2:c4];
    [ovalPath addCurveToPoint:pointD controlPoint1:c5 controlPoint2:c6];
    [ovalPath addCurveToPoint:pointA controlPoint1:c7 controlPoint2:c8];
    [ovalPath closePath];
    
    CGContextAddPath(ctx, ovalPath.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetLineDash(ctx, 0.0, NULL, 0);
    CGContextDrawPath(ctx, kCGPathFillStroke); // 同时给线条和线条保卫的内部区域填充颜色
    
    // 连接椭圆的辅助线
    UIBezierPath *helperPath = [UIBezierPath bezierPath];
    [helperPath moveToPoint:pointA];
    [helperPath addLineToPoint:c1];
    [helperPath addLineToPoint:c2];
    [helperPath addLineToPoint:pointB];
    [helperPath addLineToPoint:c3];
    [helperPath addLineToPoint:c4];
    [helperPath addLineToPoint:pointC];
    [helperPath addLineToPoint:c5];
    [helperPath addLineToPoint:c6];
    [helperPath addLineToPoint:pointD];
    [helperPath addLineToPoint:c7];
    [helperPath addLineToPoint:c8];
    [helperPath closePath];
    
    CGContextAddPath(ctx, helperPath.CGPath);
    CGFloat dash2[] = {2.0, 2.0};// 虚线更加密集
    CGContextSetLineDash(ctx, 0.0, dash2, 2);
    CGContextStrokePath(ctx);
    
    // 为各个点添加黄色点进行标注
    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    NSArray *points = @[[NSValue valueWithCGPoint:pointA],
                        [NSValue valueWithCGPoint:pointB],
                        [NSValue valueWithCGPoint:pointC],
                        [NSValue valueWithCGPoint:pointD],
                        [NSValue valueWithCGPoint:c1],
                        [NSValue valueWithCGPoint:c2],
                        [NSValue valueWithCGPoint:c3],
                        [NSValue valueWithCGPoint:c4],
                        [NSValue valueWithCGPoint:c5],
                        [NSValue valueWithCGPoint:c6],
                        [NSValue valueWithCGPoint:c7],
                        [NSValue valueWithCGPoint:c8]];
    [self drawPoint:points withContext:ctx];
}


/**
 标记每一个点，将所有的关键点染成黄色，辅助线黑色

 */
- (void)drawPoint:(NSArray *)points withContext:(CGContextRef)ctx {
    for (NSValue *pointValue in points) {
        CGPoint point = [pointValue CGPointValue];
        CGContextFillRect(ctx, CGRectMake(point.x - 2, point.y - 2, 4, 4));
    }
}

@end
