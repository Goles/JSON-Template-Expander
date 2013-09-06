//
//  HIURLTemplateShorthands.h
//  Example
//
//  Created by Nicolas Goles on 8/28/13.
//  Copyright (c) 2013 HopIn. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 This is an implementation for JSON API URL Template Shorthands
 The standard is defined in http://jsonapi.org/format/ it basically
 says:
    When returning a list of documents from a response, a top-level "links"
    object can specify a URL template that should be used for all documents.
 
 "links": {
    "posts.author": "http://example.com/people/{posts.author}"
 },

 This NSDictionary Category basically adds an href field to each templated
 resource by taking the link into account.
 */

@interface NSDictionary (TemplateShorthands)
- (NSDictionary *) parsedTemplateShorthands;
@end
