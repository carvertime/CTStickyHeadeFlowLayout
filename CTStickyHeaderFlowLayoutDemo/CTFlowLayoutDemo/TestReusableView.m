//
//  TestReusableView.m
//  CTFlowLayoutDemo
//
//  Created by wenjie on 2017/10/31.
//  Copyright © 2017年 Demo. All rights reserved.
//

#import "TestReusableView.h"

@interface TestReusableView ()

@property (nonatomic, strong) UILabel *titleLb;

@end

@implementation TestReusableView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLb = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLb.text = @"吸顶Header";
        self.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.titleLb];
    }
    return self;
}

- (void)updateWithItem:(NSString *)item{
    self.titleLb.text = item;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLb.frame = self.bounds;
}

@end
