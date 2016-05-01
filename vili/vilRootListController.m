#include "vilRootListController.h"


@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end
@interface VILCustomHeaderView : UITableViewCell <PreferencesTableCustomView> {
	UILabel *title;
	UILabel *subLabel;
}
@end

@implementation vilRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}
void isKill(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    #pragma clang diagnostic pop
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	 CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &isKill, CFSTR("com.rdurant.vili/settingschanged"), NULL, 0);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.rdurant.vili/settingschanged"), NULL);
}

@end

@implementation VILCustomHeaderView
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect titleRect = CGRectMake(0, -15, width, 60);
        CGRect subLabelRect = CGRectMake(0, 20, width, 60);
        
        title = [[UILabel alloc] initWithFrame:titleRect];
        [title setNumberOfLines:1];
        title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:48];
        [title setText:@"Vili"];
        [title setBackgroundColor:[UIColor clearColor]];
        title.textColor = [UIColor colorWithRed:74/255.0f green:74/255.0f blue:74/255.0f alpha:1.0f];
        title.textAlignment = NSTextAlignmentCenter;
        
        subLabel = [[UILabel alloc] initWithFrame:subLabelRect];
        [subLabel setNumberOfLines:1];
        subLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [subLabel setText:@"An experimental music HUD."];
        [subLabel setBackgroundColor:[UIColor clearColor]];
        subLabel.textColor = [UIColor colorWithRed:74/255.0f green:74/255.0f blue:74/255.0f alpha:1.0f];
        subLabel.textAlignment = NSTextAlignmentCenter;

        
        [self addSubview:title];
        [self addSubview:subLabel];
        
    }
    return self;
}
@end


