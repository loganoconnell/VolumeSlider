#import <Flipswitch/Flipswitch.h>

@interface UIApplication (VolumeSlider)
- (UIInterfaceOrientation)_frontMostAppOrientation;
@end

@interface UIImage (VolumeSlider)
- (UIImage *)_flatImageWithColor:(UIColor *)color;
@end

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
+ (SBHUDController *)sharedHUDController;
- (void)presentHUDView:(SBHUDView *)arg1 autoDismissWithDelay:(double)arg2;
- (void)volumeSliderShouldShow:(id)sender;
- (void)volumeSliderShouldHide:(id)sender;
- (void)showVolumeSliderWithFrame:(CGRect)frame;
- (void)hideVolumeSliderWithFrame:(CGRect)frame;
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