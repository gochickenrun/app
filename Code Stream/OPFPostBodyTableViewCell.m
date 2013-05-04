//
//  OPFPostBodyTableViewCell.m
//  Code Stream
//
//  Created by Aron Cedercrantz on 18-04-2013.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFPostBodyTableViewCell.h"
#import "NSString+OPFEscapeStrings.h"

@implementation OPFPostBodyTableViewCell
@synthesize htmlString = _htmlString;

- (void)setHtmlString:(NSString *)htmlString {
	_htmlString = htmlString;
	
	if (!self.bodyTextView.loading)
		[self reloadHTMLWithString:htmlString];
}



- (void)reloadHTMLWithString:(NSString *)content {
	NSString *command = [NSString stringWithFormat:@"loadBody(\"%@\")", [content OPF_escapeWithScheme:OPFEscapePrettify]];
	[self.bodyTextView stringByEvaluatingJavaScriptFromString:command];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// Insert html from database and run prettify
	[self reloadHTMLWithString:_htmlString];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"%@",error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if(navigationType==UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	} else return YES;
}

- (void)awakeFromNib {
	self.bodyTextView.keyboardDisplayRequiresUserAction = NO;
	self.bodyTextView.mediaPlaybackAllowsAirPlay = NO;
	self.bodyTextView.mediaPlaybackRequiresUserAction = NO;
	self.bodyTextView.dataDetectorTypes = UIDataDetectorTypeNone;
	self.bodyTextView.delegate = self;
	self.bodyTextView.scrollView.scrollEnabled = NO;
	self.bodyTextView.scrollView.bounces = NO;
	
	NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"bodytemplate" ofType:@"html"];
	NSURL *bundle = [[NSBundle mainBundle] bundleURL];

	if (htmlPath && bundle) {
        NSData *htmlData = [NSData dataWithContentsOfFile:htmlPath];
        [self.bodyTextView loadData:htmlData MIMEType:@"text/html"
						textEncodingName:@"utf-8" baseURL:bundle];
    }
	
}

@end
