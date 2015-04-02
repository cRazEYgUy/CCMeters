//
//  UIColor-Additions.h
//  CCMeters
//
//  Additions to the UIColor class.
//
//  Copyright (c) 2015 Sticktron. All rights reserved.
//
//

#import <UIKit/UIColor.h>

@interface UIColor (CCMeters)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (UIImage *)thumbnailWithSize:(CGSize)size;
@end

