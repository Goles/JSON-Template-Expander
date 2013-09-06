//
//  HIURLTemplateShorthands.m
//  Example
//
//  Created by Nicolas Goles on 8/28/13.
//  Copyright (c) 2013 HopIn. All rights reserved.
//

#import "NSDictionary+TemplateShorthands.h"

typedef enum {
    kDocumentKey_parent = 0,
    kDocumentKey_child = 1
} kDocumentKey;

@implementation NSDictionary (TemplateShorthands)

- (NSDictionary *)parsedTemplateShorthands
{
    NSDictionary *templates = self[@"links"];

    if (!templates) {
        return nil;
    }

    NSDictionary *objectKeysDictionary = [self objectKeysDictionaryFromDictionary:self];
    return [self expandDocument:self withDocumentKeys:objectKeysDictionary];
}

#pragma mark - Core Template Resolving Methods

- (NSDictionary *)expandDocument:(NSDictionary *)document withDocumentKeys:(NSDictionary *) links
{
    __block NSMutableDictionary *expandedDocument = [[NSMutableDictionary alloc] init];
    __block NSMutableArray *subDocuments = [[NSMutableArray alloc] init];

    [links enumerateKeysAndObjectsUsingBlock:^(id documentKey, id shortHands, BOOL *stop) {
        __block NSMutableDictionary *subDocument = nil;
        [self[documentKey] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *_stop) {
            subDocument = [self expandLinksInDocument:obj withDocumentLinks:links[documentKey]];
            if (subDocument) {
                [subDocuments addObject:subDocument];
            } else {
                subDocument = [self subDocumentWithLinks:links key:documentKey andDocument:obj];
                [subDocuments addObject:subDocument];
            }
        }];

        [expandedDocument setObject:subDocuments forKey:documentKey];
    }];

    return expandedDocument;
}

- (NSMutableDictionary *)subDocumentWithLinks:(NSDictionary *)links key:(id)documentKey andDocument:(NSDictionary *)document
{
    NSMutableDictionary *subDocument = [document mutableCopy];

    for (NSString * _key in links[documentKey]) {
        NSString *templatedURL = links[documentKey][_key][@"href"];
        NSString *template = [self extractTemplateFromURL:templatedURL];
        NSArray *keys = [self extractDocumentKeysFromString:template];
        NSString *expandedURL = [self expandURL:templatedURL withReplacement:subDocument[keys[kDocumentKey_child]]];
        if (!subDocument[_key]) {
            subDocument[_key] = [[NSMutableDictionary alloc] init];
        }
        subDocument[_key][@"href"] = expandedURL;
    }

    return subDocument;
}

- (NSDictionary *)defaultDocumentWithId:(NSString *)documentId andExpandedURL:(NSString *)expandedURL
{
    NSMutableDictionary *defaultDoc = [[NSMutableDictionary alloc] init];
    if (documentId) {
        defaultDoc[@"id"] = documentId;
    }
    defaultDoc[@"href"] = expandedURL;
    return defaultDoc;
}

- (NSMutableDictionary *)expandLinksInDocument:(NSDictionary *)document withDocumentLinks:(NSDictionary *)links
{
    if (!document[@"links"]) {
        return nil;
    }

    __block NSMutableDictionary *docCopy = [document mutableCopy];
    [docCopy removeObjectForKey:@"links"];

    [document[@"links"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *documentType = links[key][@"type"] ? links[key][@"type"] : key;

        if (documentType) {
            NSDictionary *linkedDoc;
            NSString *expandedURL;
            NSArray *guids = [obj isKindOfClass:[NSString class]] ? @[obj]: obj;

            for (NSString *guid in guids) {
                expandedURL = [self expandURL:links[key][@"href"] withReplacement:guid];
                linkedDoc = [self linkedResourceWithKey:documentType andIdentifier:guid];
                if (!linkedDoc) {
                    linkedDoc = [self defaultDocumentWithId:guid andExpandedURL:expandedURL];
                }
                [self assignLinkedDocument:linkedDoc toDocument:docCopy withKey:key andURL:expandedURL];
            }
        }
    }];

    return docCopy;
}

- (NSDictionary *)objectKeysDictionaryFromDictionary:(NSDictionary *)jsonDocument
{
    if (!jsonDocument[@"links"]) {
        return nil;
    }
    
    __block NSMutableDictionary *objectKeys = [[NSMutableDictionary alloc] init];
    [jsonDocument[@"links"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *splitKey = [self extractDocumentKeysFromString:key];
        NSString *parentKey = splitKey[kDocumentKey_parent];
        NSString *childKey = splitKey[kDocumentKey_child];

        if (!objectKeys[parentKey]) {
            objectKeys[parentKey] = [[NSMutableDictionary alloc] init];
        }

        if (!objectKeys[parentKey][childKey]) {
            objectKeys[parentKey][childKey] = [[NSMutableDictionary alloc] init];
        }

        NSString *url = [self extractURLFromResourceDescription:obj];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [objectKeys[parentKey][childKey] setObject:obj[@"type"] forKey:@"type"];
        }

        [objectKeys[parentKey][childKey] setObject:url forKey:@"href"];
    }];

    return objectKeys;
}

#pragma mark - Document Handling & Manipulation Helpers

- (NSDictionary *)linkedResourceWithKey:(NSString *)key andIdentifier:(NSString *)guid
{
    NSArray *match;
    if ([self[key] count] > 1) {
        NSArray *temp = self[key];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id MATCHES[cd] %@", guid];
        match = [temp filteredArrayUsingPredicate:predicate];
    } else {
        match = self[key];
    }
    return match[0];
}

- (NSString *)extractURLFromResourceDescription:(id)description
{
    if ([description isKindOfClass:[NSDictionary class]]) {
        return description[@"href"];
    } else if ([description isKindOfClass:[NSString class]]) {
        return description;
    }
    return nil;
}

- (void)replaceObjectWithArrayInDocument:(NSMutableDictionary *)document withKey:(NSString *)key
{
    NSDictionary *object = [document objectForKey:key];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithObjects:object, nil];
    document[key] = newArray;
}

- (void)assignLinkedDocument:(NSDictionary *)linkedDoc
                  toDocument:(NSMutableDictionary *)document
                     withKey:(NSString *)key
                      andURL:(NSString *)expandedURL
{
    if (document[key])  {
        if ([document[key] isKindOfClass:[NSDictionary class]]) {
            [self replaceObjectWithArrayInDocument:document withKey:key];
        }

        NSMutableDictionary *mutableLinkedDoc = [linkedDoc mutableCopy];
        mutableLinkedDoc[@"href"] = expandedURL;
        [document[key] addObject:mutableLinkedDoc];
    } else {
        [document setObject:[linkedDoc mutableCopy] forKey:key];
        document[key][@"href"] = expandedURL;
    }
}

#pragma mark - Shorthands Template & String Manipulation

- (NSArray *)extractDocumentKeysFromString:(NSString *) key
{
    NSArray *fragments = [key componentsSeparatedByString:@"."];
    return ([fragments count] != 2) ? nil : fragments;
}

- (NSString *)extractTemplateFromURL:(NSString *)bracedURL
{
    NSRange openBrace = [bracedURL rangeOfString:@"{"];
    NSRange closeBrace = [bracedURL rangeOfString:@"}"];
    NSRange extractionRange = NSMakeRange(NSMaxRange(openBrace), closeBrace.location - NSMaxRange(openBrace));
    return [bracedURL substringWithRange:extractionRange];
}

- (NSString *)replaceTemplateInURL:(NSString *)bracedURL withString:(NSString *)replacement
{
    NSRange openBrace = [bracedURL rangeOfString:@"{"];
    NSRange closeBrace = [bracedURL rangeOfString:@"}"];
    NSRange extractionRange = NSMakeRange(openBrace.location, NSMaxRange(closeBrace) - openBrace.location);

    NSMutableString *expandedURL = [NSMutableString stringWithString:bracedURL];
    [expandedURL replaceCharactersInRange:extractionRange withString:replacement];
    return expandedURL;
}

- (NSString *)expandURL:(NSString *)url withReplacement:(NSString *)replacement
{
    NSString *expandedURL = [self replaceTemplateInURL:url withString:replacement];
    return expandedURL;
}

@end
