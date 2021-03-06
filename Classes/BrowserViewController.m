//
//    BrowserViewController.m
//    LatestChatty2
//
//    Created by Alex Wayne on 3/26/09.
//    Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"
#import "LatestChatty2AppDelegate.h"

#import "GoogleChromeActivity.h"
#import "AppleSafariActivity.h"

@implementation BrowserViewController

@synthesize request;
@synthesize webView, backButton, forwardButton, spinner, mainToolbar, actionButton, bottomToolbar, isShackLOL;

- (id)initWithRequest:(NSURLRequest*)_request {
    self = [super initWithNib];
    self.request = _request;
    self.title = @"Browser";
    return self;
}

//Patch-E: new constructor to support Shack[LOL]-tergration. Overrides the title and if the web view is to point to the Shack[LOL] site, a menu button is created that fires the lolMenu selector.
- (id)initWithRequest:(NSURLRequest*)_request title:(NSString*)title isForShackLOL:(BOOL)isForShackLOL {
    self = [super initWithNib];
    self.request = _request;
    self.title = title;
    self.isShackLOL = isForShackLOL;
 
    if (self.isShackLOL) {
        UIBarButtonItem *lolMenuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(lolMenu)];
        [lolMenuButton setEnabled:NO];
        
        if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
            [self.navigationItem setLeftBarButtonItem:lolMenuButton];
        } else {
            [self.navigationItem setRightBarButtonItem:lolMenuButton];
        }
        
        [lolMenuButton release];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
        self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    }
    
    if (mainToolbar) {
        UIBarButtonItem *spinnerItem = [[[UIBarButtonItem alloc] initWithCustomView:spinner] autorelease];
        NSMutableArray *items = [NSMutableArray arrayWithArray:mainToolbar.items];
        [items insertObject:spinnerItem atIndex:[items count]-1];
        
        //remove action button when using this controller for Shack[LOL]
        if (isShackLOL) {
            for(int i = 0; i < mainToolbar.items.count; i++) {
                UIBarButtonItem *item = (UIBarButtonItem *)[items objectAtIndex:i];
                if([item isEqual:actionButton]) {
                    [items removeObjectAtIndex:i];
                }
            }
        }
        mainToolbar.items = items;
    }

    //remove action button when using this controller for Shack[LOL]
    if (bottomToolbar && isShackLOL) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:bottomToolbar.items];
        for(int i = 0; i < bottomToolbar.items.count; i++) {
            UIBarButtonItem *item = (UIBarButtonItem *)[items objectAtIndex:i];
            if([item isEqual:actionButton]) {
                 [items removeObjectAtIndex:i];
            }
        }
        bottomToolbar.items = items;
    }
    
    [webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([[LatestChatty2AppDelegate delegate] isPadDevice] && self.navigationController) {
        mainToolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationItem.titleView = self.mainToolbar;
        webView.frame = self.view.bounds;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    [spinner stopAnimating];
    backButton.enabled = webView.canGoBack;
    forwardButton.enabled = webView.canGoForward;

    if (self.navigationItem.leftBarButtonItem != nil) {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }

    if (self.navigationItem.rightBarButtonItem != nil) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
    [self.actionButton setEnabled:YES];
}

- (void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFinishLoad:webView];
}

- (IBAction)safari {
    [[UIApplication sharedApplication] openURL:[webView.request URL]];
}

//Patch-E: displays the custom iPhone menu on the Shack[LOL] site. Menu button is disabled until the web view finishes loading.
- (void)lolMenu {
    //switching to a javascript function called on the page rather than a page transfer
    //[self.webView loadURLString:@"http://lol.lmnopc.com/iphonemenu.php"];
    [self.webView stringByEvaluatingJavaScriptFromString: @"lc_menu();"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"landscape"]) return YES;
    return YES;
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc {
    NSLog(@"BrowserViewController dealloc");
    self.request = nil;
    [webView loadHTMLString:@"<div></div>" baseURL:nil];
    if (webView.loading) {
        [webView stopLoading];
    }
    webView.delegate = nil;

    self.webView = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.spinner = nil;
    self.mainToolbar = nil;
    self.actionButton = nil;
    [super dealloc];
}

- (IBAction)closeBrowser {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark UIActivityViewController & Action Sheet Delegate
- (IBAction)action:(id)sender {
    //use iOS 6 ActivityViewController functionality if available
    if ([UIActivityViewController class]) {
        //load custom activities
        AppleSafariActivity *safariActivity = [[[AppleSafariActivity alloc] init] autorelease];
        GoogleChromeActivity *chromeActivity = [[[GoogleChromeActivity alloc] init] autorelease];
        
        NSArray *activityItems = @[[webView.request URL]];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                            initWithActivityItems:activityItems
                                                            applicationActivities:@[safariActivity, chromeActivity]];

        activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
        
        //present as popover on iPad, as a regular view on iPhone
        if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
            //hide popover if its already showing and the button is pressed again
            if ([popoverController isPopoverVisible]) {
                [popoverController dismissPopoverAnimated:YES];
            } else {
                popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        } else {
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
        
        [activityViewController release];
    }
    //fallback to ActionSheets for pre-iOS 6
    else {
        //check to see if action sheet is already showing (isn't nil), dismiss it if so
        if (theActionSheet) {
            [theActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
            theActionSheet = nil;
            return;
        }
        //keep track of the action sheet
        theActionSheet = [[[UIActionSheet alloc] initWithTitle:@"Options"
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil] autorelease];
        
        [theActionSheet addButtonWithTitle:@"Copy URL"];
        [theActionSheet addButtonWithTitle:@"Open in Safari"];
        
        //if Chome is available, add it to the action sheet
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
            [theActionSheet addButtonWithTitle:@"Open in Chrome"];
        }
        //set the cancel button to the last button
        [theActionSheet addButtonWithTitle:@"Cancel"];
        theActionSheet.cancelButtonIndex = theActionSheet.numberOfButtons-1;
        
        //present as popover of the sender button on iPad, modally on iPhone
        if ([[LatestChatty2AppDelegate delegate] isPadDevice]) {
            [theActionSheet showFromBarButtonItem:sender animated:YES];
        } else {
            [theActionSheet showInView:self.navigationController.view];
        }

    }
}

- (void)copyURL {
    [[UIPasteboard generalPasteboard] setString:[[webView.request URL] absoluteString]];
}

- (void)openInSafari {
    [[UIApplication sharedApplication] openURL:[webView.request URL]];
}

- (void)openInChrome {
    LatestChatty2AppDelegate *appDelegate = (LatestChatty2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *chromeURL = [appDelegate urlAsChromeScheme:[webView.request URL]];
    [[UIApplication sharedApplication] openURL:chromeURL];
    chromeURL = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    theActionSheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    switch (buttonIndex) {
        case 0: [self copyURL]; break;
        case 1: [self openInSafari]; break;
        case 2: [self openInChrome]; break;
        default: break;
    }
}

@end
