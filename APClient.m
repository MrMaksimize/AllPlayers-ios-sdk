//
//  APClient.m
//  AllPlayers
//
//  Created by Maksim Pecherskiy on 10/31/12.
//  Copyright (c) 2012 AllPlayers. All rights reserved.
//

#import "APClient.h"
#import "AFJSONRequestOperation.h"
#import "AFPropertyListRequestOperation.h"
#include <sys/time.h>
#import <CommonCrypto/CommonHMAC.h>
#import "APSettings.h"
// Non Afis

//static NSString * const kAllPlayersAPIBaseURLString = @"https://www.allplayers.com/api/v1/rest/";
static NSString* Base64EncodedStringFromData(NSData *data);
static NSString* URLEncodeString(NSString *string);
static const NSString *kOAuthSignatureMethodKey = @"oauth_signature_method";
static const NSString *kOAuthVersionKey = @"oauth_version";
static const NSString *kOAuthConsumerKey = @"oauth_consumer_key";
static const NSString *kOAuthTokenIdentifier = @"oauth_token";
static const NSString *kOAuthSignatureKey = @"oauth_signature";

static const NSString *kOAuthSignatureTypeHMAC_SHA1 = @"HMAC-SHA1";
static const NSString *kOAuthVersion1_0 = @"1.0";
static dispatch_once_t once;
static APClient *sharedClient;
//Class extention - private - 646
//http://stackoverflow.com/questions/9751057/what-is-the-interface-declaration-in-m-files-used-for-in-ios-5-projects
//http://stackoverflow.com/questions/9751057/what-is-the-interface-declaration-in-m-files-used-for-in-ios-5-projects
//http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocCategories.html#//apple_ref/doc/uid/TP30001163-CH20-SW2

@interface APClient()

- (id) initWithBaseURL:(NSURL *)url;
- (void) addGeneratedTimestampAndNonceInto:(NSMutableDictionary *)dictionary;

- (NSString *) authorizationHeaderValueForRequest:(NSURLRequest *)request;
@end

#define _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_
@implementation APClient

/*+ (APClient *)sharedClient {
  static APClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAllPlayersAPIBaseURLString]];
    [sharedSession setParameterEncoding:AFJSONParameterEncoding];
  });
  
  return _sharedClient;
}*/
#pragma mark - Singleton Initializers

+ (APClient *)sharedClient {
  dispatch_once(&once, ^ {
    sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAllPlayersAPIBaseURLString]];
    [sharedClient setParameterEncoding:AFJSONParameterEncoding];
  });
  return sharedClient;
}

+ (APClient *)sharedClientWithURL:(NSString*)url {
  dispatch_once(&once, ^ {
    sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:url]];
    [sharedClient setParameterEncoding:AFJSONParameterEncoding];
  });
  //[sharedClient setBaseURL:[NSURL URLWithString:url]];
  return sharedClient;
}

+ (APClient *)sharedOauthClientWithURL:(NSString*)url consumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret {
  dispatch_once(&once, ^ {
    sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:url] consumerKey:aConsumerKey secret:aConsumerSecret];
    [sharedClient setParameterEncoding:AFJSONParameterEncoding];
  });
  //[sharedSession setBaseURL:[NSURL URLWithString:url]];
  return sharedClient;
}

#pragma mark - Initializers

- (id) initWithBaseURL:(NSURL *)url consumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret {
  self = [super initWithBaseURL:url];
  
  if (self) {
    self.signRequests = YES;
    self.consumerKey = aConsumerKey;
    self.consumerSecret = aConsumerSecret;
    
    NSLog(@"Self Set Consumer Key => %@", self.consumerKey);
    NSLog(@"Self Set Consumer Key => %@", self.consumerSecret);
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Content-Type" value:@"application/json"];
  }
  
  return self;
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

#pragma mark - OAuth
+ (void) getRequestTokensWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  APClient *client = [[APClient alloc] initWithBaseURL:[[APClient sharedClient] baseURL]];
  NSLog(@"%@", [[APClient sharedClient] consumerKey]);
  [client setConsumerKey:[[APClient sharedClient] consumerKey] secret:[[APClient sharedClient] consumerSecret]];
  NSLog(@"%@", client.consumerKey);
  NSLog(@"%@", [[APClient sharedClient] consumerKey]);
  [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
  [client setDefaultHeader:@"Accept" value:@"text/html"];
  [client setDefaultHeader:@"Content-Type" value:@"text/html"];
  NSMutableDictionary *params = [NSMutableDictionary new];
  [params setObject:[[APClient sharedClient] consumerKey] forKey:kOAuthConsumerKey];
  [params setObject:[[APClient sharedClient] consumerSecret] forKey:kOAuthTokenIdentifier];
  [client sendSignedRequestWithPath:@"/oauth/request_token" method:@"GET" params:params success:success failure:failure];
}

+ (void) getAccessTokensWithRequestTokens:(NSDictionary *)requestTokens
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  APClient *client = [[APClient alloc] initWithBaseURL:[[APClient sharedClient] baseURL]];
  [client setConsumerKey:[[APClient sharedClient] consumerKey] secret:[[APClient sharedClient] consumerSecret]];
  [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
  [client setDefaultHeader:@"Accept" value:@"text/html"];
  [client setDefaultHeader:@"Content-Type" value:@"text/html"];
  [client setAccessToken:[requestTokens objectForKey:@"oauth_token"] secret:[requestTokens objectForKey:@"oauth_token_secret"]];
  [client sendSignedRequestWithPath:@"/oauth/access_token" method:@"GET" params:requestTokens success:success failure:failure];
}

- (void) sendSignedRequestWithPath:(NSString*)path
                            method:(NSString*)method
                            params:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  NSURLRequest *request = [self signedRequestWithMethod:method path:path parameters:params];
  
  AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
  [self enqueueHTTPRequestOperation:operation];
}

- (NSURLRequest *) signedRequestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
  
  NSString *authorizationHeader = [self authorizationHeaderValueForRequest:request];
  [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
  
  return request;
}

#pragma mark - Setters and Getters

- (void) addHeaderValue:(NSString*)value forKey:(NSString*)key {
  [self setDefaultHeader:key value:value];
}

- (void) setAccessToken:(NSString *)accessToken secret:(NSString *)secret {
  self.tokenIdentifier = accessToken;
  self.tokenSecret = secret;
  self.threeLegged = YES;
}

- (void) setConsumerKey:(NSString *)aConsumerKey secret:(NSString *)secret {
  self.consumerKey = aConsumerKey;
  self.consumerSecret = secret;
}

#pragma mark - Helpers

- (NSMutableDictionary *) mutableDictionaryWithOAuthInitialData {
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 kOAuthSignatureTypeHMAC_SHA1, kOAuthSignatureMethodKey,
                                 kOAuthVersion1_0, kOAuthVersionKey,
                                 nil];
  
  if (self.consumerKey) [result setObject:self.consumerKey forKey:kOAuthConsumerKey];
  if (self.tokenIdentifier) [result setObject:self.tokenIdentifier forKey:kOAuthTokenIdentifier];
  
  [self addGeneratedTimestampAndNonceInto:result];
  
  return  result;
}

- (NSString *) stringWithOAuthParameters:(NSMutableDictionary *)oauthParams requestParameters:(NSDictionary *)parameters {
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:oauthParams];
  [params addEntriesFromDictionary:parameters];
  
  // sorting parameters
  NSArray *sortedKeys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
    NSComparisonResult result = [key1 compare:key2 options:NSLiteralSearch];
    if (result == NSOrderedSame)
      result = [[params objectForKey:key1] compare:[params objectForKey:key2] options:NSLiteralSearch];
    
    return result;
  }];
  
  // join keys and values with =
  NSMutableArray *longListOfParameters = [NSMutableArray arrayWithCapacity:[sortedKeys count]];
  [sortedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
    [longListOfParameters addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
  }];
  
  // join components with &
  return [longListOfParameters componentsJoinedByString:@"&"];
}

- (NSString *) authorizationHeaderValueForRequest:(NSURLRequest *)request {
  NSURL *url = request.URL;
  NSString *fixedURL = [self baseURLforAddress:url];
  NSMutableDictionary *oauthParams = [self mutableDictionaryWithOAuthInitialData];
  // adding oauth_ extra params to the header
  NSArray *parameterComponents = [[request.URL query] componentsSeparatedByString:@"&"];
  NSMutableDictionary *parameters = [NSMutableDictionary new];
  for(NSString *component in parameterComponents) {
    NSArray *subComponents = [component componentsSeparatedByString:@"="];
    if ([subComponents count] == 2) {
      [parameters setObject:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];
    }
  }
  NSData *body = [request HTTPBody];
  NSString *htttpBody = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
  NSArray *subComponents = [htttpBody componentsSeparatedByString:@"="];
  if ([subComponents count] == 2) {
    [parameters setObject:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];
  }
  
  NSString *allParameters = [self stringWithOAuthParameters:oauthParams requestParameters:parameters];
  // adding HTTP method and URL
  NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@", [request.HTTPMethod uppercaseString], URLEncodeString(fixedURL), URLEncodeString(allParameters)];
  
  NSString *signature = [self signatureForBaseString:signatureBaseString];
  
  // add to OAuth params
  [oauthParams setObject:signature forKey:kOAuthSignatureKey];
  
  // build OAuth Authorization Header
  NSMutableArray *headerParams = [NSMutableArray arrayWithCapacity:[oauthParams count]];
  [oauthParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
    [headerParams addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, URLEncodeString(obj)]];
  }];
  
  // let's use the base URL if a realm was not set
  NSString *oauthRealm = self.realm;
  if (!oauthRealm) oauthRealm = [self baseURLforAddress:[self baseURL]];
  
  NSString *result = [NSString stringWithFormat:@"OAuth realm=\"%@\",%@", oauthRealm, [headerParams componentsJoinedByString:@","]];
  
  return result;
}

- (void)addGeneratedTimestampAndNonceInto:(NSMutableDictionary *)dictionary {
  NSUInteger epochTime = (NSUInteger)[[NSDate date] timeIntervalSince1970];
  NSString *timestamp = [NSString stringWithFormat:@"%d", epochTime];
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  NSString *nonce = (__bridge NSString *)string;
  CFRelease(theUUID);
  
  [dictionary setObject:nonce forKey:@"oauth_nonce"];
  [dictionary setObject:timestamp forKey:@"oauth_timestamp"];
}

- (NSString *) signatureForBaseString:(NSString *)baseString {
  NSString *key = [NSString stringWithFormat:@"%@&%@", self.consumerSecret != nil ? URLEncodeString(self.consumerSecret) : @"", self.tokenSecret != nil ? URLEncodeString(self.tokenSecret) : @""];
  const char *keyBytes = [key cStringUsingEncoding:NSUTF8StringEncoding];
  const char *baseStringBytes = [baseString cStringUsingEncoding:NSUTF8StringEncoding];
  unsigned char digestBytes[CC_SHA1_DIGEST_LENGTH];
  
  CCHmac(kCCHmacAlgSHA1, keyBytes, strlen(keyBytes), baseStringBytes, strlen(baseStringBytes), digestBytes);
  
  NSData *digestData = [NSData dataWithBytes:digestBytes length:CC_SHA1_DIGEST_LENGTH];
  return Base64EncodedStringFromData(digestData);
}

- (NSString *) baseURLforAddress:(NSURL *)url {
  NSAssert1([url host] != nil, @"URL host missing: %@", [url absoluteString]);
  
  // Port need only be present if it's not the default
  NSString *hostString;
  if (([url port] == nil)
      || ([[[url scheme] lowercaseString] isEqualToString:@"http"] && ([[url port] integerValue] == 80))
      || ([[[url scheme] lowercaseString] isEqualToString:@"https"] && ([[url port] integerValue] == 443))) {
    hostString = [[url host] lowercaseString];
  } else {
    hostString = [NSString stringWithFormat:@"%@:%@", [[url host] lowercaseString], [url port]];
  }
  
  return [NSString stringWithFormat:@"%@://%@%@", [[url scheme] lowercaseString], hostString, [[url absoluteURL] path]];
}



- (NSMutableURLRequest *) requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters {
  
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
  
  if (self.signRequests) {
    NSString *authorizationHeader = [self authorizationHeaderValueForRequest:request];
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
  }
  
  return request;
}

- (NSURLRequest *) unsignedRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
  NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
  
  return request;
}

#pragma mark - Encoding Helpers
//
//  The function below is based on
//
//  NSString+URLEncode.h
//
//  Created by Scott James Remnant on 6/1/11.
//  Copyright 2011 Scott James Remnant <scott@netsplit.com>. All rights reserved.
//
static NSString *URLEncodeString(NSString *string) {
  // See http://en.wikipedia.org/wiki/Percent-encoding and RFC3986
  // Hyphen, Period, Understore & Tilde are expressly legal
  const CFStringRef legalURLCharactersToBeEscaped = CFSTR(":/=,!$&'()*+;[]@#?");
  
  return (__bridge  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, ( CFStringRef)string, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8);
}
//@end

// The function below was inspired on
//
// AFOAuth2Client.m
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me/)
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
//
static NSString * Base64EncodedStringFromData(NSData *data) {
  NSUInteger length = [data length];
  NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
  
  uint8_t *input = (uint8_t *)[data bytes];
  uint8_t *output = (uint8_t *)[mutableData mutableBytes];
  
  for (NSUInteger i = 0; i < length; i += 3) {
    NSUInteger value = 0;
    for (NSUInteger j = i; j < (i + 3); j++) {
      value <<= 8;
      if (j < length) value |= (0xFF & input[j]);
    }
    
    static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    NSUInteger idx = (i / 3) * 4;
    output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
    output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
    output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
    output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
  }
  
  return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
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
