//
//  TestCell.m
//  CTFlowLayoutDemo
//
//  Created by wenjie on 2017/10/31.
//  Copyright © 2017年 Demo. All rights reserved.
//

#import "TestCell.h"

@interface TestCell ()

@property (nonatomic, strong) UILabel *titleLb;

@end

@implementation TestCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLb = [[UILabel alloc] initWithFrame:CGRectZero];
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLb];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLb.frame = self.bounds;
}

- (void)updateWithItem:(NSString *)item{
    self.titleLb.text = item;
}

@end
