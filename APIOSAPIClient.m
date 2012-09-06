// SongAPIClient.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "APIOSAPIClient.h"

static NSString * const kAPIOSAPIBaseURLString = @"https://www.allplayers.com/api/v1/rest/";

@implementation APIOSAPIClient


@synthesize user;
+ (APIOSAPIClient *)sharedClient {
    static APIOSAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIOSAPIBaseURLString]];
      [_sharedClient setParameterEncoding:AFJSONParameterEncoding];
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

// Override paths for core data entities.
- (NSString *)pathForEntity:(NSEntityDescription *)entity {
  //return AFPluralizedString(entity.name);
  //NSString *pathForEntity = @"";
  if (entity.name == @"Person") {
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

#pragma mark - AFIncrementalStore

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *mutableURLRequest = nil;
    if ([fetchRequest.entityName isEqualToString:@"Person"]) {
      mutableURLRequest = [self requestWithMethod:@"GET" path:@"users/42f0fc54-f611-11e0-a44b-12313d04fc0f.json" parameters:nil];
    }
    
    return mutableURLRequest;
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                pathForObjectWithID:(NSManagedObjectID *)objectID
                        withContext:(NSManagedObjectContext *)context
{
  NSLog(@"RequestWithMethod PathForObjectWithID WithContext");
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                pathForRelationship:(NSRelationshipDescription *)relationship
                    forObjectWithID:(NSManagedObjectID *)objectID
                        withContext:(NSManagedObjectContext *)context
{
  NSLog(@"RequestWithMethod PathForRelationship forObjectId withContext");
}

- (NSString *)resourceIdentifierForRepresentation:(NSDictionary *)representation
                                         ofEntity:(NSEntityDescription *)entity
                                     fromResponse:(NSHTTPURLResponse *)response
{
  NSLog(@"resourceIdentifierForRepresentation ofEntity from Response");
  return [representation valueForKey:@"uuid"];
}
- (NSDictionary *)representationsForRelationshipsFromRepresentation:(NSDictionary *)representation
                                                           ofEntity:(NSEntityDescription *)entity
                                                       fromResponse:(NSHTTPURLResponse *)response
{
  NSLog(@"represenationsForRelatinshipsFromReporesentation OfEntity From Response");
  return nil;
}

/*- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject
{
  NSLog(@"test");
}*/

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation 
                                         ofEntity:(NSEntityDescription *)entity 
                                     fromResponse:(NSHTTPURLResponse *)response 
{
  //NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
  NSMutableDictionary *mutablePropertyValues = [[NSMutableDictionary alloc] init];
    if ([entity.name isEqualToString:@"Person"]) {
        [mutablePropertyValues setValue:[representation valueForKey:@"uuid"] forKey:@"uid"];
      //[mutablePropertyValues setValue:[representation valueForKey:@"screen_name"] forKey:@"username"];
      //[mutablePropertyValues setValue:[representation valueForKey:@"profile_image_url"] forKey:@"profileImageURLString"];
    }
    
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

@end
