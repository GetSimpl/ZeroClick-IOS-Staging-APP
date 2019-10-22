//
//  GSWebHandler.m
//  GetSimpl
//
//  Created by Alok Jha on 08/11/16.
//  Copyright © 2016 Simpl. All rights reserved.
//

#import "GSWebViewHandler.h"
#import "GSConstants.h"
#import "Extensions.h"
#import "GSGuard.h"
#import <WebKit/WebKit.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static NSString *kMessageHandlerName = @"Simpl" ;

static NSString *iOSVersionNumber = @"8.0";

@interface GSWebViewHandler ()<UIWebViewDelegate ,WKScriptMessageHandler, WKNavigationDelegate>
{
    UIActivityIndicatorView *actView;
    UIImageView *logoImageView;
}

@property (nonatomic) UIView* _Nonnull webView;
@end


@implementation GSWebViewHandler

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super init];
    
    if (self) {

        if (NSClassFromString(@"WKWebView")) {
            
            WKUserContentController *userContentController = [[WKUserContentController alloc] init];
            [userContentController addScriptMessageHandler:self name:kMessageHandlerName];
            
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
            configuration.userContentController = userContentController;
            
            _webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
            _webView.backgroundColor = [UIColor whiteColor];
            
            WKWebView *web = (WKWebView *)_webView ;
            web.navigationDelegate = self ;

        } else {
            _webView = [[UIWebView alloc] initWithFrame: frame];
            _webView.backgroundColor  = [UIColor whiteColor];
            
            UIWebView *web = (UIWebView *)_webView;
            web.delegate = self;
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow ;
        [window addSubview:[self webView]];
        
    }
    return self;
}

-(BOOL)iOS8 {
    
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOSVersionNumber) ;
}

-(void)showWithCallback:(void(^)(NSError *error)) callback {
    [self addLoader];
    [self showWebView:callback];
}

-(void)loadRequest:(NSURLRequest *)request {
    if (NSClassFromString(@"WKWebView")) {
        
        if([[self webView] isKindOfClass:[WKWebView class]] ) {
            WKWebView *webView = (WKWebView *)[self webView];
            [webView loadRequest:request];
        }
        
    }
    else if([[self webView] isKindOfClass:[UIWebView class]] ) {
        UIWebView *webView = (UIWebView *)[self webView];
        [webView loadRequest:request];
    }
}

-(void)showWebView:(void(^)(NSError *error)) callback {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow ;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self webView].frame = window.bounds;
    } completion:^(BOOL finished) {
        if(finished && callback) {
            [GSGuard guardWithCallback:^{
                callback(nil);
            } errorCallback:^(NSError *error) {
                callback(error);
                [self dismissWebView];
            }];
        }
    }];
}

-(void) dismissWebView {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGSize size = [self webView].bounds.size;
        [self webView].frame = CGRectMake(0, size.height, size.width, size.height);
        
    } completion:^(BOOL finished) {
        [[self webView] removeFromSuperview];
    }];
    
}

-(void)addLoader {
#ifdef SimplZeroClick
    UIImage *image = [UIImage imageNamed:@"simpl-logo" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    logoImageView = [[UIImageView alloc] initWithImage:image];
    logoImageView.frame = CGRectMake(0,0,92,92);
    [[self webView] addSubview:logoImageView];
    UIWindow *window = [UIApplication sharedApplication].keyWindow ;
    logoImageView.center = window.center;
    
    [UIView animateKeyframesWithDuration:.6 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationCurveEaseInOut animations:^{
        [logoImageView setAlpha:0.2f];
    } completion:^(BOOL finished) {
    }];
#else
    actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actView.frame = CGRectMake(0, 0, 40, 40);
    [actView startAnimating];
    [[self webView] addSubview:actView];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow ;
    
    actView.center = window.center;
#endif
    
}

-(void)dismissLoader {
#ifdef SimplZeroClick
    if(logoImageView) {
        [logoImageView removeFromSuperview];
        logoImageView = nil;
    }
#else
    if (actView) {
        [actView stopAnimating];
        [actView removeFromSuperview];
        actView = nil;
    }
#endif
}

-(void)parseWebViewResponse:(NSDictionary *)webResponse {
    NSError *error = nil;
    NSMutableDictionary *jsonResponse = nil;
    
    if ([webResponse isKindOfClass:[NSDictionary class]]) {
        
        if (webResponse[@"status"] != nil) {
            
            NSString *status = webResponse[@"status"];
            
            if ([status caseInsensitiveCompare:@"Success"] == NSOrderedSame) {
                jsonResponse = [webResponse mutableCopy];
            }
            else {
                
                if (webResponse[@"errors"] && [webResponse[@"errors"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *errors = webResponse[@"errors"] ;
                    NSString *message = errors[0];
                    
                     error =  [NSError errorFromErrorCode :GS_ERROR_CODE_OTHER domain : nil message:message];
                }
                else {
                    
                    error =  [NSError errorFromErrorCode :GS_ERROR_CODE_VERIFICATION_FAILED domain : nil message: webResponse[@"message"]];
                }
                
            }
        }
        else {
            error =  [NSError errorFromErrorCode :GS_ERROR_CODE_UNRESOLVED_RESPONSE domain : nil message: nil];
        }
    }
    else {
        error =  [NSError errorFromErrorCode :GS_ERROR_CODE_UNRESOLVED_RESPONSE domain : nil message: nil];
    }
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] save];
    [self dismissWebViewAndPerformCallback:jsonResponse error:error];
}

- (void)dismissWebViewAndPerformCallback:(NSDictionary *) response error:(NSError *)error {
    [self dismissWebView];
    if ([self.delegate respondsToSelector:@selector(webHandler:didRecieveResponse:withError:) ]) {
        [self.delegate webHandler:self didRecieveResponse:response withError:error];
    }
}

#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSNumber * response = [GSGuard<NSNumber*> guardWithCallbackAndReturn:^NSNumber *{
        NSString *urlString =  request.URL.absoluteString;
        
        NSString *protocolPrefix  = @"js2ios://";
        
        if ([urlString hasPrefix:protocolPrefix] ) {
            
            urlString = [urlString substringFromIndex:protocolPrefix.length];
            
            urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError *error = nil;
            
            NSDictionary *urlInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            [self parseWebViewResponse:urlInfo];
            
            return @(NO);
        }
        
        return @(YES) ;
    } errorCallback:^NSNumber *(NSError * error) {
        [self dismissWebViewAndPerformCallback:nil error:error];
        return @(NO);
    }];
    return [response boolValue];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [GSGuard guard:^{
        [self dismissLoader];
    }];
}

#pragma mark - WKWebview methods

-(void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [GSGuard guardWithCallback:^{
        if ([message.name isEqualToString:kMessageHandlerName]) {
            [self parseWebViewResponse:message.body];
        }
    } errorCallback:^(NSError *error) {
        [self dismissWebViewAndPerformCallback:nil error:error];
    }];
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    [GSGuard guard:^{
        [self dismissLoader];
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [GSGuard guard:^{
        decisionHandler(WKNavigationActionPolicyAllow);
    }];
}



-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    [self dismissLoader];
    
    if ([self.delegate respondsToSelector:@selector(webHandler:didRecieveResponse:withError:) ]) {
        [self.delegate webHandler:self didRecieveResponse:nil withError:error];
    }
}

@end





