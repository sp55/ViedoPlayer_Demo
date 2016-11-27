//
//  UIImage+VideoScaleToSize.h
//  ViedoPlayer_Demo
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VideoScaleToSize)


/**
 重新绘制图片大小
 
 @param image 原始图片
 @param size  需要的大小
 
 @return 返回改变大小后图片
 */
-(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size;


@end
