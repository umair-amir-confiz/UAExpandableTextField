//
//  UITableView+PlaceholderColor.m
//  Cove
//
//  Created by Umair Aamir on 4/7/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "UITextField+PlaceholderColor.h"

@implementation UITextField (PlaceholderColor)

-(void)setPlaceholderColor:(UIColor*)color
{
    [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}

@end
