//
//  UploadVideoTool.m
//  UploadVideo
//
//  Created by Rainy on 2018/3/21.
//  Copyright © 2018年 WealthOnline_iOS_team. All rights reserved.
//

/**
 *  最大录制视频时间
 */
#define kVideoMaximumDuration                               10.0f
/**
 *  最大上传视频大小M
 */
#define kVideoMaximumMemory                                 30


#import "UploadVideoTool.h"
#import "UIApplication+CurrentViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface UploadVideoTool ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    ChoosVideoBlock _chooseVideoBlock;
    ChoosImageBlock _choosImageBlock;
}

@end

@implementation UploadVideoTool

- (void)chooseMultimediaWihtType:(MultimediaType)mediaType
                 chooseVideoDone:(ChoosVideoBlock)chooseVideoDone
                 chooseImageDone:(ChoosImageBlock)chooseImageDone
{
    _chooseVideoBlock = chooseVideoDone;
    _choosImageBlock = chooseImageDone;
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil message: nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self chooseVideoInPhoto:NO mediaType:mediaType];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self chooseVideoInPhoto:YES mediaType:mediaType];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [[[UIApplication sharedApplication] getCurrentViewController] presentViewController:alertController animated:YES completion:nil];
}
//选择视频
- (void)chooseVideoInPhoto:(BOOL)photo mediaType:(MultimediaType)mediaType
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    //sourcetype有三种分别是camera，photoLibrary和photoAlbum
    ipc.sourceType = photo ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
    //Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
    NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    //设置媒体类型为public.movie
    ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[mediaType]];
    [[[UIApplication sharedApplication] getCurrentViewController] presentViewController:ipc animated:YES completion:nil];
    //限制视频长度
    if (mediaType == MultimediaTypeForVideo) ipc.videoMaximumDuration = kVideoMaximumDuration;
    ipc.delegate = self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    if ([[picker.mediaTypes firstObject]isEqual:@"public.image"]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
        }
        _choosImageBlock(image);
        
    }else
    {
        NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:sourceURL]]);
        NSLog(@"%@", [NSString stringWithFormat:@"%.2f MB", [self getFileSize:[sourceURL path]]]);
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            UISaveVideoAtPathToSavedPhotosAlbum([sourceURL path], self, nil, NULL);
        }
        
        NSURL *newVideoUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingFormat:@"vidio-%@.mp4",[formater stringFromDate:[NSDate date]]]];
        [self convertVideoQuailtyWithInputURL:sourceURL outputURL:newVideoUrl completeHandler:nil];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f MB", [self getFileSize:[outputURL path]]]);
                 
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     
                     if ([self getFileSize:[outputURL path]] > kVideoMaximumMemory) {
                         
                         
                         UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"视频大小不能超过%dMB,请重新选择或拍摄",kVideoMaximumMemory] preferredStyle:UIAlertControllerStyleAlert];
                         
                         [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                             return;
                         }]];
                         
                         [[[UIApplication sharedApplication] getCurrentViewController] presentViewController:alertController animated:YES completion:nil];
                         
                         
                         
                     }else
                     {
                         _chooseVideoBlock([outputURL path]);
                     }
                 });
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
     }];
}
//获取文件的大小,单位KB。
- (CGFloat)getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = - 1.0;
    if ([fileManager fileExistsAtPath:path]) {
        
        //获取文件的属性
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0 * size / 1024 / 1024;
        
    }else{
        
        NSLog(@"文件不存在");
    }
    return filesize;
}
//获取视频文件的时长
- (CGFloat)getVideoLength:(NSURL *)URL
{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}



@end
