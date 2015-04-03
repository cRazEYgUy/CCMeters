//
//  UIColor-Additions.m
//  CCMeters
//
//  Additions to the UIColor class.
//
//  Copyright (c) 2014-2015 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @" CCMeters >>"
#import "DebugLog.h"

#import "UIColor-Additions.h"


@implementation UIColor (CCMeters)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
	//DebugLog(@"param hexString=%@", hexString);
	
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:1]; // bypass '#' character
	[scanner scanHexInt:&rgbValue];	
	//DebugLog(@"scanned string, rgbValue=%u", rgbValue);
	
	UIColor *color = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
	//DebugLog(@"created color: scanned string, rgbValue=%u", rgbValue);
	
	return color;
}

- (UIImage *)thumbnailWithSize:(CGSize)size {
	CGRect rect = (CGRect){CGPointZero, size};
	
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [self CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end

