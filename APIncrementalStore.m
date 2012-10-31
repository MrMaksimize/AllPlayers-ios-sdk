//
//  APIncrementalStore.m
//  AllPlayers
//
//  Created by Maksim Pecherskiy on 10/31/12.
//  Copyright (c) 2012 AllPlayers. All rights reserved.
//

#import "APIncrementalStore.h"
#import "APClient.h"

@implementation APIncrementalStore
+ (void)initialize {
  [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
  return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model {
  return [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"APCI" withExtension:@"xcdatamodeld"]];
}

- (id <AFIncrementalStoreHTTPClient>)HTTPClient {
  return [APClient sharedClient];
}

@end