//
//  CCMetersColorPicker.m
//  CCMeters Settings
//
//  Copyright (c) 2014-2015 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @"••••• [CCMeters|Settings]"
#import "../DebugLog.h"

#import "Headers/PSViewController.h"
#import "Headers/PSSpecifier.h"
#import "../UIColor-Additions.h"


static CFStringRef const kPrefsAppID = CFSTR("com.sticktron.ccmeters");
static CFStringRef const kPrefsNotification = CFSTR("com.sticktron.ccmeters.settings-changed");

static NSString * const kNameKey = @"name";
static NSString * const kHexKey = @"hex";



@interface CCMetersColorPicker : PSViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *palettes;
@property (nonatomic, strong) NSString *selectedColor;
@property (nonatomic, strong) NSString *defaultColor;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSString *prefKey;
@end



@implementation CCMetersColorPicker

- (instancetype)init {
	self = [super init];
	if (self) {
		//
	}
	return self;
}

- (NSArray *)palettes {
	if (!_palettes) {
		_palettes = @[
			@{
				@"title": 	@"Special",
				@"colors": 	@[ @{ kNameKey: @"Translucent", kHexKey: @"translucent" } ]
			},
			@{
				@"title": 	@"iOS Palette",
				@"colors": 	[self iOSColors]
			},
			@{
				@"title": 	@"Crayons",
				@"colors": 	[self crayonColors]
			}
		];
	}
	return _palettes;
}

- (void)loadView {
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
														  style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.rowHeight = 44.0f;
	self.view = tableView;
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// self.specifier isn't ready during init, but it should be by now,
	// so let's use it to get some info from the PSSpecifier we belong to.
	self.title = [self.specifier name];
	self.prefKey = [self.specifier propertyForKey:@"key"];
	self.defaultColor = [self.specifier propertyForKey:@"default"];
	
	// check user prefs to see if there's selected color yet.
	if (self.prefKey) {
		CFPreferencesAppSynchronize(kPrefsAppID);
		CFPropertyListRef value = CFPreferencesCopyAppValue((CFStringRef)self.prefKey, kPrefsAppID);
		if (value) {
			self.selectedColor = (__bridge NSString *)value;
			CFRelease(value);
		}
	}
	if (!self.selectedColor) {
		self.selectedColor = self.defaultColor;
	}
}

/* TableView Stuff */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.palettes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.palettes[section][@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DebugLog0;
	
//	NSDictionary *palette = self.palettes[section];
//	NSArray *colors = palette[@"colors"];
//	return [colors count];
	
	return [self.palettes[section][@"colors"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyCellIdentifier = @"ColorSwatchCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:MyCellIdentifier];
		cell.opaque = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.textColor = UIColor.blackColor;
		
		cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
		cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
	}
	
	// prepare for reuse
	cell.textLabel.text = nil;
	cell.detailTextLabel.text = nil;
	cell.imageView.image = nil;
	cell.imageView.layer.borderWidth = 0;
	
	
	// configure cell with new data ...
	
	NSDictionary *colorDict = self.palettes[indexPath.section][@"colors"][indexPath.row];
	NSString *colorName = colorDict[kNameKey];
	NSString *hexValue = colorDict[kHexKey];
	
	cell.textLabel.text = colorName;
	
	if (indexPath.section == 0) {
		cell.detailTextLabel.text = @"*color blending on newer devices only";
		
	} else {
		cell.detailTextLabel.text = hexValue;
		
		// make a swatch
		UIColor *color = [UIColor colorFromHexString:hexValue];
		UIImage *image = [color thumbnailWithSize:CGSizeMake(48, 24)];
		cell.imageView.image = image;
		
		// show a border for white
		if ([hexValue isEqualToString:@"#FFFFFF"]) {
			cell.imageView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
			cell.imageView.layer.borderWidth = 1;
		}
	}
	
	
	// set selection state ...
	
	DebugLog(@"hexValue=%@", hexValue);
	DebugLog(@"self.selectedPath=%@", self.selectedIndexPath);
	DebugLog(@"self.selectedColor=%@", self.selectedColor);
	
	
	if ([hexValue isEqualToString:self.selectedColor]) {
		self.selectedIndexPath = indexPath;
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DebugLog(@"User selected cell at position: (%ld,%ld)", (long)indexPath.section, (long)indexPath.row);
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		// cell is already selected, do nothing
		return;
	}
	
	// un-check previously checked cell
	UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
	oldCell.accessoryType = UITableViewCellAccessoryNone;
	
	// check this cell
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	self.selectedIndexPath = indexPath;
	
	// save the value
	NSDictionary *colorDict = self.palettes[indexPath.section][@"colors"][indexPath.row];
	self.selectedColor = colorDict[kHexKey];
	DebugLog(@"saving setting for '%@': %@", self.prefKey, self.selectedColor);
	CFPreferencesSetAppValue((CFStringRef)self.prefKey, (CFStringRef)self.selectedColor, kPrefsAppID);
	CFPreferencesAppSynchronize(kPrefsAppID);
	
	// notify tweak
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
										 kPrefsNotification,
										 NULL,
										 NULL,
										 kCFNotificationDeliverImmediately);
}

- (NSArray *)iOSColors {
	// This is the new palette introduced in iOS 7.
	
	return @[
			 
  		@{ kNameKey: @"Purple", 		kHexKey: @"#5856D6" },
		@{ kNameKey: @"System Blue", 	kHexKey: @"#007AFF" },
		@{ kNameKey: @"Marine Blue", 	kHexKey: @"#34AADC" },
		@{ kNameKey: @"Light Blue", 	kHexKey: @"#5AC8FA" },
		@{ kNameKey: @"Pink", 			kHexKey: @"#FF2D55" },
		@{ kNameKey: @"System Red", 	kHexKey: @"#FF3B30" },
		@{ kNameKey: @"Orange", 		kHexKey: @"#FF9500" },
		@{ kNameKey: @"Yellow", 		kHexKey: @"#FFCC00" },
		@{ kNameKey: @"System Green", 	kHexKey: @"#4CD964" },
		@{ kNameKey: @"Gray", 			kHexKey: @"#8E8E93" }
		
	];
}

- (NSArray *)crayonColors {
	
	// These are the crayons from the OS X color picker.
	
	return @[
		@{ kNameKey: @"Snow",			kHexKey: @"#FFFFFF" }, //White
		@{ kNameKey: @"Mercury",		kHexKey: @"#E6E6E6" },
		@{ kNameKey: @"Silver", 		kHexKey: @"#CCCCCC" },
		@{ kNameKey: @"Magnesium", 		kHexKey: @"#B3B3B3" },
		@{ kNameKey: @"Aluminum", 		kHexKey: @"#999999" },
		@{ kNameKey: @"Nickel", 		kHexKey: @"#808080" },
		@{ kNameKey: @"Tin", 			kHexKey: @"#7F7F7F" },
		@{ kNameKey: @"Steel", 			kHexKey: @"#666666" },
		@{ kNameKey: @"Iron", 			kHexKey: @"#4C4C4C" },
		@{ kNameKey: @"Tungsten", 		kHexKey: @"#333333" },
		@{ kNameKey: @"Lead", 			kHexKey: @"#191919" },
		@{ kNameKey: @"Licorice", 		kHexKey: @"#000000" }, //Black
				
		@{ kNameKey: @"Marascino", 		kHexKey: @"#FF0000" }, //Red
		@{ kNameKey: @"Cayenne", 		kHexKey: @"#800000" },
		@{ kNameKey: @"Salmon", 		kHexKey: @"#FF6666" },
		@{ kNameKey: @"Maroon", 		kHexKey: @"#800040" },
		@{ kNameKey: @"Strawberry", 	kHexKey: @"#FF0080" },
		@{ kNameKey: @"Carnation", 		kHexKey: @"#FF6FCF" },
		@{ kNameKey: @"Magenta", 		kHexKey: @"#FF00FF" }, //Magenta
  		@{ kNameKey: @"Plum", 			kHexKey: @"#800080" },
		@{ kNameKey: @"BubbleGum", 		kHexKey: @"#FF66FF" },
  		@{ kNameKey: @"Lavender", 		kHexKey: @"#CC66FF" },
		@{ kNameKey: @"Grape", 			kHexKey: @"#8000FF" },
		@{ kNameKey: @"Eggplant", 		kHexKey: @"#400080" },
		@{ kNameKey: @"Blueberry", 		kHexKey: @"#0000FF" }, //Blue
		@{ kNameKey: @"Midnight", 		kHexKey: @"#000080" },
		@{ kNameKey: @"Orchid",			kHexKey: @"#6666FF" },
		@{ kNameKey: @"Ocean", 			kHexKey: @"#004080" },
		@{ kNameKey: @"Aqua", 			kHexKey: @"#0080FF" },
		@{ kNameKey: @"Sky", 			kHexKey: @"#66CCFF" },
		@{ kNameKey: @"Turquoise", 		kHexKey: @"#00FFFF" }, //Cyan
		@{ kNameKey: @"Teal", 			kHexKey: @"#008080" },
		@{ kNameKey: @"Ice", 			kHexKey: @"#66FFFF" },
		@{ kNameKey: @"Spindrift", 		kHexKey: @"#66FFCC" },
		@{ kNameKey: @"Sea Foam", 		kHexKey: @"#00FF80" },
		@{ kNameKey: @"Moss", 			kHexKey: @"#008040" },
		@{ kNameKey: @"Spring", 		kHexKey: @"#00FF00" }, //Green
		@{ kNameKey: @"Clover", 		kHexKey: @"#008000" },
		@{ kNameKey: @"Flora", 			kHexKey: @"#66FF66" },
		@{ kNameKey: @"Fern", 			kHexKey: @"#408000" },
		@{ kNameKey: @"Lime", 			kHexKey: @"#80FF00" },
		@{ kNameKey: @"Honeydew", 		kHexKey: @"#CCFF66" },
		@{ kNameKey: @"Lemon", 			kHexKey: @"#FFFF00" }, //Yellow
		@{ kNameKey: @"Asperagus", 		kHexKey: @"#808000" },		
		@{ kNameKey: @"Banana", 		kHexKey: @"#FFFF66" },
		@{ kNameKey: @"Cantaloupe", 	kHexKey: @"#FFCC66" },
		@{ kNameKey: @"Tangerine", 		kHexKey: @"#FF8000" },
		@{ kNameKey: @"Mocha", 			kHexKey: @"#804000" },		
	];
}

- (NSArray *)sortPaletteByHue:(NSArray *)palette {
	NSArray *sortedPalette = [palette sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *color1, NSDictionary *color2) {
	
		CGFloat hue, saturation, brightness, alpha;
		[[UIColor colorFromHexString:color1[kHexKey]] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
		
		CGFloat hue2, saturation2, brightness2, alpha2;
		[[UIColor colorFromHexString:color2[kHexKey]] getHue:&hue2 saturation:&saturation2 brightness:&brightness2 alpha:&alpha2];
		
		if (hue < hue2) {
			return NSOrderedAscending;
		} else if (hue > hue2) {
			return NSOrderedDescending;
		}
		
		if (saturation < saturation2) {
			return NSOrderedAscending;
		} else if (saturation > saturation2) {
			return NSOrderedDescending;
		}
		
		if (brightness < brightness2) {
			return NSOrderedAscending;
		} else if (brightness > brightness2) {
			return NSOrderedDescending;
		}
		
		return NSOrderedSame;
	}];
	
	return sortedPalette;
}

@end

