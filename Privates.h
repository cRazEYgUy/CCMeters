//
//  Privates.h
//  NCMeters
//
//  Private APIs.
//
//

#import <UIKit/UIImage.h>

// UIImage-Private.h
@interface UIImage (Private)
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
- (id)_flatImageWithColor:(id)arg;
@end

// UIView-Private.h
@interface UIView (Private)
- (void)_setDrawsAsBackdropOverlayWithBlendMode:(long long)arg1;
- (void)_setDrawsAsBackdropOverlay:(_Bool)arg1;
- (id)_generateBackdropMaskImage;
@end

