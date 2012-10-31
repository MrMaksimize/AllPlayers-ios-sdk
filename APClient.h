//
//  APClient.h
//  AllPlayers
//
//  Created by Maksim Pecherskiy on 10/31/12.
//  Copyright (c) 2012 AllPlayers. All rights reserved.
//

#import "AFIncrementalStore.h"
#import "AFRESTClient.h"

/**
 `AFRESTClient` is a subclass of `AFHTTPClient` that implements the `AFIncrementalStoreHTTPClient` protocol in a way that follows the conventions of a RESTful web service.
 */
@interface APClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (APClient *)sharedClient;

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
