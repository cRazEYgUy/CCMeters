//
//  CCMetersTitleCell.m
//  CCMeters Settings
//
//  Copyright (c) 2014-2015 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @"••••• [CCMeters|Settings]"
#import "../DebugLog.h"

#import "Headers/PSTableCell.h"
#import "Headers/PSHeaderFooterView-Protocol.h"


static NSString * const kBundlePath = @"/Library/PreferenceBundles/CCMetersSettings.bundle";


@interface CCMetersTitleCell : UIView <PSHeaderFooterView>
@property (nonatomic, strong) UIImageView *imageView;
@end


@implementation CCMetersTitleCell

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super init];
	if (self) {
		
		self.backgroundColor = UIColor.clearColor;
		
		NSString *path = [kBundlePath stringByAppendingPathComponent:@"logo.png"];
		UIImage *logo = [[UIImage alloc] initWithContentsOfFile:path];
		
		_imageView = [[UIImageView alloc] initWithImage:logo];
		_imageView.frame = self.frame;
		_imageView.contentMode = UIViewContentModeCenter;
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		[self addSubview:_imageView];
	}
	return self;
}

- (float)preferredHeightForWidth:(float)width {
	return 100.0f;
}

@end

