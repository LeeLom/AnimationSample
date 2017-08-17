//
//  CircleView.m
//  AnimationSample
//
//  Created by LeeLom on 2017/8/17.
//  Copyright © 2017年 LeeLom. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

+ (Class)layerClass {
    return [CircleLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _circleLayer = [CircleLayer layer];
        _circleLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        //关于contentScale: http://joeshang.github.io/2015/01/10/understand-contentsscale/
        _circleLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_circleLayer];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
