//
//  CMDivisionAlert.m
//  DivisionBell
//
//  Created by Tim on 25/11/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "CMDivisionAlert.h"

@implementation CMDivisionAlert

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"norwegian_rose"]];
    [self setBackgroundColor:background];
}

@end
