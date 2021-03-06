//
//  OSUtilityHelper.m
//  OSNewFrame
//
//  Created by Macx on 2017/11/29.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "OSUtilityHelper.h"

#import "GTMBase64.h"

#import <CommonCrypto/CommonCryptor.h>

#import <MapKit/MapKit.h>

@implementation OSUtilityHelper

/** 是否登录,return NO 就跳转到登录页面 */
+ (BOOL) isLogin:(UIViewController *) vc
{
    if ([OSUserInfoManage shareInstance].is_login == NO)
    {
        UIViewController * sb = [[UIStoryboard storyboardWithName:@"OSLoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OSLogin"];
        [vc.navigationController showViewController:sb sender:self];
        return NO;
    }
    return YES;
}

/** 自适应Size **/
+  (CGSize) fitSizeWithLabel:(NSString *)currentString size:(CGSize)size font:(UIFont*)font
{
    CGSize finalSize = [currentString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return finalSize;
}

/**
 DES加密
 */
+ (NSString *) encryptParmar:(NSString *)paramer
{
    return [OSUtilityHelper encryptUseDES2:paramer key:DESKEY];
}

/*
 加密方法
 iv和后台协商
 */
const  Byte iv[] = {1,2,3,4,5,6,7,8};
+ (NSString *) encryptUseDES2:(NSString *)plainText key:(NSString *)key
{
    NSString *ciphertext = nil;
    NSData *textData =  [plainText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSUInteger dataLength = [textData length];
    //    unsigned char buffer[1024];
    
    size_t bufferSize = ([textData length] + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    unsigned char buffer[bufferSize];
    
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [textData bytes], dataLength,
                                          buffer, bufferSize,//1024
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        //ciphertext = [Base64 encode:data];
        ciphertext = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    }
    return ciphertext;
}

/**
 DES解密
 */
+ (NSString *)decryptUseDES2:(NSString *)cipherText key:(NSString *)key
{
    NSString *plaintext = nil;
    NSData *cipherdata = [GTMBase64 decodeString:cipherText];//[Base64 decode:cipherText];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String], kCCKeySizeDES,
                                          nil,//iv
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, 1024,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
    }
    return plaintext;
}

/**
 获取本地数据
 */
+ (NSDictionary *) localDataResourceWithName:(NSString *)name
{
    //@"Directions"
    NSString *strPath = [[NSBundle mainBundle] pathForResource:name ofType:@"geojson"];
    NSString *parseJason = [[NSString alloc] initWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [parseJason dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    return dic;//parseJason.mj_keyValues;
}

/**
 地图导航
 */
+ (void )loadGPSWithLat:(NSString *)latitude log:(NSString *)longitude
{
    //百度地图
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"baidumap://map/"]])
    {
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",[latitude floatValue],[longitude floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    //高德地图
    else if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",AppName,@"iosamap",[latitude floatValue],[longitude floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    //谷歌地图
    else if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",AppName,@"comgooglemaps",[latitude floatValue],[longitude floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    //苹果地图
    else
    {
        //终点坐标
        CLLocationCoordinate2D coords1 = CLLocationCoordinate2DMake([latitude floatValue],[longitude floatValue]);
        //当前位置
        MKMapItem * currentLocation = [MKMapItem mapItemForCurrentLocation];
        //目的地的位置
        MKMapItem * toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coords1 addressDictionary:nil]];
        toLocation.name = @"目的地";
        
        //        NSString *myname=[dataSource objectForKey:@"name"];
        //
        //        if (![XtomFunction xfunc_check_strEmpty:myname])
        //
        //        {
        //            toLocation.name =myname;
        //        }
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}

/***
 扫一扫
 **/
+(void)scanRQCode:(UIViewController<SGScanningQRCodeVCDelegate>*)vc
{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        SGScanningQRCodeVC * scan = [[SGScanningQRCodeVC alloc] init];
        scan.delegate = vc;
        [vc.navigationController pushViewController:scan animated:YES];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"未检测到您的摄像头, 请在真机上测试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [av show];
    }
}

@end
