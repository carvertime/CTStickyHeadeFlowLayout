//
//  ViewController.m
//  CTFlowLayoutDemo
//
//  Created by wenjie on 2017/10/31.
//  Copyright © 2017年 Demo. All rights reserved.
//

#import "ViewController.h"
#import "UICollectionViewFlowLayout+CTStickyHeader.h"
#import "TestCell.h"
#import "TestReusableView.h"
#import <objc/runtime.h>

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *headerData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.data = @[].mutableCopy;
    self.headerData = @[].mutableCopy;
    for (int i = 0; i<10; i++) {
        NSMutableArray *subAry = @[].mutableCopy;
        [self.headerData addObject:[NSString stringWithFormat:@"第%zd组header",i]];
        for (int j = 0; j < 10; j++) {
            [subAry addObject:[NSString stringWithFormat:@"第%zd组 第%zditem",i,j]];
            [subAry addObject:[NSString stringWithFormat:@"第%zd组 第%zditem",i,j]];
        }
        [self.data addObject:subAry.copy];
    }
    [self.collectionView registerClass:[NSClassFromString(@"TestCell") class] forCellWithReuseIdentifier:@"TestCell"];
    [self.collectionView registerClass:[NSClassFromString(@"TestReusableView") class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TestReusableView"];
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TestCell *cell = (TestCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TestCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor purpleColor];
    [cell updateWithItem:self.data[indexPath.section][indexPath.item]];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.data[section] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 80);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 150);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        TestReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TestReusableView" forIndexPath:indexPath];
        [reusableView updateWithItem:self.headerData[indexPath.section]];
        return reusableView;
    }
    return nil;
}


- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.ct_stickyEnable = YES;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 150) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

@end
