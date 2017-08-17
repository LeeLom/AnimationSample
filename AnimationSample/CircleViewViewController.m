//
//  CircleViewViewController.m
//  AnimationSample
//
//  Created by LeeLom on 2017/8/17.
//  Copyright © 2017年 LeeLom. All rights reserved.
//

#import "CircleViewViewController.h"
#import "CircleView.h"

@interface CircleViewViewController ()

@property (strong, nonatomic) IBOutlet UILabel *currentLabel;
@property (strong, nonatomic) IBOutlet UISlider *mySlider;
@property (strong, nonatomic) CircleView *cv;


@end

@implementation CircleViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cv = [[CircleView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 320/2, self.view.frame.size.height/2 - 320/2, 320, 320)];
    [self.view addSubview:self.cv];
    
    _cv.circleLayer.progress = _mySlider.value;
}

- (IBAction)valueChanged:(UISlider *)sender {
    _currentLabel.text = [NSString stringWithFormat:@"Current: %f", sender.value];
    _cv.circleLayer.progress = sender.value;
}


@end
