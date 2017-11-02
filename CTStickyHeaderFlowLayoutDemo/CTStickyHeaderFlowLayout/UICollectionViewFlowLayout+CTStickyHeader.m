//
//  UICollectionViewFlowLayout+CTStickyHeader.m
//  CTFlowLayoutDemo
//
//  Created by wenjie on 2017/10/31.
//  Copyright © 2017年 Demo. All rights reserved.
//

#import "UICollectionViewFlowLayout+CTStickyHeader.h"
#import <objc/runtime.h>

@implementation UICollectionViewFlowLayout (CTStickyHeader)

+ (void)load{
    SEL originalSelector = @selector(layoutAttributesForElementsInRect:);
    SEL swizzledSelector = @selector(ct_layoutAttributesForElementsInRect:);
    [self exchangeOriginal:originalSelector swizzledSelector:swizzledSelector];
}

- (instancetype)init{
    if (self = [super init]) {
        self.ct_stickSingleSection = -1;
    }
    return self;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)ct_layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *oldElements = [self ct_layoutAttributesForElementsInRect:rect];
    if (!self.ct_stickyEnable) {
        return oldElements;
    }
    
    NSMutableArray *newElements = oldElements.mutableCopy;
    NSMutableArray *headerIndexs = @[].mutableCopy;
    NSMutableArray *cellIndexs = @[].mutableCopy;
    
    [newElements enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [headerIndexs addObject:@(attributes.indexPath.section)];
        } else if (attributes.representedElementCategory == UICollectionElementCategoryCell){
            [cellIndexs addObject:@(attributes.indexPath.section)];
        }
    }];
    
    [cellIndexs enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![headerIndexs containsObject:index]) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:index.integerValue]];
            if (attributes) {
                [newElements addObject:attributes];
            }
        }
    }];
    
    __block BOOL flag = NO;
    [newElements enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewLayoutAttributes *attributes = obj;
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            if (!CGSizeEqualToSize(attributes.size, CGSizeZero)) {
                if (self.ct_stickSingleSection >= 0) {
                    if (self.ct_stickSingleSection == attributes.indexPath.section) {
                        flag = YES;
                        [self updateAttributes:attributes];
                    }
                } else {
                    flag = YES;
                    [self updateAttributes:attributes];
                }
            }
        }
    }];
    
    if (!flag && self.ct_stickSingleSection >= 0) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.ct_stickSingleSection]];
        [self updateAttributes:attributes];
        [newElements addObject:attributes];
    }
    return newElements.copy;
}

- (void)updateAttributes:(UICollectionViewLayoutAttributes *)attributes{
    
    CGRect frame = attributes.frame;
    NSIndexPath *indexPath = attributes.indexPath;
    NSInteger section = indexPath.section;
    NSInteger count = [self.collectionView numberOfItemsInSection:section];
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:MAX(0, count-1) inSection:section];
    
    UICollectionViewLayoutAttributes *firstAttributes;
    UICollectionViewLayoutAttributes *lastAttributes;
    UICollectionViewLayoutAttributes *lastHeaderAttributes;
    if (count == 0) {
        firstAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:firstIndexPath];
        firstAttributes.frame = CGRectMake(0, CGRectGetMaxY(attributes.frame)+self.sectionInset.top, 0, 0);
        lastAttributes = firstAttributes.copy;
    } else {
        firstAttributes = [self layoutAttributesForItemAtIndexPath:firstIndexPath];
        lastAttributes = [self layoutAttributesForItemAtIndexPath:lastIndexPath];
    }
    if (section+1 < [self.collectionView numberOfSections]) {
        lastHeaderAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section+1]];
    }
    
    CGFloat insetT = self.collectionView.contentInset.top;
    CGFloat originY = firstAttributes.frame.origin.y - frame.size.height;
    CGFloat offsetY = self.collectionView.contentOffset.y;
    if (@available(iOS 11.0,*)) {
        insetT = self.collectionView.adjustedContentInset.top;
    }
    CGFloat newY = MAX(offsetY+insetT+self.ct_stickyExtraTop, originY);
    
    if (CGSizeEqualToSize(CGSizeZero, lastHeaderAttributes.frame.size)) {
        frame.origin.y = newY;
    } else {
        if (self.ct_stickSingleSection == attributes.indexPath.section) {
            frame.origin.y = newY;
        } else {
            CGFloat lastY = CGRectGetMaxY(lastAttributes.frame)-frame.size.height;
            frame.origin.y = MIN(lastY, newY);
        }
    }
    attributes.frame = frame;
    attributes.zIndex = 1024;
}

+ (void)exchangeOriginal:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (CGFloat)ct_stickyExtraTop{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setCt_stickyExtraTop:(CGFloat)ct_stickyExtraTop{
    objc_setAssociatedObject(self, @selector(ct_stickyExtraTop), @(ct_stickyExtraTop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ct_stickyEnable{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setCt_stickyEnable:(BOOL)ct_stickyEnable{
    objc_setAssociatedObject(self, @selector(ct_stickyEnable), @(ct_stickyEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)ct_stickSingleSection{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setCt_stickSingleSection:(NSInteger)ct_stickSingleSection{
    objc_setAssociatedObject(self, @selector(ct_stickSingleSection), @(ct_stickSingleSection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




@end

