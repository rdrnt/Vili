#import "Vili.h"

//settings
static BOOL enabled;
static BOOL darkBlur;
static BOOL colorAlbum;
static BOOL roundArt;
static int keepAliveSeconds;

static NSString *const VilPrefsPath = @"/var/mobile/Library/Preferences/com.rdurant.vili.plist";
static void loadPreferences() {
	HBLogInfo(@"Preferences loaded...");
    	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:VilPrefsPath];

    	enabled = [dict objectForKey:@"enabled"] ? [[dict objectForKey:@"enabled"] boolValue] : TRUE;
    	darkBlur = [dict objectForKey:@"darkBlur"] ? [[dict objectForKey:@"darkBlur"] boolValue] : TRUE;
    	colorAlbum = [dict objectForKey:@"colorAlbum"] ? [[dict objectForKey:@"colorAlbum"] boolValue] : TRUE;
    	roundArt = [dict objectForKey:@"roundArt"] ? [[dict objectForKey:@"roundArt"] boolValue] : TRUE;
    	keepAliveSeconds= [dict objectForKey:@"keepAliveSeconds"] ? [[dict objectForKey:@"keepAliveSeconds"] intValue] : 2;

    	[dict release];
}

%hook SBHUDController
-(void)_createUI {
	%orig;
	loadPreferences();
	SBHUDView *view = MSHookIvar<SBHUDView *>(self, "_hudView");
	UIWindow *window = MSHookIvar<UIWindow *>(self, "_hudWindow");
	UIView *content = MSHookIvar<UIView *>(self, "_hudContentView");
	if (enabled) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];

		HBLogInfo(@"VILI: LOADED!");

		CGRect screenRect = [[UIScreen mainScreen] bounds];
		CGFloat screenWidth = screenRect.size.width;
		//CGFloat screenHeight = screenRect.size.height;

		view.hidden = YES;
		//window.hidden = YES;
		content.hidden = YES;

		//creating the bannerview
		bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
		bannerView.layer.masksToBounds = YES;

		if (darkBlur){
			blurView = [[_UIBackdropView alloc] initWithStyle:2030];
			[blurView setTintOpacity:0.20];
			bannerView.backgroundColor = [UIColor clearColor];
			HBLogInfo(@"Adding darkblur");
		}
		if (!darkBlur) {
			blurView = [[_UIBackdropView alloc] initWithStyle:2060];
			bannerView.backgroundColor = [UIColor clearColor];
			HBLogInfo(@"Adding light blur")
		}
		[bannerView insertSubview:blurView atIndex:0];

		//Album art
		CGRect albumArtFrame = CGRectMake(10,  (80-50) /2, 50, 50);

		//song text
		songTitle = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake((albumArtFrame.origin.x * 4) + 30, 10, 200, 25)];
		songTitle.textColor = [UIColor whiteColor];
		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
			NSDictionary *dict = (__bridge NSDictionary *)(information);
			if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] == nil) {
        				songTitle.text = @"No song";
        			}
        			if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] != nil) {
        				NSString *songText = [[NSString alloc] initWithString:[dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle]];
        				songTitle.text = songText;
        			}
		});
		songTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
		songTitle.labelSpacing = 13; // distance between start and end labels
		songTitle.pauseInterval = 0; // seconds of pause before scrolling starts again
		songTitle.scrollSpeed = 30; // pixels per second
		songTitle.fadeLength = 12.f; 
		songTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
		songTitle.scrollDirection = CBAutoScrollDirectionLeft;
    		[songTitle observeApplicationNotifications];

		//Artist Text
		artistTitle = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake((albumArtFrame.origin.x * 4) + 30, albumArtFrame.origin.y+30, 200, 25)];
		artistTitle.textColor = [UIColor whiteColor];
		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
			NSDictionary *dict = (__bridge NSDictionary *)(information);
			if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] == nil) {
        				artistTitle.text = @"No artist";
        			}
        			if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] != nil) {
        				NSString *artistText = [[NSString alloc] initWithString:[dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist]];
        				artistTitle.text = artistText;
        			}
		});
		artistTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
		artistTitle.labelSpacing = 13; // distance between start and end labels
		artistTitle.pauseInterval = 0; // seconds of pause before scrolling starts again
		artistTitle.scrollSpeed = 30; // pixels per second
		artistTitle.fadeLength = 12.f; 
		artistTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
		artistTitle.scrollDirection = CBAutoScrollDirectionLeft;
    		[artistTitle observeApplicationNotifications];

    		albumArt = [[UIImageView alloc] initWithFrame:albumArtFrame];
		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
			NSDictionary *dict=(__bridge NSDictionary *)(information);
			if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] == nil) {
				albumArt.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Vili.bundle/mrec.png"];
				[window addSubview:bannerView];
			}
			if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
				NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
				UIImage *finalImage = [UIImage imageWithData:artworkData];
				albumArt.image = finalImage;
				if (colorAlbum) {
					HBLogInfo(@"Removing blur, adding color");
					[blurView removeFromSuperview];
					UIColor *bgColor = [self pixelColorInImage:finalImage atX:finalImage.size.width/2 atY:finalImage.size.height/2 ];
					bannerView.backgroundColor = bgColor;
					if ([self updateColor:bgColor] == YES) {
						songTitle.textColor = [UIColor whiteColor];
						artistTitle.textColor = [UIColor whiteColor];
					}
					if ([self updateColor:bgColor] == NO) {
						songTitle.textColor = [UIColor blackColor];
						artistTitle.textColor = [UIColor blackColor];
					}
				}
				[window addSubview:bannerView];
			}
		});

		if (roundArt) {
			albumArt.layer.cornerRadius = 15;
		}
		albumArt.clipsToBounds = YES;

    		volumeBar = [[UIProgressView alloc] initWithFrame:CGRectMake((screenWidth - (screenWidth-25))/2,5,screenWidth-25,5)];
    		volumeBar.progressTintColor = [UIColor whiteColor];
    		volumeBar.progress = [[%c(SBMediaController) sharedInstance] volume];

		[UIView animateWithDuration:0.3
                          	delay:0.0
                        	options: UIViewAnimationCurveEaseIn
                     		animations:^{
                         		bannerView.frame = CGRectMake(0, 0, screenWidth, 80);
                     		} 
                     		completion:^(BOOL finished){
                     			[bannerView addSubview:songTitle];
                     			[bannerView addSubview:artistTitle];
                     			[bannerView addSubview:albumArt];
                     			[bannerView addSubview:volumeBar];
                     	}];
	}
	if (!enabled) {
		view.hidden = NO;
		window.hidden = NO;
		content.hidden = NO;
	}
}

%new
- (void)volumeChanged:(NSNotification *)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    volumeBar.progress = volume;
    HBLogInfo(@"Volume is %f", volume);
}


%new
- (BOOL) updateColor:(UIColor *) newColor
{
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);

    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5)
    {
        HBLogInfo(@"my color is dark");
        return YES;
    }
    else
    {
        HBLogInfo(@"my color is light");
        return NO;
    }
}

-(void)_orderWindowOut:(id)arg1 {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, keepAliveSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		%orig;
		if (enabled) {
			[songTitle removeFromSuperview];
			[artistTitle removeFromSuperview];
			[albumArt removeFromSuperview];
			[volumeBar removeFromSuperview];
			[UIView animateWithDuration:0.3
                          		delay:0.0
                        		options: UIViewAnimationCurveEaseOut
                     			animations:^{
                         			bannerView.frame = CGRectMake(0, 0, 500, 0);
                     			} 
                     			completion:^(BOOL finished){
                     		}];
		}
	});
}

%new
- (UIColor*)pixelColorInImage:(UIImage*)image atX:(int)x atY:(int)y {

    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);

    int pixelInfo = ((image.size.width * y) + x ) * 4; // 4 bytes per pixel

    UInt8 red   = data[pixelInfo + 0];
    UInt8 green = data[pixelInfo + 1];
    UInt8 blue  = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    UIColor *finalColor = [UIColor colorWithRed:red  /255.0f
                           green:green/255.0f
                            blue:blue /255.0f
                           alpha:alpha/255.0f];
    return finalColor;
}
%end

%ctor {
    loadPreferences();
}


