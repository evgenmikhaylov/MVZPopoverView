//
//  ViewController.m
//  PopoversSample
//
//  Created by Evgeny Mikhaylov on 10/11/2016.
//  Copyright © 2016 Evgeny Mikhaylov. All rights reserved.
//

#import "ViewController.h"
#import "MVZPopoverView.h"
#import "TriangleSide.h"

@interface ViewController ()

@property (nonatomic, weak) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) MVZPopoverView *popoverView;
@property (nonatomic, weak) UIView *touchView;

@property (nonatomic) NSArray<TriangleSide *> *triangleSides;
@property (nonatomic) TriangleSide *selectedTriangleSide;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[self.triangleSides valueForKeyPath:@"title"]];
    [segmentedControl addTarget:self action:@selector(segmentedControlPressed:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
    
    UIView *touchView = [[UIView alloc] init];
    [self.view addSubview:touchView];
    self.touchView = touchView;
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touched:)];
    gestureRecognizer.minimumPressDuration = 0.0;
    [self.touchView addGestureRecognizer:gestureRecognizer];

    
    [self.triangleSides enumerateObjectsUsingBlock:^(TriangleSide * _Nonnull triangleSide, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([triangleSide.title isEqual:self.selectedTriangleSide.title]) {
            self.segmentedControl.selectedSegmentIndex = idx;
            *stop = YES;
        }
    }];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.segmentedControl.frame = (CGRect){
        .origin.x = 10.0,
        .origin.y = self.topLayoutGuide.length,
        .size.width = CGRectGetWidth(self.view.frame) - 20.0,
        .size.height = 44.0,
    };
    self.touchView.frame = (CGRect){
        .origin.x = 0.0,
        .origin.y = CGRectGetMaxY(self.segmentedControl.frame),
        .size.width = CGRectGetWidth(self.view.frame),
        .size.height = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.segmentedControl.frame),
    };
}

#pragma mark - Setters/Getters

- (NSArray<TriangleSide *> *)triangleSides {
    if (!_triangleSides) {
        _triangleSides = @[
                           [[TriangleSide alloc] initWithTitle:@"Top" side:MVZPopoverViewTriangleSideTop],
                           [[TriangleSide alloc] initWithTitle:@"Left" side:MVZPopoverViewTriangleSideLeft],
                           [[TriangleSide alloc] initWithTitle:@"Bottom" side:MVZPopoverViewTriangleSideBottom],
                           [[TriangleSide alloc] initWithTitle:@"Right" side:MVZPopoverViewTriangleSideRight],
                           [[TriangleSide alloc] initWithTitle:@"None" side:MVZPopoverViewTriangleSideNone],
                           ];
    }
    return _triangleSides;
}

- (TriangleSide *)selectedTriangleSide {
    if (!_selectedTriangleSide) {
        _selectedTriangleSide = [[TriangleSide alloc] initWithTitle:@"Bottom" side:MVZPopoverViewTriangleSideBottom];
    }
    return _selectedTriangleSide;
}

#pragma mark - Actions

- (void)segmentedControlPressed:(id)sender {
    self.selectedTriangleSide = self.triangleSides[self.segmentedControl.selectedSegmentIndex];
    if (self.popoverView) {
        self.popoverView.preferedTriangleSide = self.selectedTriangleSide.side;
        [self.popoverView showFromPoint:self.popoverView.point inContainer:self.touchView];
    }
}

- (void)touched:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.touchView];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 10;
            label.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

            [self.popoverView removeFromSuperview];
            
            MVZPopoverView *popoverView = [[MVZPopoverView alloc] init];
            popoverView.backgroundColor = [UIColor whiteColor];
            popoverView.contentInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
            popoverView.containerInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
            popoverView.shadowColor = [UIColor blackColor];
            popoverView.shadowRadius = 8.0f;
            popoverView.shadowOpacity = 0.15f;
            popoverView.borderColor = [UIColor lightGrayColor];
            popoverView.borderWidth = 1.0;
            popoverView.cornerRadius = 4.0f;
            popoverView.triangleSize = CGSizeMake(30.0f, 15.0f);
            popoverView.preferedTriangleOffset = 0.5f;
            popoverView.preferedContentSize = [label sizeThatFits:(CGSize) {
                .width = 200.0,
                .height = CGFLOAT_MAX,
            }];
            popoverView.preferedTriangleSide = self.selectedTriangleSide.side;
            popoverView.contentView = label;
            [popoverView showFromPoint:point inContainer:self.touchView];
            self.popoverView = popoverView;
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            [self.popoverView showFromPoint:point inContainer:self.touchView];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Views 

- (void)createPopoverView {
    
}

@end
