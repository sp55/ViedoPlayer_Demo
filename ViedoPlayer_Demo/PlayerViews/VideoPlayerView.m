//
//  VideoPlayerView.m
//  ViedoPlayer_Demo
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+VideoSetRect.h"
#import "UIImage+VideoTintColor.h"
#import "UIImage+VideoScaleToSize.h"
#import "VideoSlider.h"


//间隙
#define Padding        10
//消失时间
#define DisappearTime  4
//顶部底部控件高度
#define ViewHeight     50
//按钮大小
#define ButtonSize     35
//滑块大小
#define SliderSize     20
//进度条颜色
#define ProgressColor     [UIColor colorWithRed:1.00000f green:1.00000f blue:1.00000f alpha:0.40000f]
//缓冲颜色
#define ProgressTintColor [UIColor colorWithRed:1.00000f green:1.00000f blue:1.00000f alpha:1.00000f]
//播放完成颜色
#define PlayFinishColor   [UIColor redColor]
//滑块颜色
#define SliderColor       [UIColor redColor]



@interface VideoPlayerView ()
/**控件原始Frame*/
@property (nonatomic,assign) CGRect customFrame;
/**父类的父类控件*/
@property (nonatomic,strong) UIView *topSuperView;
/**父类控件原始Frame*/
@property (nonatomic,assign) CGRect customSuperViewFrame;

/**播放器*/
@property(nonatomic,strong)AVPlayer *player;
/**playerLayer*/
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
/**播放器item*/
@property(nonatomic,strong)AVPlayerItem *playerItem;
/**播放进度条*/
@property(nonatomic,strong)VideoSlider *slider;
/**播放时间*/
@property(nonatomic,strong)UILabel *currentTimeLabel;
/**表面View*/
@property(nonatomic,strong)UIView *backView;
/**转子*/
@property(nonatomic,strong)UIActivityIndicatorView *activity;
/**缓冲进度条*/
@property(nonatomic,strong)UIProgressView *progress;
/**顶部控件*/
@property(nonatomic,strong) UIView *topView;
/**底部控件 */
@property (nonatomic,strong) UIView *bottomView;
/**播放按钮*/
@property (nonatomic,strong) UIButton *startButton;
/**轻拍定时器*/
@property (nonatomic,strong) NSTimer *timer;

/**返回按钮回调*/
@property (nonatomic,copy) void(^BackBlock) (UIButton *backButton);
/**播放完成回调*/
@property (nonatomic,copy) void(^EndBlock) ();
@end

@implementation VideoPlayerView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _customFrame = frame;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}
#pragma mark - 传入播放地址
-(void)setUrl:(NSURL *)url
{
    _url = url;
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [self creatUI];
}
#pragma mark - 创建播放器UI
- (void)creatUI
{
    if (ScreenWidth < ScreenHeight)
    {
        self.frame = _customFrame;
        _playerLayer.frame = CGRectMake(0, 0, _customFrame.size.width, _customFrame.size.height);
    }
    else
    {
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _playerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }
    
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:_playerLayer];
    
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    
    //最上面的View
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, _playerLayer.frame.origin.y, _playerLayer.frame.size.width, _playerLayer.frame.size.height)];
    _backView.backgroundColor = [UIColor clearColor];
    [self addSubview:_backView];
    
    //顶部View条
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, ViewHeight)];
    _topView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    [_backView addSubview:_topView];
    //底部View条
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _backView.height - ViewHeight, self.frame.size.width, ViewHeight)];
    _bottomView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    [_backView addSubview:_bottomView];
    // 监听loadedTimeRanges属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //创建播放按钮
    [self createButton];
    //创建进度条
    [self createProgress];
    //创建播放条
    [self createSlider];
    //创建时间Label
    [self createCurrentTimeLabel];
    //创建返回按钮
    [self createBackButton];
    //创建全屏按钮
    [self createMaxButton];
    //创建点击手势
    [self createGesture];
    
    //转子
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.center = _backView.center;
    [self addSubview:_activity];
    [_activity startAnimating];
    
    //计时器，循环执行
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeStack) userInfo:nil repeats:YES];
    //工具条定时消失
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime target:self selector:@selector(disappear) userInfo:nil repeats:NO];
}
#pragma mark - 状态栏
- (BOOL)prefersStatusBarHidden
{
    // 返回NO表示要显示，返回YES将hiden
    return YES;
}
#pragma mark - 创建UISlider
- (void)createSlider
{
    self.slider = [[VideoSlider alloc]init];
    _slider.frame = CGRectMake(_progress.x, 0, _progress.width, ViewHeight);
    _slider.centerY = _bottomView.height/2.0;
    [_bottomView addSubview:_slider];
    //自定义滑块大小
    UIImage *image = [UIImage imageNamed:@"iconfont-yuan"];
    //改变滑块大小
    UIImage *tempImage = [image OriginImage:image scaleToSize:CGSizeMake( SliderSize, SliderSize)];
    //改变滑块颜色
    UIImage *newImage = [tempImage imageWithTintColor:SliderColor];
    [_slider setThumbImage:newImage forState:UIControlStateNormal];
    //添加监听
    [_slider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    //左边颜色
    _slider.minimumTrackTintColor = PlayFinishColor;
    //右边颜色
    _slider.maximumTrackTintColor = [UIColor clearColor];
}

#pragma mark - 拖动进度条
- (void)progressSlider:(UISlider *)slider
{
    //拖动改变视频播放进度
    if (_player.status == AVPlayerStatusReadyToPlay)
    {
        //暂停
        [self pausePlay];
        
        //计算出拖动的当前秒数
        CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        
        [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
            //继续播放
            [self playVideo];
        }];
        
    }
}
#pragma mark - 创建UIProgressView
- (void)createProgress
{
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(_startButton.right + Padding, 0, self.frame.size.width - 80 - Padding - _startButton.right - Padding - Padding, Padding)];
    self.progress.centerY = _bottomView.height/2.0;
    
    //进度条颜色
    self.progress.trackTintColor = ProgressColor;
    // 计算缓冲进度
    NSTimeInterval timeInterval = [self availableDuration];
    CMTime duration = self.playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    [self.progress setProgress:timeInterval / totalDuration animated:NO];
    
    CGFloat time = round(timeInterval);
    CGFloat total = round(totalDuration);
    
    //确保都是number
    if (isnan(time) == 0 && isnan(total) == 0)
    {
        if (time == total)
        {
            //缓冲进度颜色
            self.progress.progressTintColor = ProgressTintColor;
        }
        else
        {
            //缓冲进度颜色
            self.progress.progressTintColor = [UIColor clearColor];
        }
    }
    else
    {
        //缓冲进度颜色
        self.progress.progressTintColor = [UIColor clearColor];
    }
    [_bottomView addSubview:_progress];
}
#pragma mark - 缓存条监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.progress setProgress:timeInterval / totalDuration animated:NO];
        //设置缓存进度颜色
        self.progress.progressTintColor = ProgressTintColor;
    }
}
//计算缓冲进度
- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark - 创建播放时间
- (void)createCurrentTimeLabel
{
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, Padding)];
    self.currentTimeLabel.centerY = _progress.centerY;
    self.currentTimeLabel.right = self.backView.right - Padding;
    [_bottomView addSubview:_currentTimeLabel];
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [UIFont systemFontOfSize:12];
    _currentTimeLabel.text = @"00:00/00:00";
}
#pragma mark - 计时器事件
- (void)timeStack
{
    if (_playerItem.duration.timescale != 0)
    {
        _slider.maximumValue = 1;//总共时长
        _slider.value = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);//当前进度
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        //duration 总时长
        NSInteger durMin = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总分钟
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", proMin, proSec, durMin, durSec];
        
    }
    //开始播放停止转子
    if (_player.status == AVPlayerStatusReadyToPlay)
    {
        [_activity stopAnimating];
    }
    else
    {
        [_activity startAnimating];
    }
}
#pragma mark - 播放按钮
- (void)createButton
{
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame = CGRectMake(Padding, 0, ButtonSize, ButtonSize);
    _startButton.centerY = _bottomView.height/2.0;
    [_bottomView addSubview:_startButton];
    _startButton.tintColor = [UIColor whiteColor];
    
    //根据播放状态来设置播放按钮
    if (_player.rate == 1.0)
    {
        _startButton.selected = YES;
        [_startButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
    }
    else
    {
        _startButton.selected = NO;
        [_startButton setBackgroundImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    }
    [_startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma mark - 播放暂停按钮方法
- (void)startAction:(UIButton *)button
{
    if (button.selected == YES)
    {
        [self pausePlay];
    }
    else
    {
        [self playVideo];
    }
    button.selected =!button.selected;
}
#pragma mark - 返回按钮方法
- (void)createBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(Padding - 5, 0, ButtonSize, ButtonSize);
    button.centerY = _topView.centerY;
    button.tintColor = [UIColor whiteColor];
    [button setBackgroundImage:[UIImage imageNamed:@"iconfont-back"] forState:UIControlStateNormal];
    [_topView addSubview:button];
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 全屏按钮
- (void)createMaxButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, ButtonSize, ButtonSize);
    button.right = _topView.right - Padding;
    button.centerY = _topView.centerY;
    button.tintColor = [UIColor whiteColor];
    if (ScreenWidth < ScreenHeight)
    {
        [button setBackgroundImage:[UIImage imageNamed:@"max"] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:@"min"] forState:UIControlStateNormal];
    }
    
    [button addTarget:self action:@selector(maxAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:button];
}
#pragma mark - 横屏代码
- (void)maxAction:(UIButton *)button
{
    //取消定时消失
    [_timer invalidate];
    
    if (ScreenWidth < ScreenHeight)
    {
        //记录父类的父类和父类的位置大小
        _topSuperView = self.superview.superview;
        _customSuperViewFrame = self.superview.frame;
        //横屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        //改变父类大小
        self.superview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        //将父类添加到window上面
        UIView *superView = self.superview;
        [self.window addSubview:superView];
        //删除原有控件
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        //创建全屏控件
        [self creatUI];
    }
    else
    {
        
        //旋转屏幕
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        //还原父类控件范围大小
        self.superview.frame = _customSuperViewFrame;
        //将父类添加到原有控件上
        UIView *superView = self.superview;
        [_topSuperView addSubview:superView];
        //删除
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        //创建小屏UI
        [self creatUI];
    }
}

#pragma mark - 创建手势
- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}
#pragma mark - 轻拍方法
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (_backView.alpha == 1)
    {
        //取消定时消失
        [_timer invalidate];
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 0;
        }];
    } else if (_backView.alpha == 0)
    {
        //添加定时消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime target:self selector:@selector(disappear) userInfo:nil repeats:NO];
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 1;
        }];
    }
}
#pragma mark - 定时消失
- (void)disappear
{
    [UIView animateWithDuration:0.5 animations:^{
        _backView.alpha = 0;
    }];
}
#pragma mark - 播放完成
- (void)moviePlayDidEnd:(id)sender
{
    [self pausePlay];
    self.EndBlock();
}
- (void)endPlay:(EndBolck) end
{
    self.EndBlock = end;
}

#pragma mark - 返回按钮
- (void)backButtonAction:(UIButton *)button
{
    self.BackBlock(button);
}
- (void)backButton:(BackButtonBlock) backButton;
{
    self.BackBlock = backButton;
}

#pragma mark - 暂停播放
- (void)pausePlay
{
    [_player pause];
    [_startButton setBackgroundImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    
}
#pragma mark - 播放
- (void)playVideo
{
    [_player play];
    [_startButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}



@end
