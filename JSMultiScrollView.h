//
//  JSMultiScrollView.h
//  StackOverflow
//
//  Created by Justin Saletta on 9/12/14.
//  Copyright (c) 2014 jsdodgers. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JSMultiScrollView : UIScrollView <UIScrollViewDelegate>

- (CGRect)originalFrameForView:(UIView *)view;
- (CGSize)originalSizeForView:(UIView *)view;
- (void)setMultiScrolling:(BOOL)multiScrolling forView:(UIView *)view;
- (void)addSubview:(UIView *)view  multiScrolling:(BOOL)multiScrolling;

- (void)setContentOffsetFake:(CGPoint)contentOffset;

@end
