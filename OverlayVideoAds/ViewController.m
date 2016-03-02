//
//  ViewController.m
//  OverlayVideoAds
//
//  Created by Nikunj Modi on 3/1/16.
//  Copyright © 2016 Niks. All rights reserved.
//

#import "ViewController.h"
#import "NKDirectVideo.h"
NSString *const kDirectVideo = @"http://www.jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v";
@interface ViewController (){
    MPMoviePlayerController *moviePlayerNew;
}
@property (nonatomic, strong) NSTimer *durationTimer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NKDirectVideo *directVideo = [[NKDirectVideo alloc] initWithContent:[NSURL URLWithString:kDirectVideo]];
    directVideo.currentVC = self;
    [directVideo play:NKQualityHigh];
}
-(void)doneButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    // Obtain the reason why the movie playback finished
    MPMoviePlayerController *moviePlayer = [aNotification object];
    if (moviePlayer.duration == moviePlayer.currentPlaybackTime) {
        NSLog(@"Done");
        
    }
    else{
        
    }
    // Remove this class from the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
    // Dismiss the view controller
    moviePlayerNew = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)moviePlaybackStateDidChange:(NSNotification *)note {
    // Obtain the reason why the movie playback finished
    //MPMoviePlayerController *moviePlayer = [note object];
    moviePlayerNew = [note object];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[moviePlayerNew.view viewWithTag:365365];
    UIButton *playPauseButton = (UIButton *)[moviePlayerNew.view viewWithTag:365366];
    switch (moviePlayerNew.playbackState) {
        case MPMoviePlaybackStatePlaying:
        {
            playPauseButton.selected = NO;
            [self setDurationSliderMaxMinValues];
            [self startDurationTimer];
            //NSLog(@"MPMoviePlaybackStatePlaying");
        }
        case MPMoviePlaybackStateSeekingBackward:
        {
            //NSLog(@"MPMoviePlaybackStateSeekingBackward");
        }
        case MPMoviePlaybackStateSeekingForward:
        {
            //NSLog(@"MPMoviePlaybackStateSeekingForward");
            [activityIndicator stopAnimating];
        }
            break;
        case MPMoviePlaybackStateInterrupted:
        {
            [activityIndicator startAnimating];
            //NSLog(@"MPMoviePlaybackStateInterrupted");
        }
            break;
        case MPMoviePlaybackStatePaused:
        {
            //NSLog(@"MPMoviePlaybackStatePaused");
        }
        case MPMoviePlaybackStateStopped:
        {
            [activityIndicator startAnimating];
            playPauseButton.selected = YES;
            [self stopDurationTimer];
            //NSLog(@"MPMoviePlaybackStateStopped");
        }
            break;
        default:
            break;
    }
}
- (void)movieDurationAvailable:(NSNotification *)note {
    [self setDurationSliderMaxMinValues];
 }
 - (void)playPausePressed {
     moviePlayerNew.playbackState == MPMoviePlaybackStatePlaying ? [moviePlayerNew pause] : [moviePlayerNew play];
 }
 - (void)startDurationTimer {
     self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitorMoviePlayback) userInfo:nil repeats:YES];
     [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
 }
 - (void)stopDurationTimer {
     [self.durationTimer invalidate];
 }
 - (void)monitorMoviePlayback {
     double currentTime = floor(moviePlayerNew.currentPlaybackTime);
     double totalTime = floor(moviePlayerNew.duration);
     [self setTimeLabelValues:currentTime totalTime:totalTime];
     UISlider *durationSlider = (UISlider *)[moviePlayerNew.view viewWithTag:365369];
     durationSlider.value = ceil(currentTime);
 }
 - (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
     double minutesElapsed = floor(currentTime / 60.0);
     double secondsElapsed = fmod(currentTime, 60.0);
     UILabel *timeElapsedLabel = (UILabel *)[moviePlayerNew.view viewWithTag:365367];
     UILabel *timeRemainingLabel = (UILabel *)[moviePlayerNew.view viewWithTag:365368];
     timeElapsedLabel.text = [NSString stringWithFormat:@"%.0f:%02.0f", minutesElapsed, secondsElapsed];
 
     double minutesRemaining;
     double secondsRemaining;

     minutesRemaining = floor((totalTime - currentTime) / 60.0);
     secondsRemaining = fmod((totalTime - currentTime), 60.0);
 
     timeRemainingLabel.text = [NSString stringWithFormat:@"-%.0f:%02.0f", minutesRemaining, secondsRemaining];
 }
 - (void)durationSliderValueChanged:(UISlider *)slider {
     double currentTime = floor(slider.value);
     double totalTime = floor(moviePlayerNew.duration);
     [self setTimeLabelValues:currentTime totalTime:totalTime];
 }
 - (void)setDurationSliderMaxMinValues {
     CGFloat duration = moviePlayerNew.duration;
     UISlider *durationSlider = (UISlider *)[moviePlayerNew.view viewWithTag:365369];
     durationSlider.minimumValue = 0.f;
     durationSlider.maximumValue = duration;
 }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
