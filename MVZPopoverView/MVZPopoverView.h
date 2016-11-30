//
//  MVZPopoverView.h
//
//  Created by EvgenyMikhaylov on 11/27/14.
//  Copyright (c) 2014 Rosberry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MVZPopoverViewTriangleSide) {
    MVZPopoverViewTriangleSideNone,
    MVZPopoverViewTriangleSideTop,
    MVZPopoverViewTriangleSideLeft,
    MVZPopoverViewTriangleSideBottom,
    MVZPopoverViewTriangleSideRight
};

@class MVZPopoverView;

@protocol MVZPopoverViewDelegate <NSObject>

@optional
- (void)popoverView:(MVZPopoverView *)popoverView touchedAtPoint:(CGPoint)point withEvent:(UIEvent *)event;

@end

@interface MVZPopoverView : UIView

@property (nonatomic, weak) id<MVZPopoverViewDelegate> delegate;

@property (nonatomic) UIEdgeInsets containerInsets;

@property (nonatomic) CGFloat cornerRadius;

@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) UIColor *borderColor;

@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) CGFloat shadowBlur;
@property (nonatomic) UIColor *shadowColor;

@property (nonatomic) CGSize triangleSize;
@property (nonatomic) CGFloat preferedTriangleOffset;
@property (nonatomic) MVZPopoverViewTriangleSide preferedTriangleSide;

@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) CGSize preferedContentSize;
@property (nonatomic) UIView *contentView;

@property (nonatomic, readonly) CGPoint point;

- (void)showFromView:(UIView *)view inContainer:(UIView *)containerView;
- (void)showFromPoint:(CGPoint)point inContainer:(UIView *)containerView;

@end
