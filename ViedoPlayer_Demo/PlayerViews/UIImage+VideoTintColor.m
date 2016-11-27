//
//  UIImage+VideoTintColor.m
//  ViedoPlayer_Demo
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "UIImage+VideoTintColor.h"

@implementation UIImage (VideoTintColor)



- (UIImage *) imageWithTintColor:(UIColor *)tintColor

{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
    
}

- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor

{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
    
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode

{
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    [tintColor setFill];
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tintedImage;
    
}




@end
