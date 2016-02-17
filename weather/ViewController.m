//
//  ViewController.m
//  weather
//
//  Created by 杨 on 16/2/16.
//  Copyright © 2016年 杨. All rights reserved.
//

#import "ViewController.h"

#import "APIStoreSDK.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"4be8614e1531073557e3a1293ea28bad" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   
                                   NSArray *dic1 = dic[@"HeWeather data service 3.0"];
                                   NSDictionary *dic2 = dic1[0];
                                   NSDictionary *dic3 = dic2[@"basic"];
                                   NSLog(@"");
                                   
                               }
                           }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *httpUrl = @"http://apis.baidu.com/heweather/weather/free";
    NSString *httpArg = @"city=hangzhou";
    [self request: httpUrl withHttpArg: httpArg];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
