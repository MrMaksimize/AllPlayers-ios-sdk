//
//  APClient.h
//  AllPlayers
//
//  Created by Maksim Pecherskiy on 10/31/12.
//  Copyright (c) 2012 AllPlayers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFIncrementalStore.h"
#import "AFRESTClient.h"
#import "APSettings.h"

/**
 `AFRESTClient` is a subclass of `AFHTTPClient` that implements the `AFIncrementalStoreHTTPClient` protocol in a way that follows the conventions of a RESTful web service.
 */
@interface APClient : AFRESTClient <AFIncrementalStoreHTTPClient>  {
  // @todo NON-AFIS
  /*NSDictionary *user;
  NSMutableDictionary *accessTokens;
  NSString *consumerKey;
  NSString *consumerSecret;
  NSString *tokenIdentifier;
  NSString *tokenSecret;*/
}

// @todo NON-AFIS
@property (strong, nonatomic) NSDictionary *user;
@property (nonatomic, retain) NSMutableDictionary *accessTokens;
@property (nonatomic) BOOL signRequests;
@property (nonatomic) BOOL threeLegged;
@property (nonatomic, copy) NSString *realm;
@property (nonatomic, retain) NSString *consumerKey;
@property (nonatomic, retain) NSString *consumerSecret;
@property (nonatomic, retain) NSString *tokenIdentifier;
@property (nonatomic, retain) NSString *tokenSecret;

#pragma mark - Singleton Initializers

+ (APClient *)sharedClient;
+ (APClient *)sharedClientWithURL:(NSString*)url;
+ (APClient *)sharedOauthClientWithURL:(NSString*)url consumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret;

#pragma mark - Initializers

- (id) initWithBaseURL:(NSURL *)url consumerKey:(NSString *)consumerKey secret:(NSString *)consumerSecret;

#pragma mark - OAuth
+ (void) getRequestTokensWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) getAccessTokensWithRequestTokens:(NSDictionary *)requestTokens
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

- (void) sendSignedRequestWithPath:(NSString*)path
                            method:(NSString*)method
                            params:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;


- (NSURLRequest *) signedRequestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;



#pragma mark - Setters and Getters

- (void) addHeaderValue:(NSString*)value forKey:(NSString*)key;

- (void) setAccessToken:(NSString *)accessToken secret:(NSString *)secret;

- (void) setConsumerKey:(NSString *)consumerKey secret:(NSString *)secret;

#pragma mark - AFRESTClient Implementation

/**
 Returns the request path for a collection of resources of the specified entity. By default, this returns an imprecise pluralization of the entity name.
 
 @discussion The return value of this method is used as the `path` parameter in other `AFHTTPClient` methods.
 
 @param entity The entity used to determine the resources path.
 
 @return An `NSString` representing the request path.
 */
- (NSString *)pathForEntity:(NSEntityDescription *)entity;

/**
 Returns the request path for the resource of a particular managed object. By default, this returns an imprecise pluralization of the entity name, with the additional path component of the resource identifier corresponding to the managed object.
 
 @discussion The return value of this method is used as the `path` parameter in other `AFHTTPClient` methods.
 
 @param object The managed object used to determine the resource path.
 
 @return An `NSString` representing the request path.
 */
- (NSString *)pathForObject:(NSManagedObject *)object;

/**
 Returns the request path for the resource of a particular managed object. By default, this returns an imprecise pluralization of the entity name, with the additional path component of either an imprecise pluralization of the relationship destination entity name if the relationship is to-many, or the relationship destination entity name if to-one.
 
 @discussion The return value of this method is used as the `path` parameter in other `AFHTTPClient` methods.
 
 @param relationship The relationship used to determine the resource path
 @param object The managed object used to determine the resource path.
 
 @return An `NSString` representing the request path.
 */
- (NSString *)pathForRelationship:(NSRelationshipDescription *)relationship
                        forObject:(NSManagedObject *)object;

@end
