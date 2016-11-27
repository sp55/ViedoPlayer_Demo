//
//  ViewController.m
//  ViedoPlayer_Demo
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerView.h"
#import "UIView+VideoSetRect.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    VideoPlayerView *playerView = [[VideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
    [self.view addSubview:playerView];
    
    
    //视频地址
    playerView.url = [NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0215/56c1809735217_wpd.mp4"];
    //播放
    [playerView playVideo];
    //返回按钮点击事件回调
    [playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    //播放完成回调
    [playerView endPlay:^{
        NSLog(@"播放完成");
    }];

}


@end
