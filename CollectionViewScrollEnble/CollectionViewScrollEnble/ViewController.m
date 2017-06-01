//
//  ViewController.m
//  collectionViewScroll
//
//  Created by miki on 2017/5/31.
//  Copyright © 2017年 kingbom. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    NSMutableArray      *_dataSource;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectioview;

@property (nonatomic,strong)UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) BOOL isShake;
@property (nonatomic, assign) BOOL state;
- (void)addGesture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"collectionview";
    
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStylePlain target:self action:@selector(managerBarButtonItemPressed:)];
        item;
    });
    _dataSource = [[NSMutableArray alloc] initWithArray:@[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg",@"7.jpg",@"8.jpg",@"9.jpg",@"10.jpg",@"11.jpg",@"12.jpg",@"13.jpg",@"14.jpg",@"15.jpg",@"16.jpg",@"17.jpg",@"18.jpg",@"19.jpg",@"20.jpg"]];
    
    [self addGesture];
}

- (void)addGesture {
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
        _longPressGesture.minimumPressDuration = 1.0;
    }
    _state = YES;
    [self.collectioview addGestureRecognizer:_longPressGesture];
}

#pragma mark - <UICollectionViewDataSource>/<UICollectionViewDelegate>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"scrollCollectionViewCell" forIndexPath:indexPath];
    ((UIImageView *)[cell viewWithTag:1]).image = [UIImage imageNamed:_dataSource[indexPath.row]];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width / 2.5, [[UIScreen mainScreen] bounds].size.width / 2.5);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id obj = [_dataSource objectAtIndex:sourceIndexPath.row];
    [_dataSource removeObjectAtIndex:sourceIndexPath.row];
    [_dataSource insertObject:obj atIndex:destinationIndexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // 抖动
    UIImageView *imageView = [cell viewWithTag:1];
    if (_isShake) {
        CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
        keyAnimation.keyPath = @"transform.rotation";
        keyAnimation.values = @[@(-0.03),@(0.03)];
        keyAnimation.repeatCount = MAXFLOAT;
        keyAnimation.duration = 0.3f;
        [imageView.layer addAnimation:keyAnimation forKey:@"keyAnimation"];
    }else if (!_isShake){
        [imageView.layer removeAllAnimations];
    }
}

#pragma mark - 管理
- (void)managerBarButtonItemPressed:(UIBarButtonItem *)item {
    if ([item.title isEqualToString:@"管理"]) {
        self.navigationItem.rightBarButtonItem.title = @"完成";
        [self.collectioview addGestureRecognizer:_longPressGesture];
        [self shake];
    } else {
        [self cancelShake];
        self.navigationItem.rightBarButtonItem.title = @"管理";
    }
    
}


#pragma mark 抖动效果
- (void)shake{
    self.collectioview.allowsSelection = NO;
    _isShake = YES;
    _state = NO;
    [self.collectioview reloadData];
}
- (void)cancelShake{
    self.collectioview.allowsSelection = YES;
    _isShake = NO;
    _state = YES;
    [self.collectioview reloadData];
}

- (void)handleLongGesture:(UILongPressGestureRecognizer *)longGesture {
    
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [self.collectioview indexPathForItemAtPoint:[longGesture locationInView:self.collectioview]];
            if (indexPath == nil || _state == YES) {
                if (_state == YES) {
                    [self shake];
                    self.navigationItem.rightBarButtonItem.title = @"完成";
                }
                break;
            }
            //在路径上则开始移动该路径上的cell
            [self.collectioview beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
            //移动过程当中随时更新cell位置
            [self.collectioview updateInteractiveMovementTargetPosition:[longGesture locationInView:self.collectioview]];
            break;
        case UIGestureRecognizerStateEnded:
            //移动结束后关闭cell移动
            [self.collectioview endInteractiveMovement];
            break;
        default:
            [self.collectioview cancelInteractiveMovement];
            break;
    }
}
@end
