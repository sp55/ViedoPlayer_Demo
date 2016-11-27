//
//  UIImage+VideoScaleToSize.m
//  ViedoPlayer_Demo
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "UIImage+VideoScaleToSize.h"

@implementation UIImage (VideoScaleToSize)


-(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size
{
    //size为CGSize类型，即你所需要的图片尺寸
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}



@end
