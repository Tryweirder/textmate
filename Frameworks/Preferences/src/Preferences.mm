#import "Preferences.h"
#import "FilesPreferences.h"
#import "ProjectsPreferences.h"
#import "BundlesPreferences.h"
#import "VariablesPreferences.h"
#import "SoftwareUpdatePreferences.h"
#import "TerminalPreferences.h"
#import "Keys.h"
#import <MASPreferences/MASPreferencesWindowController.h>
#import <oak/debug.h>

OAK_DEBUG_VAR(Preferences);

@implementation MASPreferencesWindowController (GoToNextPreviousTab)
- (IBAction)selectNextTab:(id)sender      { [self goNextTab:sender];     }
- (IBAction)selectPreviousTab:(id)sender  { [self goPreviousTab:sender]; }
@end

@interface Preferences ()
@property (nonatomic) MASPreferencesWindowController* windowController;
@property (nonatomic) NSArray* viewControllers;
@end

@implementation Preferences
+ (instancetype)sharedInstance
{
	static Preferences* sharedInstance = [self new];
	return sharedInstance;
}

- (NSWindowController*)windowController
{
	if(!_windowController)
	{
		self.viewControllers = @[
			[FilesPreferences new],
			[ProjectsPreferences new],
			[BundlesPreferences new],
			[VariablesPreferences new],
			[SoftwareUpdatePreferences new],
			[TerminalPreferences new]
		];

		self.windowController = [[MASPreferencesWindowController alloc] initWithViewControllers:self.viewControllers];
		_windowController.nextResponder = self;
	}
	return _windowController;
}

- (void)showWindow:(id)sender
{
	[self.windowController showWindow:self];
}

- (void)takeSelectedViewControllerFrom:(id)sender
{
	if([sender respondsToSelector:@selector(representedObject)])
		[self.windowController selectControllerWithIdentifier:[sender representedObject]];
}

- (void)updateShowTabMenu:(NSMenu*)aMenu
{
	if(![self.windowController.window isKeyWindow])
		return;

	NSString* const selectedIdentifier = [self.windowController selectedViewController].identifier;

	int i = 0;
	for(NSViewController <MASPreferencesViewController>* viewController in _viewControllers)
	{
		NSMenuItem* item = [aMenu addItemWithTitle:viewController.title action:@selector(takeSelectedViewControllerFrom:) keyEquivalent:i < 9 ? [NSString stringWithFormat:@"%c", '1' + i] : @""];
		item.representedObject = viewController.identifier;
		item.target = self;
		if([viewController.identifier isEqualToString:selectedIdentifier])
			[item setState:NSControlStateValueOn];
		++i;
	}
}
@end
