//
//  HIURLTemplateShorthands.h
//  Example
//
//  Created by Nicolas Goles on 8/28/13.
//  Copyright (c) 2013 HopIn. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The URL-Based JSON API format is defined in http://jsonapi.org/format/
 For more info refer to http://jsonapi.org/ and to the README.md
 Goles.
 */

@interface NSDictionary (JTE)
- (NSDictionary *)expandedTemplates;
@end
