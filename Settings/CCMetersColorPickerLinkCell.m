//
//  CCMetersColorPickerLinkCell.m
//  CCMeters Settings
//
//  Copyright (c) 2014-2015 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @"••••• [CCMeters|Settings]"
#import "../DebugLog.h"

#import "Headers/PSTableCell.h"
#import "Headers/PSSpecifier.h"
#import "../UIColor-Additions.h"


static CFStringRef const kPrefsAppID = CFSTR("com.sticktron.ccmeters");


@interface CCMetersColorPickerLinkCell : PSTableCell
@property (nonatomic, strong) NSString *selectedColor;
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UILabel *valueLabel;
@end


@implementation CCMetersColorPickerLinkCell

- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	
	if (self) {
		_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
		_valueLabel.font = [UIFont systemFontOfSize:12];
		_valueLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
		_valueLabel.textAlignment = NSTextAlignmentRight;
		_valueLabel.hidden = YES;
		[self.contentView addSubview:_valueLabel];
		
		_thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
		_thumbnailView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;

		_thumbnailView.hidden = YES;
		[self.contentView addSubview:_thumbnailView];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	[self loadColorValueFromPrefs];
	
	if ([self.selectedColor hasPrefix:@"#"]) {
		// showing a color...
		self.valueLabel.hidden = YES;
		
		UIColor *color = [UIColor colorFromHexString:self.selectedColor];
		self.thumbnailView.image  = [color thumbnailWithSize:self.thumbnailView.frame.size];
		self.thumbnailView.hidden = NO;
		
		if ([self.selectedColor isEqual:@"#FFFFFF"]) {
			// add a border for white
			self.thumbnailView.layer.borderWidth = 1;
		} else {
			self.thumbnailView.layer.borderWidth = 0;
		}
		
	} else {
		// showing a non-color...
		self.thumbnailView.hidden = YES;
		
		self.valueLabel.text = self.selectedColor;
		self.valueLabel.hidden = NO;
	}

	CGRect thumbFrame = self.thumbnailView.frame;
	thumbFrame.origin.x = self.contentView.bounds.size.width - thumbFrame.size.width - 4;
	thumbFrame.origin.y = (self.contentView.bounds.size.height - thumbFrame.size.height) / 2.0;
	self.thumbnailView.frame = thumbFrame;
	
	CGRect labelFrame = self.valueLabel.frame;
	labelFrame.origin.x = self.contentView.bounds.size.width - labelFrame.size.width - 4;
	labelFrame.origin.y = (self.contentView.bounds.size.height - labelFrame.size.height) / 2.0;
	self.valueLabel.frame = labelFrame;
}

- (void)loadColorValueFromPrefs {
	NSString *key = [self.specifier propertyForKey:@"key"];
	if (key) {
		CFPreferencesAppSynchronize(kPrefsAppID);
		CFPropertyListRef value = CFPreferencesCopyAppValue((CFStringRef)key, kPrefsAppID);
		if (value) {
			self.selectedColor = (__bridge NSString *)value;
			CFRelease(value);
		}
	}
	if (!self.selectedColor) {
		self.selectedColor = [self.specifier propertyForKey:@"default"];
	}
}

@end

