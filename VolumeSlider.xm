#import "VolumeSlider.h"

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;

	volumeSliderWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale)];
	volumeSliderWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	volumeSliderWindow.alpha = 1.0;
	volumeSliderWindow.hidden = YES;
	volumeSliderWindow.backgroundColor = [UIColor clearColor];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:[%c(SBHUDController) sharedHUDController] action:@selector(volumeSliderShouldHide:)];
	[volumeSliderWindow addGestureRecognizer:tap];

	UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:[%c(SBHUDController) sharedHUDController] action:@selector(volumeSliderShouldHide:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [volumeSliderWindow addGestureRecognizer:swipe];

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
- (void)volumeSliderMoved:(id)sender {
	[[%c(SBMediaController) sharedInstance] setVolume:volumeSlider.value];
}

%new
- (void)updateVolumeSlider:(NSNotification *)notification {
	volumeSlider.value = [[%c(SBMediaController) sharedInstance] volume];
}

%new
- (void)orientationChanged:(NSNotification *)notification {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			volumeSliderWindow.transform = CGAffineTransformIdentity;

			volumeSliderWindow.frame = CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale);

			effectBGView.frame = CGRectMake(0, 0, screenWidth, screenHeightScale);

			volumeSlider.frame = CGRectMake(screenHeightScale, 0, screenWidth - (screenHeightScale * 2), screenHeightScale);

			volumeSliderOnImage.frame = CGRectMake((screenHeightScale / 2) - 15 + (screenWidth - screenHeightScale), (screenHeightScale / 2) - 15, 30, 30);

			break;
		case UIInterfaceOrientationLandscapeLeft:
			volumeSliderWindow.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);

			volumeSliderWindow.frame = CGRectMake(0 - screenHeightScale, 0, screenHeightScale, screenHeight);

			effectBGView.frame = CGRectMake(0, 0, screenHeight, screenHeightScale);

			volumeSlider.frame = CGRectMake(screenHeightScale, 0, screenHeight - (screenHeightScale * 2), screenHeightScale);

			volumeSliderOnImage.frame = CGRectMake((screenHeightScale / 2) - 15 + (screenHeight - screenHeightScale), (screenHeightScale / 2) - 15, 30, 30);

			break;
		case UIInterfaceOrientationLandscapeRight:
			volumeSliderWindow.transform = CGAffineTransformMakeRotation(M_PI_2);

			volumeSliderWindow.frame = CGRectMake(screenWidth, 0, screenHeightScale, screenHeight);

			effectBGView.frame = CGRectMake(0, 0, screenHeight, screenHeightScale);

			volumeSlider.frame = CGRectMake(screenHeightScale, 0, screenHeight - (screenHeightScale * 2), screenHeightScale);

			volumeSliderOnImage.frame = CGRectMake((screenHeightScale / 2) - 15 + (screenHeight - screenHeightScale), (screenHeightScale / 2) - 15, 30, 30);

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			volumeSliderWindow.transform = CGAffineTransformMakeRotation(M_PI);

			volumeSliderWindow.frame = CGRectMake(0, screenHeight + screenHeightScale, screenWidth, screenHeightScale);

			effectBGView.frame = CGRectMake(0, 0, screenWidth, screenHeightScale);

			volumeSlider.frame = CGRectMake(screenHeightScale, 0, screenWidth - (screenHeightScale * 2), screenHeightScale);

			volumeSliderOnImage.frame = CGRectMake((screenHeightScale / 2) - 15 + (screenWidth - screenHeightScale), (screenHeightScale / 2) - 15, 30, 30);

			break;
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

		[self volumeSliderShouldShow:nil];
	}

	else {
		%orig;
	}
}

%new
- (void)volumeSliderShouldShow:(id)sender {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self showVolumeSliderWithFrame:CGRectMake(0, 0, screenWidth, screenHeightScale)];

			break;
		case UIInterfaceOrientationLandscapeLeft:
			[self showVolumeSliderWithFrame:CGRectMake(0, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationLandscapeRight:
			[self showVolumeSliderWithFrame:CGRectMake(screenWidth - screenHeightScale, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[self showVolumeSliderWithFrame:CGRectMake(screenHeight - screenHeightScale, 0, screenWidth, screenHeightScale)];

			break;
	}
}

%new
- (void)volumeSliderShouldHide:(id)sender {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self hideVolumeSliderWithFrame:CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale)];

			break;
		case UIInterfaceOrientationLandscapeLeft:
			[self hideVolumeSliderWithFrame:CGRectMake(0 - screenHeightScale, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationLandscapeRight:
			[self hideVolumeSliderWithFrame:CGRectMake(screenWidth, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[self hideVolumeSliderWithFrame:CGRectMake(0, screenHeight + screenHeightScale, screenWidth, screenHeightScale)];

			break;
	}
}

%new
- (void)showVolumeSliderWithFrame:(CGRect)frame {
	[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
					
		volumeSliderWindow.hidden = NO;
		CGRect newWindowFrame = frame;
		volumeSliderWindow.frame = newWindowFrame;
	}
	completion:^(BOOL finished) {
		[timer invalidate];
		timer = nil;
		timer = [[NSTimer scheduledTimerWithTimeInterval:delayDuration target:self selector:@selector(volumeSliderShouldHide:) userInfo:nil repeats:NO] retain];
	}];
}

%new
- (void)hideVolumeSliderWithFrame:(CGRect)frame {
	[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		CGRect newWindowFrame = frame;
		volumeSliderWindow.frame = newWindowFrame;
	}
	completion:^(BOOL finished) {
		volumeSliderWindow.hidden = YES;
	}];
}
%end

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.TweaksByLogan.VolumeSlider/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}