@interface TWTweetComposeViewController : UIViewController
- (void)setInitialText:(NSString *)string;
@end

@interface PSViewController : UIViewController
@end

@interface PSListController : PSViewController {
	id _specifiers;
}
- (id)specifiers;
- (id)loadSpecifiersFromPlistName:(id)name target:(id)target;
@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;
@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
@end

@interface PSTableCell : UITableView
- (id)initWithStyle:(int)style reuseIdentifier:(id)arg2;
@end

@interface VolumeSliderPrefsListController: PSListController
- (void)respring;
- (void)followLogan;
@end

@implementation VolumeSliderPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"VolumeSliderPrefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage* customImg = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/VolumeSliderPrefs.bundle/twitterbutton.png"];
    UIBarButtonItem *_customButton = [[UIBarButtonItem alloc] initWithImage:customImg style:UIBarButtonItemStyleDone target:self action:@selector(share:)];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *iname = @"/Library/PreferenceBundles/VolumeSliderPrefs.bundle/VolumeSliderPrefs.png";
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = image;

    [super viewDidAppear:animated];
}

- (void)respring {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        system("killall -9 SpringBoard");
    }
}

- (void)followLogan {
	NSString *user = @"logandev22";
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	
	else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
	
	else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	
	else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	
	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

- (void)share:(UIBarButtonItem *)sender {
    TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];
    [tweetComposeViewController setInitialText:@"#VolumeSlider - A modern, unobtrusive volume slider!. Developed by @logandev22"];
    [self.navigationController presentViewController:tweetComposeViewController animated:YES 
   	completion:^{
    }];
}
@end

@interface VolumeSliderCustomCell : PSTableCell <PreferencesTableCustomView> {
	UILabel *label;
	UILabel *underLabel;
	UILabel *otherLabel;
}
@end

@implementation VolumeSliderCustomCell
- (id)initWithSpecifier:(id)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	if (self) {
		CGRect frame = CGRectMake(0, -15, [[UIScreen mainScreen] bounds].size.width, 60);
		CGRect underFrame = CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, 60);
		CGRect otherFrame = CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, 60);
 
		label = [[UILabel alloc] initWithFrame:frame];
		[label setNumberOfLines:1];
		label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:36];
		[label setText:@"VolumeSlider"];
		[label setBackgroundColor:[UIColor clearColor]];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentCenter;

		underLabel = [[UILabel alloc] initWithFrame:underFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[underLabel setText:@"A modern, unobtrusive volume slider!"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;

		otherLabel = [[UILabel alloc] initWithFrame:otherFrame];
		[otherLabel setNumberOfLines:1];
		otherLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[otherLabel setText:@"Created by Logan O’Connell"];
		[otherLabel setBackgroundColor:[UIColor clearColor]];
		otherLabel.textColor = [UIColor grayColor];
		otherLabel.textAlignment = NSTextAlignmentCenter;

		[self addSubview:label];
		[self addSubview:underLabel];
		[self addSubview:otherLabel];
	}
	
	return self;
}
 
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {

	CGFloat prefHeight = 90.0;
	return prefHeight;
}
@end