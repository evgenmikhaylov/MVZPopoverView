//
//  TriangleSide.m
//  PopoversSample
//
//  Created by Evgeny Mikhaylov on 29/11/2016.
//  Copyright © 2016 Evgeny Mikhaylov. All rights reserved.
//

#import "TriangleSide.h"

@interface TriangleSide ()

@property (nonatomic) NSString *title;
@property (nonatomic) MVZPopoverViewTriangleSide side;

@end

@implementation TriangleSide

- (instancetype)initWithTitle:(NSString *)title side:(MVZPopoverViewTriangleSide)side {
    self = [super init];
    if (self) {
        self.title = title;
        self.side = side;
    }
    return self;
}

@end
