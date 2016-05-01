#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <SpringBoard/SBHUDView.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaRemote/MediaRemote.h>
#import <CBAutoScrollLabel/CBAutoScrollLabel.h>

@interface _UIBackdropView : UIView
-(id)initWithStyle:(long long)arg1 ;
@property (assign,nonatomic) long long style;    
-(id)initWithSettings:(id)arg1;
-(void)setTintOpacity:(double)arg1 ;
@end


@interface _UIBackdropViewSettings : NSObject {
}
@property (nonatomic,retain) UIColor *colorTint;  
@end

@interface SBMediaController : NSObject
-(float)volume;
+(id)sharedInstance;
@end

@interface SBHUDController : NSObject {

	UIWindow* _hudWindow;
	UIView* _hudContentView;
	SBHUDView* _hudView;
}
+(id)sharedHUDController;
-(void)_orderWindowOut:(id)arg1 ;
-(id)visibleHUDView;
-(void)hideHUDView;
-(void)_createUI;
-(void)presentHUDView:(id)arg1 ;
-(void)_tearDown;
-(void)dealloc;
- (UIColor*)pixelColorInImage:(UIImage*)image atX:(int)x atY:(int)y;
- (BOOL) updateColor:(UIColor *) newColor;
@end


UIView *bannerView;
_UIBackdropView *blurView;
UIImageView *albumArt;
CBAutoScrollLabel *artistTitle, *songTitle;
UIProgressView *volumeBar;


