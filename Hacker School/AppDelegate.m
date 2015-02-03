//
//  AppDelegate.m
//  Hacker School
//
//  Created by Alan Wang on 1/20/15.
//  Copyright (c) 2015 Alan Wang. All rights reserved.
//

#import "AppDelegate.h"
#import "AW_MainViewController.h"
#import "NXOAuth2.h"

#import "AW_BatchStore.h"
#import "AW_UserAccount.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    // --- Set up OAuth2 ---
    // The ClientID and secret are generated by the Hacker School website
    [[NXOAuth2AccountStore sharedStore] setClientID:@"6a0ef0f986f96b491ae88d9eed40d8b32b08525ac2b603ba931b368b0f881fbc"
                                             secret:@"25a6deb0dcf00a01c4e8e5f54de0635765fd53a89ca55975c76fc0fa9fdab749"
                                   authorizationURL:[NSURL URLWithString:@"https://www.hackerschool.com/oauth/authorize"]
                                           tokenURL:[NSURL URLWithString:@"https://www.hackerschool.com/oauth/token"]
                                        redirectURL:[NSURL URLWithString:@"HackerSchoolApp://oauth"]
                                     forAccountType:@"Hacker School"];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      // Update your UI
                                                      if (aNotification.userInfo) {
                                                          //account added, we have access
                                                          //we can now request protected data
                                                          NSLog(@"Success!! We have an access token.");
                                                      } else {
                                                          //account removed, we lost access
                                                      }
                                                      
                                                      NSLog(@"Accounts; %@", [[NXOAuth2AccountStore sharedStore] accounts]);
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      NSLog(@"Error: %@", error);
                                                  }];
    
    
    // ---- Set up root view controller ----
    AW_MainViewController *mainVC = [[AW_MainViewController alloc]init];
    self.window.rootViewController = mainVC;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Redirected from: %@", sourceApplication);
    NSLog(@"URL: %@", url);
    
    [[NXOAuth2AccountStore sharedStore]handleRedirectURL:url];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    BOOL success = [[AW_BatchStore sharedStore]saveChanges];
    
    if (success) {
        NSLog(@"Batches saved");
    }
    else {
        NSLog(@"Batch save failed");
    }
    
    success = [[AW_UserAccount currentUser]saveCurrentUserInfo];
    
    if (success) {
        NSLog(@"Current user's info saved");
    }
    else {
        NSLog(@"Current user's info save failed");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
