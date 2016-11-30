//
//  TriangleSide.h
//  PopoversSample
//
//  Created by Evgeny Mikhaylov on 29/11/2016.
//  Copyright © 2016 Evgeny Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVZPopoverView.h"

@interface TriangleSide : NSObject

- (instancetype)initWithTitle:(NSString *)title side:(MVZPopoverViewTriangleSide)side;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) MVZPopoverViewTriangleSide side;

@end
