//
//  TemplateShorthands-Private.h
//  Example
//
//  Created by Nicolas Goles on 9/2/13.
//  Copyright (c) 2013 HopIn. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 This is used to access the Category internals while testing, you don't
 really need to import it anywhere in your code.
 - Nicolas Goles Domic.
 */

@interface NSDictionary (TemplateShorthandsPrivate)

/** Core Template Resolving Methods */
- (NSDictionary *)expandDocument:(NSDictionary *)document withDocumentKeys:(NSDictionary *) links;
- (NSMutableDictionary *)subDocumentWithLinks:(NSDictionary *)links key:(id)documentKey andDocument:(NSDictionary *)document;
- (NSDictionary *)defaultDocumentWithId:(NSString *)documentId andExpandedURL:(NSString *)expandedURL;
- (NSMutableDictionary *)expandLinksInDocument:(NSDictionary *)document withDocumentLinks:(NSDictionary *) links;
- (NSDictionary *)objectKeysDictionaryFromDictionary:(NSDictionary *)jsonDocument;

/** Document Handling & Manipulation Helpers */
- (NSDictionary *)linkedResourceWithKey:(NSString *)key andIdentifier:(NSString *)guid;
- (NSString *)extractURLFromResourceDescription:(id)description;
- (void)replaceObjectWithArrayInDocument:(NSMutableDictionary *)document withKey:(NSString *)key;
- (void)assignLinkedDocument:(NSDictionary *)linkedDoc toDocument:(NSMutableDictionary *)document withKey:(NSString *)key andURL:(NSString *)expandedURL;

/** Shorthands Template & String Manipulation */
- (NSArray *)extractDocumentKeysFromString:(NSString *)key;
- (NSString *)extractTemplateFromURL:(NSString *)bracedURL;
- (NSString *)replaceTemplateInURL:(NSString *)bracedURL withString:(NSString *)replacement;
- (NSString *)expandURL:(NSString *)url withReplacement:(NSString *)replacement;
@end
