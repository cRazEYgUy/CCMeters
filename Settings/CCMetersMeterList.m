//
//  CCMetersMeterList.m
//  CCMeters Settings
//
//  Copyright (c) 2014-2015 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @"••••• [CCMeters|Settings]"
#import "../DebugLog.h"

#import "Headers/PSViewController.h"
#import "../Privates.h"


#define ICON_PATH		@"/Library/CCLoader/Bundles/CCMeters.bundle/"
#define ICON_COLOR		[UIColor colorWithRed:1 green:0 blue:0 alpha:1]

#define ENABLED_SEC		0
#define DISABLED_SEC	1


static CFStringRef const kPrefsAppID = CFSTR("com.sticktron.ccmeters");
static CFStringRef const kEnabledMetersKey = CFSTR("EnabledMeters");
static CFStringRef const kDisabledMetersKey = CFSTR("DisabledMeters");


@interface CCMetersMeterList : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *meters;
@property (nonatomic, strong) NSMutableArray *enabledMeters;
@property (nonatomic, strong) NSMutableArray *disabledMeters;
@end


@implementation CCMetersMeterList

- (instancetype)init {
	self = [super init];
	if (self) {
		self.title = @"Select Meters";
		
		// label dictionary
		_meters = @{ @"cpu":		@"CPU Used",
					 @"ram":		@"Memory Available",
					 @"disk":		@"Disk Space Free",
					 @"upload":		@"Upload Speed",
					 @"download":	@"Download Speed"
					};
		
		/* load preferences */
		
		CFPropertyListRef value;
		CFPreferencesAppSynchronize(kPrefsAppID);
		
		// get EnabledMeters pref
		value = CFPreferencesCopyAppValue(kEnabledMetersKey, kPrefsAppID);
		if (value) {
			_enabledMeters = [(__bridge NSArray *)value mutableCopy];
			CFRelease(value);
		} else {
			// default
			_enabledMeters = [@[@"cpu", @"ram", @"disk", @"upload", @"download"] mutableCopy];
		}
		
		// get DisabledMeters pref
		value = CFPreferencesCopyAppValue(kDisabledMetersKey, kPrefsAppID);
		if (value) {
			_disabledMeters = [(__bridge NSArray *)value mutableCopy];
			CFRelease(value);
		} else {
			// default
			_disabledMeters = [NSMutableArray array];
		}
	}
	
	return self;
}

- (void)loadView {
	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
												  style:UITableViewStyleGrouped];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 44.0f;
	self.tableView.editing = YES;
	
	self.view = self.tableView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)syncPrefs:(BOOL)notificate {
	DebugLog(@"########## SyncPrefs()");
	
	CFPreferencesSetAppValue(kEnabledMetersKey, (CFArrayRef)self.enabledMeters, kPrefsAppID);
	CFPreferencesSetAppValue(kDisabledMetersKey, (CFArrayRef)self.disabledMeters, kPrefsAppID);
	
	CFPreferencesAppSynchronize(kPrefsAppID);
	
	if (notificate) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
											 CFSTR("com.sticktron.ccmeters.settings-changed"),
											 NULL, NULL, YES);
	}
}

/* TableView Stuff */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == ENABLED_SEC) {
		return [self.enabledMeters count];
	} else {
		return [self.disabledMeters count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == ENABLED_SEC) {
		return @"ENABLED";
	} else {
		return @"DISABLED";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"MyCellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.opaque = YES;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.showsReorderControl = YES;
		cell.separatorInset = (UIEdgeInsets){0, 0, 0, 0};
	}
	
	// fetch meter and setup cell ...

	if ((indexPath.section == ENABLED_SEC && [self.enabledMeters count]) || (indexPath.section == DISABLED_SEC && [self.disabledMeters count])) {
		
		NSString *meter = (indexPath.section == ENABLED_SEC ? self.enabledMeters[indexPath.row] : self.disabledMeters[indexPath.row]);
		cell.textLabel.text = self.meters[meter];
		
		NSString *path = [NSString stringWithFormat:@"%@%@.png", ICON_PATH, meter];
		UIImage *icon = [UIImage imageWithContentsOfFile:path];
		
		if (icon) {
			// make tintable
			//icon = [icon _flatImageWithColor:ICON_COLOR];
			icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
			cell.imageView.image = icon;
		}
	}
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSIndexPath *dest = proposedDestinationIndexPath;
	
	// if the destination section is empty, return row 0
	if ((dest.section == ENABLED_SEC && !self.enabledMeters.count) || (dest.section == DISABLED_SEC && !self.disabledMeters.count)) {
        return [NSIndexPath indexPathForRow:0 inSection:dest.section];
    } else {
        return dest;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == ENABLED_SEC) {
		
		// moving from Enabled ...
		
		NSString *sourceMeter = self.enabledMeters[sourceIndexPath.row];
		[self.enabledMeters removeObjectAtIndex:sourceIndexPath.row];
		//DebugLog(@"##### removed (%@) from enabledMeters[%d]", sourceID, (int)sourceIndexPath.row);
		//DebugLog(@"##### enabledMeters=%@", self.enabledMeters);
        
        if (destinationIndexPath.section == ENABLED_SEC) {
			
			// ... to Enabled
			
            [self.enabledMeters insertObject:sourceMeter atIndex:destinationIndexPath.row];
			//DebugLog(@"##### added (%@) to enabledMeters[%d]", sourceID, (int)destinationIndexPath.row);
			//DebugLog(@"##### enabledMeters=%@", self.enabledMeters);
			
        } else {
			
			// ... to Disabled
			
            //[self.disabledMeters insertObject:sourceMeter atIndex:(emptyRow ? 0 : destinationIndexPath.row)];
            [self.disabledMeters insertObject:sourceMeter atIndex:destinationIndexPath.row];
			//DebugLog(@"##### added (%@) to disabledMeters[%d]", sourceID, (int)destinationIndexPath.row);
			//DebugLog(@"##### disabledMeters=%@", self.disabledMeters);
        }
		
    } else if (sourceIndexPath.section == 1) {
		
		// moving from Disabled ...
		
		NSString *sourceMeter = self.disabledMeters[sourceIndexPath.row];
		[self.disabledMeters removeObjectAtIndex:sourceIndexPath.row];

		if (destinationIndexPath.section == 1) {
			
			// ... to Disabled
			
			[self.disabledMeters insertObject:sourceMeter atIndex:destinationIndexPath.row];
			
		} else {
			
			// ... to Enabled
			
			[self.enabledMeters insertObject:sourceMeter atIndex:destinationIndexPath.row];
		}
    }
    
	// save changes
	[self syncPrefs:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == ENABLED_SEC && [self.enabledMeters count]) || (indexPath.section == DISABLED_SEC && [self.disabledMeters count]));
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

@end

