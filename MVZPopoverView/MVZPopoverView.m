//
//  MVZPopoverView.m
//
//  Created by EvgenyMikhaylov on 11/27/14.
//  Copyright (c) 2014 Rosberry. All rights reserved.
//

#import "MVZPopoverView.h"

@interface MVZPopoverView ()

@property (nonatomic, readonly) CAShapeLayer *layer;
@property (nonatomic, readonly) CAShapeLayer *borderLayer;
@property (nonatomic) UIColor *popoverColor;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *anchorView;
@property (nonatomic) CGPoint point;

@property (nonatomic) CGRect triangleRect;
@property (nonatomic) CGSize contentSize;
@property (nonatomic) MVZPopoverViewTriangleSide triangleSide;

@end

@implementation MVZPopoverView

@dynamic layer;

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentInsets = UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f);
        self.containerInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        self.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.shadowRadius = 5.0f;
        self.shadowColor = [UIColor blackColor];
        self.cornerRadius = 10.0f;
        self.preferedTriangleOffset = 0.0f;
        self.triangleSize = CGSizeMake(20.0f, 10.0f);
        self.preferedTriangleSide = MVZPopoverViewTriangleSideBottom;
        self.triangleType = MVZPopoverViewTriangleTypeDefault;
    }
    return self;
}

#pragma mark - Layout

- (void)updateFrame {
    self.contentSize = self.preferedContentSize;
    self.triangleSide = self.preferedTriangleSide;
    self.triangleRect = [self calculateTriangleRect];
    self.frame = [self calculateFrame];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.path = [self calculatePopoverPath];
    self.layer.shadowPath = self.layer.path;
    self.contentView.frame = [self calculateContentRect];
}

#pragma mark - Setters/Getters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    self.popoverColor = backgroundColor;
    self.layer.fillColor = backgroundColor.CGColor;
}

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    
    _contentView = contentView;
    [self addSubview:self.contentView];
    
    [self setNeedsLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    self.layer.shadowOffset = _shadowOffset;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    _shadowOpacity = shadowOpacity;
    self.layer.shadowOpacity = _shadowOpacity;
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    _shadowRadius = shadowRadius;
    self.layer.shadowRadius = _shadowRadius;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;    
    self.layer.shadowColor = _shadowColor.CGColor;
}

- (void)setPreferedTriangleOffset:(CGFloat)preferedTriangleOffset {
    _preferedTriangleOffset = preferedTriangleOffset;
    [self setNeedsLayout];
}

- (void)setTriangleSize:(CGSize)triangleSize {
    _triangleSize = triangleSize;
    [self setNeedsLayout];
}

- (void)setPreferedTriangleSide:(MVZPopoverViewTriangleSide)preferedTriangleSide {
    _preferedTriangleSide = preferedTriangleSide;
    [self setNeedsLayout];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.lineWidth = _borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.strokeColor = _borderColor.CGColor;
}

- (CGPoint)point {
    if (self.anchorView == nil) {
        return _point;
    }
    
    CGRect anchorRect = [self.anchorView.superview convertRect:self.anchorView.frame toView:self.containerView];
    
    switch (self.triangleSide) {
            
        case MVZPopoverViewTriangleSideTop: {
            return (CGPoint) {
                .x = CGRectGetMidX(anchorRect),
                .y = CGRectGetMaxY(anchorRect),
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideLeft: {
            return (CGPoint) {
                .x = CGRectGetMaxX(anchorRect),
                .y = CGRectGetMidY(anchorRect),
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideBottom: {
            return (CGPoint) {
                .x = CGRectGetMidX(anchorRect),
                .y = CGRectGetMinY(anchorRect),
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideRight: {
            return (CGPoint) {
                .x = CGRectGetMinX(anchorRect),
                .y = CGRectGetMidY(anchorRect),
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideNone: {
            return (CGPoint) {
                .x = CGRectGetMidX(anchorRect),
                .y = CGRectGetMinY(anchorRect),
            };
        }
            break;
    }
}

#pragma mark - Calculations

- (CGRect)calculatePopoverRect {
    return (CGRect){
        .origin.x = self.calculatePopoverInsets.left,
        .origin.y = self.calculatePopoverInsets.top,
        .size.width = self.contentSize.width + self.contentInsets.left + self.contentInsets.right,
        .size.height = self.contentSize.height + self.contentInsets.top + self.contentInsets.bottom,
    };
}

- (CGRect)calculateContentRect {
    UIEdgeInsets popoverInsets = self.calculatePopoverInsets;
    return (CGRect){
        .origin.x = popoverInsets.left + self.contentInsets.left,
        .origin.y = popoverInsets.top + self.contentInsets.top,
        .size.width = self.contentSize.width,
        .size.height = self.contentSize.height,
    };
}

- (CGRect)calculateFrame {
    CGPoint location = self.point;
    UIEdgeInsets popoverInsets = self.calculatePopoverInsets;
    
    CGRect triangleRect = self.triangleRect;
    
    CGFloat width = self.contentSize.width + self.contentInsets.left + self.contentInsets.right + popoverInsets.left + popoverInsets.right;
    CGFloat height = self.contentSize.height + self.contentInsets.top + self.contentInsets.bottom + popoverInsets.top + popoverInsets.bottom;
    
    CGRect rect = CGRectZero;
    
    CGFloat minX = self.containerInsets.left;
    CGFloat minY = self.containerInsets.top;
    CGFloat maxWidth = CGRectGetWidth(self.containerView.frame) - self.containerInsets.left - self.containerInsets.right;
    CGFloat maxHeight = CGRectGetHeight(self.containerView.frame) - self.containerInsets.top - self.containerInsets.bottom;
    CGFloat maxX = minX + maxWidth;
    CGFloat maxY = minY + maxHeight;
    
    switch (self.triangleSide) {
            
        case MVZPopoverViewTriangleSideTop:
        case MVZPopoverViewTriangleSideBottom: {
            CGFloat verticalOffset = self.shadowRadius;
            CGFloat recalculatedMaxHeight = CGRectGetHeight(self.containerView.frame) - location.y - self.containerInsets.bottom;
            if (self.triangleSide == MVZPopoverViewTriangleSideBottom) {
                verticalOffset = height - self.shadowRadius;
                recalculatedMaxHeight = location.y - self.containerInsets.top;
            }
            rect = (CGRect){
                .origin.x = location.x - CGRectGetMidX(triangleRect),
                .origin.y = location.y - verticalOffset,
                .size.width = width,
                .size.height = height,
            };
            if (CGRectGetWidth(rect) > maxWidth) {
                CGSize contentSize = self.contentSize;
                contentSize.width = maxWidth - (self.contentInsets.left + self.contentInsets.right + popoverInsets.left + popoverInsets.right);
                self.contentSize = contentSize;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetHeight(rect) > recalculatedMaxHeight && CGRectGetHeight(rect) > (maxHeight / 2.0)) {
                CGSize contentSize = self.contentSize;
                contentSize.height = recalculatedMaxHeight - (self.contentInsets.top + self.contentInsets.bottom + popoverInsets.top + popoverInsets.bottom);
                self.contentSize = contentSize;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetMinX(rect) < minX) {
                triangleRect.origin.x = location.x - minX - CGRectGetWidth(triangleRect) / 2.0;
                self.triangleRect = triangleRect;
                rect = [self calculateFrame];
            }
            if (CGRectGetMaxX(rect) > maxX) {
                triangleRect.origin.x = location.x - (maxX - CGRectGetWidth(rect)) - CGRectGetWidth(triangleRect) / 2.0;
                self.triangleRect = triangleRect;
                rect = [self calculateFrame];
            }
            if (CGRectGetMinY(rect) < minY && self.triangleSide == MVZPopoverViewTriangleSideBottom) {
                self.triangleSide = MVZPopoverViewTriangleSideTop;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetMaxY(rect) > maxY && self.triangleSide == MVZPopoverViewTriangleSideTop) {
                self.triangleSide = MVZPopoverViewTriangleSideBottom;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
        }
            break;
            
        case MVZPopoverViewTriangleSideLeft:
        case MVZPopoverViewTriangleSideRight: {
            CGFloat horizontalOffset = self.shadowRadius;
            CGFloat recalculatedMaxWidth = CGRectGetWidth(self.containerView.frame) - location.x - self.containerInsets.right;
            if (self.triangleSide == MVZPopoverViewTriangleSideRight) {
                horizontalOffset = width - self.shadowRadius;
                recalculatedMaxWidth = location.x - self.containerInsets.left;
            }
            rect = (CGRect){
                .origin.x = location.x - horizontalOffset,
                .origin.y = location.y - CGRectGetMidY(triangleRect),
                .size.width = width,
                .size.height = height,
            };
            if (CGRectGetWidth(rect) > recalculatedMaxWidth && CGRectGetWidth(rect) > (maxWidth / 2.0)) {
                CGSize contentSize = self.contentSize;
                contentSize.width = recalculatedMaxWidth - (self.contentInsets.left + self.contentInsets.right + popoverInsets.left + popoverInsets.right);
                self.contentSize = contentSize;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetHeight(rect) > maxHeight) {
                CGSize contentSize = self.contentSize;
                contentSize.height = maxHeight - (self.contentInsets.top + self.contentInsets.bottom + popoverInsets.top + popoverInsets.bottom);
                self.contentSize = contentSize;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetMinX(rect) < minX && self.triangleSide == MVZPopoverViewTriangleSideRight) {
                self.triangleSide = MVZPopoverViewTriangleSideLeft;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetMaxX(rect) > maxX && self.triangleSide == MVZPopoverViewTriangleSideLeft) {
                self.triangleSide = MVZPopoverViewTriangleSideRight;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetMinY(rect) < minY) {
                triangleRect.origin.y = location.y - minY - CGRectGetHeight(triangleRect) / 2.0;
                self.triangleRect = triangleRect;
                rect = [self calculateFrame];
            }
            if (CGRectGetMaxY(rect) > maxY) {
                triangleRect.origin.y = location.y - (maxY - CGRectGetHeight(rect)) - CGRectGetHeight(triangleRect) / 2.0;
                self.triangleRect = triangleRect;
                rect = [self calculateFrame];
            }
        }
            break;
            
        case MVZPopoverViewTriangleSideNone: {
            rect = (CGRect){
                .origin.x = location.x - width / 2,
                .origin.y = location.y - height / 2,
                .size.width = width,
                .size.height = height,
            };
            if (CGRectGetWidth(rect) > maxWidth) {
                CGSize contentSize = self.contentSize;
                contentSize.width = maxWidth - (self.contentInsets.left + self.contentInsets.right + popoverInsets.left + popoverInsets.right);
                self.contentSize = contentSize;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetHeight(rect) > maxHeight) {
                CGSize contentSize = self.contentSize;
                contentSize.height = maxHeight - (self.contentInsets.top + self.contentInsets.bottom + popoverInsets.top + popoverInsets.bottom);
                self.contentSize = contentSize;
                self.triangleRect = [self calculateTriangleRect];
                rect = [self calculateFrame];
            }
            if (CGRectGetMinX(rect) < minX) {
                rect.origin.x = minX;
            }
            if (CGRectGetMaxX(rect) > maxX) {
                rect.origin.x = maxX - CGRectGetWidth(rect);
            }
            if (CGRectGetMinY(rect) < minY) {
                rect.origin.y = minY;
            }
            if (CGRectGetMaxY(rect) > maxY) {
                rect.origin.y = maxY - CGRectGetHeight(rect);
            }
        }
            break;
    }
    return rect;
}

- (CGPathRef)calculatePopoverPath {
    CGRect popoverRect = self.calculatePopoverRect;
    
    CGFloat topLeftCornerRadius = self.cornerRadius;
    CGFloat topRightCornerRadius = self.cornerRadius;
    CGFloat bottomLeftCornerRadius = self.cornerRadius;
    CGFloat bottomRightCornerRadius = self.cornerRadius;
    
    CGMutablePathRef popoverPath = CGPathCreateMutable();
    
    NSMutableArray<NSValue *> *topTrianglePoints = [[NSMutableArray alloc] init];
    NSMutableArray<NSValue *> *rightTrianglePoints = [[NSMutableArray alloc] init];
    NSMutableArray<NSValue *> *bottomTrianglePoints = [[NSMutableArray alloc] init];
    NSMutableArray<NSValue *> *leftTrianglePoints = [[NSMutableArray alloc] init];
    
    if (self.triangleSide != MVZPopoverViewTriangleSideNone) {
        
        CGPoint point1 = CGPointZero;
        CGPoint point2 = CGPointZero;
        CGPoint point3 = CGPointZero;
        
        CGRect triangleRect = self.triangleRect;
        
        switch (self.triangleSide) {
            case MVZPopoverViewTriangleSideTop: {
                point1 = CGPointMake(CGRectGetMinX(triangleRect), CGRectGetMaxY(triangleRect));
                if (point1.x < CGRectGetMinX(popoverRect)) {
                    point1.x = CGRectGetMinX(popoverRect);
                }
                point2 = CGPointMake(CGRectGetMidX(triangleRect), CGRectGetMinY(triangleRect));
                point3 = CGPointMake(CGRectGetMaxX(triangleRect), CGRectGetMaxY(triangleRect));
                if (point3.x > CGRectGetMaxX(popoverRect)) {
                    point3.x = CGRectGetMaxX(popoverRect);
                }
                
                if (point1.x < (CGRectGetMinX(popoverRect) + self.cornerRadius)) {
                    topLeftCornerRadius = point1.x - CGRectGetMinX(popoverRect);
                }
                if (point3.x > (CGRectGetMaxX(popoverRect) - self.cornerRadius)) {
                    topRightCornerRadius = CGRectGetMaxX(popoverRect) - point3.x;
                }
                [topTrianglePoints addObjectsFromArray:@[
                                                         [NSValue valueWithCGPoint:point1],
                                                         [NSValue valueWithCGPoint:point2],
                                                         [NSValue valueWithCGPoint:point3],
                                                         ]];
            }
                break;
                
            case MVZPopoverViewTriangleSideRight: {
                point1 = CGPointMake(CGRectGetMinX(triangleRect), CGRectGetMinY(triangleRect));
                if (point1.y < CGRectGetMinY(popoverRect)) {
                    point1.y = CGRectGetMinY(popoverRect);
                }
                point2 = CGPointMake(CGRectGetMaxX(triangleRect), CGRectGetMidY(triangleRect));
                point3 = CGPointMake(CGRectGetMinX(triangleRect), CGRectGetMaxY(triangleRect));
                if (point3.y > CGRectGetMaxY(popoverRect)) {
                    point3.y = CGRectGetMaxY(popoverRect);
                }
                
                if (point1.y < (CGRectGetMinY(popoverRect) + self.cornerRadius)) {
                    topRightCornerRadius = point1.y - CGRectGetMinY(popoverRect);
                }
                if (point3.y > (CGRectGetMaxY(popoverRect) - self.cornerRadius)) {
                    bottomRightCornerRadius = CGRectGetMaxY(popoverRect) - point3.y;
                }
                [rightTrianglePoints addObjectsFromArray:@[
                                                           [NSValue valueWithCGPoint:point1],
                                                           [NSValue valueWithCGPoint:point2],
                                                           [NSValue valueWithCGPoint:point3],
                                                           ]];
            }
                break;
                
            case MVZPopoverViewTriangleSideBottom: {
                point1 = CGPointMake(CGRectGetMinX(triangleRect), CGRectGetMinY(triangleRect));
                if (point1.x < CGRectGetMinX(popoverRect)) {
                    point1.x = CGRectGetMinX(popoverRect);
                }
                point2 = CGPointMake(CGRectGetMidX(triangleRect), CGRectGetMaxY(triangleRect));
                point3 = CGPointMake(CGRectGetMaxX(triangleRect), CGRectGetMinY(triangleRect));
                if (point3.x > CGRectGetMaxX(popoverRect)) {
                    point3.x = CGRectGetMaxX(popoverRect);
                }
                
                if (point1.x < (CGRectGetMinX(popoverRect) + self.cornerRadius)) {
                    bottomLeftCornerRadius = point1.x - CGRectGetMinX(popoverRect);
                }
                if (point3.x > (CGRectGetMaxX(popoverRect) - self.cornerRadius)) {
                    bottomRightCornerRadius = CGRectGetMaxX(popoverRect) - point3.x;
                }
                [bottomTrianglePoints addObjectsFromArray:@[
                                                            [NSValue valueWithCGPoint:point3],
                                                            [NSValue valueWithCGPoint:point2],
                                                            [NSValue valueWithCGPoint:point1],
                                                            ]];
            }
                break;
                
            case MVZPopoverViewTriangleSideLeft: {
                point1 = CGPointMake(CGRectGetMaxX(triangleRect), CGRectGetMinY(triangleRect));
                if (point1.y < CGRectGetMinY(popoverRect)) {
                    point1.y = CGRectGetMinY(popoverRect);
                }
                point2 = CGPointMake(CGRectGetMinX(triangleRect), CGRectGetMidY(triangleRect));
                point3 = CGPointMake(CGRectGetMaxX(triangleRect), CGRectGetMaxY(triangleRect));
                if (point3.y > CGRectGetMaxY(popoverRect)) {
                    point3.y = CGRectGetMaxY(popoverRect);
                }
                
                if (point1.y < (CGRectGetMinY(popoverRect) + self.cornerRadius)) {
                    topLeftCornerRadius = point1.y - CGRectGetMinY(popoverRect);
                }
                if (point3.y > (CGRectGetMaxY(popoverRect) - self.cornerRadius)) {
                    bottomLeftCornerRadius = CGRectGetMaxY(popoverRect) - point3.y;
                }
                [leftTrianglePoints addObjectsFromArray:@[
                                                          [NSValue valueWithCGPoint:point3],
                                                          [NSValue valueWithCGPoint:point2],
                                                          [NSValue valueWithCGPoint:point1],
                                                          ]];
            }
                break;
                
                
            default:
                break;
        }
    }
    
    CGPoint pointTopLeft1 = (CGPoint) {
        .x = CGRectGetMinX(popoverRect),
        .y = CGRectGetMinY(popoverRect) + topLeftCornerRadius,
    };
    CGPoint pointTopLeft2 = (CGPoint) {
        .x = CGRectGetMinX(popoverRect) + topLeftCornerRadius,
        .y = CGRectGetMinY(popoverRect) + topLeftCornerRadius,
    };
    CGPoint pointTopLeft3= (CGPoint) {
        .x = CGRectGetMinX(popoverRect) + topLeftCornerRadius,
        .y = CGRectGetMinY(popoverRect),
    };
    
    CGPoint pointTopRight1 = (CGPoint) {
        .x = CGRectGetMaxX(popoverRect) - topRightCornerRadius,
        .y = CGRectGetMinY(popoverRect),
    };
    CGPoint pointTopRight2 = (CGPoint) {
        .x = CGRectGetMaxX(popoverRect) - topRightCornerRadius,
        .y = CGRectGetMinY(popoverRect) + topRightCornerRadius,
    };
    CGPoint pointTopRight3 = (CGPoint) {
        .x = CGRectGetMaxX(popoverRect),
        .y = CGRectGetMinY(popoverRect) + topRightCornerRadius,
    };
    
    CGPoint pointBottomRight1 = (CGPoint) {
        .x = CGRectGetMaxX(popoverRect),
        .y = CGRectGetMaxY(popoverRect) - bottomRightCornerRadius,
    };
    CGPoint pointBottomRight2 = (CGPoint) {
        .x = CGRectGetMaxX(popoverRect) - bottomRightCornerRadius,
        .y = CGRectGetMaxY(popoverRect) - bottomRightCornerRadius,
    };
    CGPoint pointBottomRight3 = (CGPoint) {
        .x = CGRectGetMaxX(popoverRect) - bottomRightCornerRadius,
        .y = CGRectGetMaxY(popoverRect),
    };
    
    CGPoint pointBottomLeft1 = (CGPoint) {
        .x = CGRectGetMinX(popoverRect) + bottomLeftCornerRadius,
        .y = CGRectGetMaxY(popoverRect),
    };
    CGPoint pointBottomLeft2 = (CGPoint) {
        .x = CGRectGetMinX(popoverRect) + bottomLeftCornerRadius,
        .y = CGRectGetMaxY(popoverRect) - bottomLeftCornerRadius,
    };
    CGPoint pointBottomLeft3 = (CGPoint) {
        .x = CGRectGetMinX(popoverRect),
        .y = CGRectGetMaxY(popoverRect) - bottomLeftCornerRadius,
    };
    
    CGPathMoveToPoint(popoverPath, NULL, pointTopLeft3.x, pointTopLeft3.y);
    [self addTrianglePoints:topTrianglePoints toPath:popoverPath];
    CGPathAddLineToPoint(popoverPath, NULL, pointTopRight1.x, pointTopRight1.y);
    CGPathAddArc(popoverPath, NULL, pointTopRight2.x, pointTopRight2.y, topRightCornerRadius, -M_PI_2, 0.0f, NO);
    
    CGPathAddLineToPoint(popoverPath, NULL, pointTopRight3.x, pointTopRight3.y);
    [self addTrianglePoints:rightTrianglePoints toPath:popoverPath];
    CGPathAddLineToPoint(popoverPath, NULL, pointBottomRight1.x, pointBottomRight1.y);
    CGPathAddArc(popoverPath, NULL, pointBottomRight2.x, pointBottomRight2.y, bottomRightCornerRadius, 0.0f, M_PI_2, NO);
    
    CGPathAddLineToPoint(popoverPath, NULL, pointBottomRight3.x, pointBottomRight3.y);
    [self addTrianglePoints:bottomTrianglePoints toPath:popoverPath];
    CGPathAddLineToPoint(popoverPath, NULL, pointBottomLeft1.x, pointBottomLeft1.y);
    CGPathAddArc(popoverPath, NULL, pointBottomLeft2.x, pointBottomLeft2.y, bottomLeftCornerRadius, M_PI_2, M_PI, NO);
    
    CGPathAddLineToPoint(popoverPath, NULL, pointBottomLeft3.x, pointBottomLeft3.y);
    [self addTrianglePoints:leftTrianglePoints toPath:popoverPath];
    CGPathAddLineToPoint(popoverPath, NULL, pointTopLeft1.x, pointTopLeft1.y);
    CGPathAddArc(popoverPath, NULL, pointTopLeft2.x, pointTopLeft2.y, topLeftCornerRadius, M_PI, 3*M_PI_2, NO);
    
    return popoverPath;
}

- (void)addTrianglePoints:(NSArray<NSValue *> *)points toPath:(CGPathRef)path {
    switch (self.triangleType) {
        case MVZPopoverViewTriangleTypeDefault:     [self addDefaultTrianglePoints:points toPath:path];     break;
        case MVZPopoverViewTriangleTypeRounded:     [self addRoundedTrianglePoints:points toPath:path];     break;
    }
}

- (void)addDefaultTrianglePoints:(NSArray<NSValue *> *)points toPath:(CGPathRef)path {
    if (points.count != 3) {
        return;
    }
    CGPoint point1 = points[0].CGPointValue;
    CGPoint point2 = points[1].CGPointValue;
    CGPoint point3 = points[2].CGPointValue;
    CGPathAddLineToPoint(path, NULL, point1.x, point1.y);
    CGPathAddLineToPoint(path, NULL, point2.x, point2.y);
    CGPathAddLineToPoint(path, NULL, point3.x, point3.y);
}

- (void)addRoundedTrianglePoints:(NSArray<NSValue *> *)points toPath:(CGPathRef)path {
    if (points.count != 3) {
        return;
    }
    CGPoint p1 = points[0].CGPointValue;
    CGPoint p2 = points[1].CGPointValue;
    CGPoint p3 = points[2].CGPointValue;
    CGPathAddLineToPoint(path, NULL, p1.x, p1.y);

    switch (self.triangleSide) {
        case MVZPopoverViewTriangleSideTop: {
            [self addArcFromPoint:p1 toPoint:p2 toPath:path reverse:NO];
            [self addArcFromPoint:p2 toPoint:p3 toPath:path reverse:YES];
        }
            break;
        case MVZPopoverViewTriangleSideRight: {
            [self addArcFromPoint:p1 toPoint:p2 toPath:path reverse:YES];
            [self addArcFromPoint:p2 toPoint:p3 toPath:path reverse:YES];
        }
            break;
        case MVZPopoverViewTriangleSideBottom: {
            [self addArcFromPoint:p1 toPoint:p2 toPath:path reverse:YES];
            [self addArcFromPoint:p2 toPoint:p3 toPath:path reverse:NO];
        }
            break;
        case MVZPopoverViewTriangleSideLeft: {
            [self addArcFromPoint:p1 toPoint:p2 toPath:path reverse:NO];
            [self addArcFromPoint:p2 toPoint:p3 toPath:path reverse:NO];
        }
            break;
        default:
            break;
    }
}

- (void)addArcFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2 toPath:(CGPathRef)path reverse:(BOOL)reverse{    
    CGFloat p1p2 = sqrt(pow(p2.x - p1.x, 2.0) + pow(p2.y - p1.y, 2.0));
    CGFloat a = p1p2 / 2.0;
    CGFloat b = 2.0 * a;
    CGFloat d = sqrt(pow(a, 2.0) + pow(b, 2.0));

    CGFloat alpha2 = acos(a / d);
    CGFloat alpha1 = acos((p2.x - p1.x) / (2.0 * a));
    CGFloat alpha3 = M_PI - alpha2 - alpha1;
    
    CGFloat angle = 2.0 * (M_PI_2 - alpha2);
    CGFloat alpha4 = M_PI - M_PI_2 - alpha3;
    CGFloat startAngle = M_PI_2 - alpha4 - angle;
    
    CGFloat x12, y12;
    CGFloat fromAngle, toAngle;
    if (reverse) {
        x12 = p2.x + d * cos(alpha3);
        y12 = p2.y - d * sin(alpha3);
        fromAngle = M_PI - startAngle;
        toAngle = M_PI - startAngle - angle;
    }
    else {
        x12 = p1.x - d * cos(alpha3);
        y12 = p1.y - d * sin(alpha3);
        fromAngle = startAngle + angle;
        toAngle = startAngle;
    }
    CGPoint p12 = (CGPoint){.x = x12, .y = y12};
    CGFloat raduis = sqrt(pow(p2.x - p12.x, 2.0) + pow(p2.y - p12.y, 2.0));
    CGPathAddArc(path, NULL, p12.x, p12.y, raduis, fromAngle, toAngle, YES);
}

- (CGRect)calculateTriangleRect {
    CGRect popoverRect = self.calculatePopoverRect;

    switch (self.triangleSide) {
        case MVZPopoverViewTriangleSideNone: {
            return (CGRect){
                .origin.x = CGRectGetMinX(popoverRect) + self.preferedTriangleOffset * CGRectGetWidth(popoverRect) - self.triangleSize.width / 2,
                .origin.y = CGRectGetMaxY(popoverRect),
                .size.width = self.triangleSize.width,
                .size.height = 0.0f,
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideTop: {
            return (CGRect){
                .origin.x = CGRectGetMinX(popoverRect) + self.preferedTriangleOffset * CGRectGetWidth(popoverRect) - self.triangleSize.width / 2,
                .origin.y = self.calculatePopoverInsets.top - self.triangleSize.height,
                .size.width = self.triangleSize.width,
                .size.height = self.triangleSize.height,
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideLeft: {
            return (CGRect){
                .origin.x = self.calculatePopoverInsets.left - self.triangleSize.height,
                .origin.y = CGRectGetMinY(popoverRect) + self.preferedTriangleOffset * CGRectGetHeight(popoverRect) - self.triangleSize.width / 2,
                .size.width = self.triangleSize.height,
                .size.height = self.triangleSize.width,
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideBottom: {
            return (CGRect){
                .origin.x = CGRectGetMinX(popoverRect) + self.preferedTriangleOffset * CGRectGetWidth(popoverRect) - self.triangleSize.width / 2,
                .origin.y = CGRectGetMaxY(popoverRect),
                .size.width = self.triangleSize.width,
                .size.height = self.triangleSize.height,
            };
        }
            break;
            
        case MVZPopoverViewTriangleSideRight: {
            return (CGRect){
                .origin.x = CGRectGetMaxX(popoverRect),
                .origin.y = CGRectGetMinY(popoverRect) + self.preferedTriangleOffset * CGRectGetHeight(popoverRect) - self.triangleSize.width / 2,
                .size.width = self.triangleSize.height,
                .size.height = self.triangleSize.width,
            };
        }
            break;
    }
}

- (UIEdgeInsets)calculatePopoverInsets {
    UIEdgeInsets insets = (UIEdgeInsets){
        .top = self.shadowRadius,
        .left = self.shadowRadius,
        .bottom = self.shadowRadius,
        .right = self.shadowRadius,
    };
    switch (self.triangleSide) {
        case MVZPopoverViewTriangleSideTop:
            insets.top += self.triangleSize.height;
            break;
        case MVZPopoverViewTriangleSideLeft:
            insets.left += self.triangleSize.height;
            break;
        case MVZPopoverViewTriangleSideBottom:
            insets.bottom += self.triangleSize.height;
            break;
        case MVZPopoverViewTriangleSideRight:
            insets.right += self.triangleSize.height;
            break;
        case MVZPopoverViewTriangleSideNone:
            break;
    }
    return insets;
}

#pragma mark - Show

- (void)showFromView:(UIView *)anchorView inContainer:(UIView *)containerView {
    self.containerView = containerView;
    self.anchorView = anchorView;
    [containerView addSubview:self];
    
    [self updateFrame];
}

- (void)showFromPoint:(CGPoint)point inContainer:(UIView *)containerView {
    self.containerView = containerView;
    self.point = point;
    [containerView addSubview:self];
    
    [self updateFrame];
}

#pragma mark - HitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if ([self.delegate respondsToSelector:@selector(popoverView:touchedAtPoint:withEvent:)]) {
        [self.delegate popoverView:self touchedAtPoint:point withEvent:event];
    }
    if (hitView == self) {
        return nil;
    }
    return hitView;
}


@end
