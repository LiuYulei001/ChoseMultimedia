//
//  ViewController.m
//  UploadVideo
//
//  Created by Rainy on 2018/3/21.
//  Copyright © 2018年 WealthOnline_iOS_team. All rights reserved.
//

#import "ViewController.h"

#import "UploadVideoTool.h"

@interface ViewController ()

@property(nonatomic,strong)UploadVideoTool *actionTool;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
}
- (IBAction)choseVideo:(id)sender {
    
    [self.actionTool chooseMultimediaWihtType:MultimediaTypeForVideo chooseVideoDone:^(NSString *videoPath) {
        
        /*
         
         录制或者选择后，通过网络上传工具根据视频路径进行上传。
         
         */
        NSLog(@"videoPath = %@",videoPath);
        
        
    } chooseImageDone:nil];
}
- (IBAction)choseImage:(id)sender {
    
    [self.actionTool chooseMultimediaWihtType:MultimediaTypeForImage chooseVideoDone:nil chooseImageDone:^(UIImage *image) {
        
        /*
         
         拍摄或者选择后，通过网络上传工具将图片进行上传。
         
         */
        NSLog(@"image = %@",image);
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UploadVideoTool *)actionTool
{
    if (!_actionTool) {
        _actionTool = [[UploadVideoTool alloc]init];
    }
    return _actionTool;
}

@end
