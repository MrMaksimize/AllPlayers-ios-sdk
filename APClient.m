//
//  APClient.m
//  AllPlayers
//
//  Created by Maksim Pecherskiy on 10/31/12.
//  Copyright (c) 2012 AllPlayers. All rights reserved.
//

#import "APClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAllPlayersAPIBaseURLString = @"https://www.allplayers.com/api/v1/rest/";

@implementation APClient

+ (APClient *)sharedClient {
  static APClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAllPlayersAPIBaseURLString]];
  });
  
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  
  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  [self setDefaultHeader:@"Accept" value:@"application/json"];
  [self setDefaultHeader:@"Content-Type" value:@"application/json"];
  
  return self;
}

#pragma mark - AFRESTClient Implementation

// Override paths for core data entities.
- (NSString *)pathForEntity:(NSEntityDescription *)entity {
  //return AFPluralizedString(entity.name);
  //NSString *pathForEntity = @"";
  NSLog(@"%@", [entity name]);
  NSLog(@"%@", entity.name);
  if ([entity.name isEqualToString:@"Person"]) {
    return @"users";
  }
  else {
    return [super pathForEntity:entity];
  }
}

// Override paths for specific objects.
- (NSString *)pathForObject:(NSManagedObject *)object {
  NSString *resourceIdentifier = [(NSIncrementalStore *)object.objectID.persistentStore referenceObjectForObjectID:object.objectID];
  return [[self pathForEntity:object.entity] stringByAppendingPathComponent:[resourceIdentifier lastPathComponent]];
}

// Override Paths for Relationships
- (NSString *)pathForRelationship:(NSRelationshipDescription *)relationship
                        forObject:(NSManagedObject *)object
{
  return [[self pathForObject:object] stringByAppendingPathComponent:relationship.name];
}


#pragma mark - AFIncrementalStoreHTTPClient - Protocol Implementation

#pragma mark Read Methods
// Note look in AFIncrementalStore AFIncrementalStoreHTTPClient protocol for more.

- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject {
  return responseObject;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
  NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
  
  // Customize the response object to fit the expected attribute keys and values
  
  return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
  return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
  return NO;
}

#pragma mark Write Methods

@end
