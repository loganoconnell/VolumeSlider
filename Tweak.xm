#import <flipswitch/flipswitch.h>

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (float)volume;
- (void)setVolume:(float)volume;
- (BOOL)isRingerMuted;
@end

@interface SBHUDView : UIView
- (NSString *)title;
@end

@interface SBHUDController : UIViewController
- (void)presentHUDView:(SBHUDView *)arg1 autoDismissWithDelay:(double)arg2;
@end

@interface UIApplication (VolumeSlider)
- (int)_frontMostAppOrientation;
@end

UIWindow *volumeSliderWindow;
UIVisualEffectView *effectBGView;

UISlider *volumeSlider;
UIImageView *volumeSliderOnImage;
UIImageView *volumeSliderOffImage;

NSTimer *timer;

NSBundle *templateBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/VolumeSliderPrefs.bundle/IconTemplate.bundle"];
NSBundle *templateBundle2 = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/VolumeSliderPrefs.bundle/IconTemplate2.bundle"];

static CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
static CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

static BOOL enabled;
static NSString *mainColor;
static NSString *blurType;
static float screenHeightScale;
static float delayDuration;
static float animationDuration;
static float cornerRadius;

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.TweaksByLogan.VolumeSlider.plist"];

	enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
	mainColor = [prefs objectForKey:@"mainColor"] ? [prefs objectForKey:@"mainColor"] : @"white";
	blurType = [prefs objectForKey:@"blurType"] ? [prefs objectForKey:@"blurType"] : @"dark";
	screenHeightScale = [prefs objectForKey:@"screenHeightScale"] ? [[prefs objectForKey:@"screenHeightScale"] floatValue] : 65.0;
	delayDuration = [prefs objectForKey:@"delayDuration"] ? [[prefs objectForKey:@"delayDuration"] floatValue] : 1.25;
	animationDuration = [prefs objectForKey:@"animationDuration"] ? [[prefs objectForKey:@"animationDuration"] floatValue] : 0.25;
	cornerRadius = [prefs objectForKey:@"cornerRadius"] ? [[prefs objectForKey:@"cornerRadius"] floatValue] : 0.0;
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;

	volumeSliderWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale)];
	volumeSliderWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	volumeSliderWindow.alpha = 1.0;
	volumeSliderWindow.hidden = YES;
	volumeSliderWindow.backgroundColor = [UIColor clearColor];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHideVolumeSlider:)];
	[volumeSliderWindow addGestureRecognizer:tap];

	if ([blurType isEqual:@"extralight"]) {
		effectBGView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
	}

	else if ([blurType isEqual:@"light"]) {
		effectBGView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
	}

	else {
		effectBGView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	}
	effectBGView.frame = CGRectMake(0, 0, screenWidth, screenHeightScale);
	effectBGView.layer.cornerRadius = cornerRadius;
	effectBGView.clipsToBounds = true;
	[volumeSliderWindow addSubview:effectBGView];

	volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(screenHeightScale, 0, screenWidth - (screenHeightScale * 2), screenHeightScale)];
	volumeSlider.backgroundColor = [UIColor clearColor];
	volumeSlider.continuous = YES;
	volumeSlider.minimumValue = 0.0;
	volumeSlider.maximumValue = 1.0;
	volumeSlider.value = [[%c(SBMediaController) sharedInstance] volume];
	volumeSlider.maximumTrackTintColor = [UIColor grayColor];
	if ([mainColor isEqual:@"black"]) {
		volumeSlider.minimumTrackTintColor = [UIColor blackColor];
	}

	else {
		volumeSlider.minimumTrackTintColor = [UIColor whiteColor];
	}
	[volumeSlider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
	[effectBGView.contentView addSubview:volumeSlider];

	if ([mainColor isEqual:@"black"]) {
		volumeSliderOffImage = [[UIImageView alloc] initWithImage:[[FSSwitchPanel sharedPanel] imageOfSwitchState:FSSwitchStateOff controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundle2]];
	}

	else {
		volumeSliderOffImage = [[UIImageView alloc] initWithImage:[[FSSwitchPanel sharedPanel] imageOfSwitchState:FSSwitchStateOff controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundle]];
	}
	volumeSliderOffImage.frame = CGRectMake((screenHeightScale / 2) - 15, (screenHeightScale / 2) - 15, 30, 30);
	[effectBGView.contentView addSubview:volumeSliderOffImage];

	if ([mainColor isEqual:@"black"]) {
		volumeSliderOnImage = [[UIImageView alloc] initWithImage:[[FSSwitchPanel sharedPanel] imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundle2]];
	}

	else {
		volumeSliderOnImage = [[UIImageView alloc] initWithImage:[[FSSwitchPanel sharedPanel] imageOfSwitchState:FSSwitchStateOn controlState:UIControlStateNormal forSwitchIdentifier:@"com.a3tweaks.switch.ringer" usingTemplate:templateBundle]];
	}
	volumeSliderOnImage.frame = CGRectMake((screenHeightScale / 2) - 15 + (screenWidth - screenHeightScale), (screenHeightScale / 2) - 15, 30, 30);
	[effectBGView.contentView addSubview:volumeSliderOnImage];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVolumeSlider:) name:@"SBMediaVolumeChangedNotification" object:[%c(SBMediaController) sharedInstance]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

%new
- (void)tapToHideVolumeSlider:(id)sender {
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) {
		[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			CGRect newWindowFrame = CGRectMake(screenWidth, 0, screenHeightScale, screenHeight);
			volumeSliderWindow.frame = newWindowFrame;
		}
		completion:^(BOOL finished) {
			volumeSliderWindow.hidden = YES;
		}];
	}

	else {
		[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			CGRect newWindowFrame = CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale);
			volumeSliderWindow.frame = newWindowFrame;
		}
		completion:^(BOOL finished) {
			volumeSliderWindow.hidden = YES;
		}];
	}
}

%new
- (void)volumeSliderMoved:(id)sender {
	[[%c(SBMediaController) sharedInstance] setVolume:volumeSlider.value];
}

%new
- (void)updateVolumeSlider:(NSNotification *)notification {
	volumeSlider.value = [[%c(SBMediaController) sharedInstance] volume];
}

%new
- (void)orientationChanged:(NSNotification *)notification {
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) {
		volumeSliderWindow.transform = CGAffineTransformMakeRotation(M_PI_2);

		volumeSliderWindow.frame = CGRectMake(screenWidth, 0, screenHeightScale, screenHeight);

		effectBGView.frame = CGRectMake(0, 0, screenHeight, screenHeightScale);

		volumeSlider.frame = CGRectMake(screenHeightScale, 0, screenHeight - (screenHeightScale * 2), screenHeightScale);

		volumeSliderOnImage.frame = CGRectMake((screenHeightScale / 2) - 15 + (screenHeight - screenHeightScale), (screenHeightScale / 2) - 15, 30, 30);
	}

	else {
		volumeSliderWindow.transform = CGAffineTransformIdentity;

		volumeSliderWindow.frame = CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale);

		effectBGView.frame = CGRectMake(0, 0, screenWidth, screenHeightScale);

		volumeSlider.frame = CGRectMake(screenHeightScale, 0, screenWidth - (screenHeightScale * 2), screenHeightScale);

		volumeSliderOnImage.frame = CGRectMake((screenHeightScale / 2) - 15 + (screenWidth - screenHeightScale), (screenHeightScale / 2) - 15, 30, 30);
	}
}
%end

%hook SBHUDController
- (void)presentHUDView:(SBHUDView *)arg1 autoDismissWithDelay:(double)arg2 {
	if (enabled) {
		if ([arg1.title isEqual:@"Ringer"]) {
			volumeSlider.userInteractionEnabled = NO;
			if ([[%c(SBMediaController) sharedInstance] isRingerMuted]) {
				volumeSlider.value = 0.0;
			}

			else {
				volumeSlider.value = 1.0;
			}
		}

		else {
			volumeSlider.userInteractionEnabled = YES;
			volumeSlider.value = [[%c(SBMediaController) sharedInstance] volume];
		}

		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) {
			[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
					
				volumeSliderWindow.hidden = NO;
				CGRect newWindowFrame = CGRectMake(screenWidth - screenHeightScale, 0, screenHeightScale, screenHeight);
				volumeSliderWindow.frame = newWindowFrame;
			}
			completion:^(BOOL finished) {
				[timer invalidate];
				timer = nil;
				timer = [[NSTimer scheduledTimerWithTimeInterval:delayDuration target:self selector:@selector(hideVolumeSlider:) userInfo:nil repeats:NO] retain];
			}];
		}

		else {
			[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
					
				volumeSliderWindow.hidden = NO;
				CGRect newWindowFrame = CGRectMake(0, 0, screenWidth, screenHeightScale);
				volumeSliderWindow.frame = newWindowFrame;
			}
			completion:^(BOOL finished) {
				[timer invalidate];
				timer = nil;
				timer = [[NSTimer scheduledTimerWithTimeInterval:delayDuration target:self selector:@selector(hideVolumeSlider:) userInfo:nil repeats:NO] retain];
			}];
		}
	}

	else {
		%orig;
	}
}

%new
- (void)hideVolumeSlider:(id)sender {
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) {
		[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			CGRect newWindowFrame = CGRectMake(screenWidth, 0, screenHeightScale, screenHeight);
			volumeSliderWindow.frame = newWindowFrame;
		}
		completion:^(BOOL finished) {
			volumeSliderWindow.hidden = YES;
		}];
	}

	else {
		[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			CGRect newWindowFrame = CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale);
			volumeSliderWindow.frame = newWindowFrame;
		}
		completion:^(BOOL finished) {
			volumeSliderWindow.hidden = YES;
		}];
	}
}
%end

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.TweaksByLogan.VolumeSlider/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}