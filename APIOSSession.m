//
// APIOSSession.m
//
// APCI
//
// Created by Maksim Pecherskiy on 05/26/2012.
// Copyright 2011 AllPlayers.com. All rights reserved.
//
// This work was heavily influenced by Drupal IOS SDK, by Kyle Browning of WorkHabit.
// https://github.com/workhabitinc/drupal-ios-sdk
//
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// Contributor(s):
//
// Alternatively, the contents of this file may be used under the terms of
// the GNU General Public License Version 2 or later (the "GPL"), in which
// case the provisions of the GPL are applicable instead of those above. If
// you wish to allow use of your version of this file only under the terms of
// the GPL and not to allow others to use your version of this file under the
// MPL, indicate your decision by deleting the provisions above and replacing
// them with the notice and other provisions required by the GPL. If you do
// not delete the provisions above, a recipient may use your version of this
// file under either the MPL or the GPL.
//
// ***** END LICENSE BLOCK *****

#import "APIOSSession.h"
#import "AFJSONRequestOperation.h"
#import "AFPropertyListRequestOperation.h"

@implementation APIOSSession
@synthesize user;
+ (APIOSSession *)sharedSession {
  static dispatch_once_t once;
  static APIOSSession *sharedSession;
  dispatch_once(&once, ^ { 
    sharedSession = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIOSBaseUrl]];
    [sharedSession setParameterEncoding:AFJSONParameterEncoding];
  });
  return sharedSession;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  
  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
  [self setDefaultHeader:@"Content-Type" value:@"application/json"];
	
  return self;
}
@end
