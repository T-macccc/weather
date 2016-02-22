//
//  ViewController.m
//  weather
//
//  Created by 杨 on 16/2/16.
//  Copyright © 2016年 杨. All rights reserved.
//

#import "ViewController.h"

#import "APIStoreSDK.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic,retain)CLLocationManager *locationManager;
@property (nonatomic,strong)CLGeocoder *geocoder;
@property (nonatomic,strong)NSString *city;
@end

@implementation ViewController
{
    CLLocation *currentLocation;
}

- (void)pingyin:(NSMutableString *)string{
    if (CFStringTransform((__bridge CFMutableStringRef)string, 0, kCFStringTransformMandarinLatin, NO)) {}
    if (CFStringTransform((__bridge CFMutableStringRef)string, 0, kCFStringTransformStripDiacritics, NO)){}
    
    NSString *resultStr = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.city = resultStr;
}

- (void)reverseGeocode:(CLLocation *)locations{
    
    if (currentLocation == nil) {
        NSLog(@"location is nil;");
    }
    else{
        NSLog(@"location is not nil" );
    }
    [self.geocoder reverseGeocodeLocation:locations completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error||placemarks.count == 0) {
            NSLog(@"error:%@",error.description);
        }
        else{
            for (CLPlacemark *placemark in placemarks) {
                NSMutableString *str = [[NSMutableString alloc]initWithString:placemark.locality];
                NSMutableString *city = [[NSMutableString alloc]initWithString:[str substringToIndex:(str.length-1)]];
                [self pingyin:city];
                
                [self sendAndGetWeather];
            }
        }
    }];
}

- (CLGeocoder *)geocoder{
    if (!_geocoder) {
        self.geocoder = [CLGeocoder new];
    }
    return _geocoder;
}

- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (error.code == kCLErrorDenied) {
        NSLog(@"failed error");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    currentLocation = [locations lastObject];
    [manager stopUpdatingLocation];
}

- (void)locate{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"recommand" message:@"failed" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [alertView show];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)clickButton{
    CLLocation *location = [[CLLocation alloc]initWithLatitude:currentLocation.coordinate.latitude longitude:(currentLocation.coordinate.longitude)];

    NSLog(@"%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    [self reverseGeocode:location];

}


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
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, (long)error.code);
                               } else {
                                   
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   
                                   [self dictionaryParse:dic];
                                   
                               }
                           }];
    
    
}

-(void)dictionaryParse:(NSDictionary *)dic{
    NSArray *dic1 = dic[@"HeWeather data service 3.0"];
    NSDictionary *dic2 = dic1[0];
    NSArray *hourForecastDic = dic2[@"hourly_forecast"];
    NSDictionary *nowForecastDic = dic2[@"now"];
    NSDictionary *aqiDic = dic2[@"aqi"];
    
    NSDictionary *hourWeatherDictionary = hourForecastDic[0];
    NSString *nowTem = hourWeatherDictionary[@"tmp"];//气温
    
    NSDictionary *aqiDictionary = aqiDic[@"city"];
    NSString *aqiNumber = aqiDictionary[@"aqi"];//空气指数
    NSString *aqiDes = aqiDictionary[@"qlty"];//空气描述
    
    NSDictionary *weather = nowForecastDic[@"cond"];
    NSString *weatherDes = weather[@"txt"];//天气
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    
    [self locate];
    [_locationManager requestAlwaysAuthorization];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 50);
    [button setTitle:@"click" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
}

- ( void)sendAndGetWeather{
    NSString *httpUrl = @"http://apis.baidu.com/heweather/weather/free";
    NSString *httpArg = [NSString stringWithFormat:@"city=%@",self.city];
    [self request: httpUrl withHttpArg: httpArg];
    NSLog(@"successful:%@",self.city);
}

@end
