//
//  UICollectionViewFlowLayout+CTStickyHeader.h
//  CTFlowLayoutDemo
//
//  Created by wenjie on 2017/10/31.
//  Copyright © 2017年 Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewFlowLayout (CTStickyHeader)

/**
 是否可以吸顶(默认是不可以)
 */
@property (nonatomic, assign) BOOL ct_stickyEnable;

/**
 距离顶部增加额外高度(默认是0吸顶在导航栏下)
 */
@property (nonatomic, assign) CGFloat ct_stickyExtraTop;

/**
 设置某个section的Header的吸顶(只有设置的section吸顶，其他section都不吸顶)
 */
@property (nonatomic, assign) NSInteger ct_stickSingleSection;

/**
 注：如果遇到 ：删除、插入、contentOffset、content时候需要手动执行
 [self.collectionView.collectionViewLayout invalidateLayout];
 */

@end

