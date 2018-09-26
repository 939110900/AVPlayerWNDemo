//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by MOKA_MBP on 2018/8/29.
//  Copyright © 2018年 weining. All rights reserved.
//

#import "ViewController.h"
#import<AVFoundation/AVFoundation.h>
#import<MediaPlayer/MediaPlayer.h>


typedef NS_ENUM(NSInteger, PanDirection){
    
    PanDirectionHorizontalMoved, // 横向移动
    
    PanDirectionVerticalMoved    // 纵向移动
    
};

@interface ViewController ()

@property (strong, nonatomic)AVPlayer *myPlayer;//播放器
@property (strong, nonatomic)AVPlayerItem *item;//播放单元
@property (strong, nonatomic)AVPlayerLayer *playerLayer;//播放界面（layer）
@property (strong, nonatomic)UIView *videoView;//播放器
@property (strong, nonatomic)UISlider *avSlider;//用来现实视频的播放进度，并且通过它来控制视频的快进快退。
@property (assign, nonatomic)BOOL isReadToPlay;//用来判断当前视频是否准备好播放。

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 100)];
    [self.view addSubview:_videoView];
    _videoView.backgroundColor = [UIColor blueColor];
    NSURL *mediaURL = [NSURL URLWithString:@"http://flv3.bn.netease.com/tvmrepo/2018/6/H/9/EDJTRBEH9/SD/EDJTRBEH9-mobile.mp4"];
    self.item = [AVPlayerItem playerItemWithURL:mediaURL];
    self.myPlayer = [[AVPlayer alloc] init];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = _videoView.bounds;
    [self.videoView.layer addSublayer:self.playerLayer];
    [self.avSlider addTarget:self action:@selector(avSliderAction) forControlEvents:
     UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
    if([[UIDevice currentDevice] systemVersion].intValue >= 10){
        //      增加下面这行可以解决iOS10兼容性问题了
        self.myPlayer.automaticallyWaitsToMinimizeStalling = NO;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 200, 100, 100);
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"按钮" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(100, 300, 100, 100);
    button1.backgroundColor = [UIColor blueColor];
    [button1 setTitle:@"暂停" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(pasueAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
//    [self.myPlayer play];
    //通过KVO来观察status属性的变化，来获得播放之前的错误信息
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)playAction{
    if ( self.isReadToPlay) {
        [self.myPlayer play];
    }else{
        NSLog(@"视频正在加载中");
    }
}

- (void)pasueAction{
    [self.myPlayer pause];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item 有误");
                self.isReadToPlay = NO;
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"准好播放了");
                self.isReadToPlay = YES;
                self.avSlider.maximumValue = self.item.duration.value / self.item.duration.timescale;
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
    //移除监听（观察者）
    [object removeObserver:self forKeyPath:@"status"];
}

- (void)avSliderAction{
    //slider的value值为视频的时间
    float seconds = self.avSlider.value;
    //让视频从指定的CMTime对象处播放。
    CMTime startTime = CMTimeMakeWithSeconds(seconds, self.item.currentTime.timescale);
    //让视频从指定处播放
    [self.myPlayer seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            [self playAction];
        }
    }];
}

- (UISlider *)avSlider{
    if (!_avSlider) {
        _avSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 400, self.view.bounds.size.width, 30)];
        [self.view addSubview:_avSlider];
    }return _avSlider;
}


@end
