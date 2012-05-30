//
// APIOSUser.m
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


#import "APIOSUser.h"
#import "APIOSSession.h"
@implementation APIOSUser


#pragma mark UserGets
- (void)userGet:(NSDictionary *)user  
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[APIOSSession sharedSession] getPath:[NSString stringWithFormat:@"%@/%@/%@", kAPIOSEndpoint, kAPIOSBaseUser, [user objectForKey:@"uid"]] 
                            parameters:nil 
                               success:success 
                               failure:failure];
}


#pragma mark userSaves
- (void)userSave:(NSDictionary *)user  
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[APIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@", kAPIOSEndpoint, kAPIOSBaseUser] 
                             parameters:user 
                                success:success 
                                failure:failure];
}

#pragma mark userRegister
- (void)userRegister:(NSDictionary *)user  
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[APIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@/register", kAPIOSEndpoint, kAPIOSBaseUser] 
                             parameters:user 
                                success:success 
                                failure:failure];
}

#pragma mark userUpdate
- (void)userUpdate:(NSDictionary *)user  
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[APIOSSession sharedSession] putPath:[NSString stringWithFormat:@"%@/%@/%@", kAPIOSEndpoint, kAPIOSBaseUser, [user objectForKey:@"uid"]] 
                            parameters:user 
                               success:success 
                               failure:failure];
}

#pragma mark UserDelete
- (void)userDelete:(NSDictionary *)user  
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[APIOSSession sharedSession] deletePath:[NSString stringWithFormat:@"%@/%@/%@", kAPIOSEndpoint, kAPIOSBaseUser, [user objectForKey:@"uid"]] 
                               parameters:user 
                                  success:success
                                  failure:failure];
}


#pragma mark userIndex
//Simpler method if you didnt want to build the params :)
- (void)userIndexWithPage:(NSString *)page 
                   fields:(NSString *)fields 
               parameters:(NSArray *)parameteres 
                 pageSize:(NSString *)pageSize  
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure; {
  NSMutableDictionary *userIndexDict = [NSMutableDictionary new];
  [userIndexDict setValue:page forKey:@"page"];
  [userIndexDict setValue:fields forKey:@"fields"];
  [userIndexDict setValue:parameteres forKey:@"parameters"];
  [userIndexDict setValue:pageSize forKey:@"pagesize"];  
  [self userIndex:userIndexDict success:success failure:failure];
}

- (void)userIndex:(NSDictionary *)params  
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  [[APIOSSession sharedSession] getPath:[NSString stringWithFormat:@"%@/%@", kAPIOSEndpoint, kAPIOSBaseUser] 
                            parameters:params 
                               success:success 
                               failure:failure];
}

#pragma mark userLogin
- (void)userLoginWithEmailAddress:(NSString *)emailAddress andPassword:(NSString *)password  
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:emailAddress, password, nil] forKeys:[NSArray arrayWithObjects:@"emailaddress", @"password", nil]];
  [[APIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@/login", kAPIOSEndpoint, kAPIOSBaseUser] 
                             parameters:params 
                                success:success 
                                failure:failure];
}
- (void)userLogin:(NSDictionary *)user  
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  [self userLoginWithEmailAddress:[user objectForKey:@"emailaddress"] andPassword:[user objectForKey:@"password"] success:success failure:failure];
}

#pragma mark userLogout
- (void)userLogoutWithSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  [[APIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@/logout", kAPIOSEndpoint, kAPIOSBaseUser] 
                             parameters:nil 
                                success:success 
                                failure:failure];
}
@end