//
//  AppDelegate.h
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import "PreferencesWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet PreferencesWindow *prefsWindow;
@property HTTPServer *Server;

-(IBAction)showPrefsWindow:(id)sender;

@end