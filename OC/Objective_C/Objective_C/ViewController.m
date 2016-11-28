//
//  ViewController.m
//  Objective_C
//
//  Created by 王留根 on 16/10/27.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
#pragma mark - https实验
@property (nonatomic,strong) NSURLRequest * failedRequest;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 9){
        self.failedRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://sslapi.qjt1000.com/rest"]];
        NSURLRequest *request = self.failedRequest;
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [urlConnection start];
    }
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - https实验=======
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURL* baseURL = self.failedRequest.URL;
        if ([challenge.protectionSpace.host isEqualToString:baseURL.host]) {
            //NSLog(@"trusting connection to host %@", challenge.protectionSpace.host);
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response {
    [connection cancel];
    
}
#pragma mark - https实验========


@end
