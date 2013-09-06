//
//  NSDictionary+TemplateShorthandsTests.m
//  Example
//
//  Created by Nicolas Goles on 8/28/13.
//  Copyright (c) 2013 HopIn. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+TemplateShorthands.h"
#import "TemplateShorthands-Private.h"

@interface NSDictionary_TemplateShorthandsTests : XCTestCase
@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation NSDictionary_TemplateShorthandsTests

- (void)setUp
{
    [super setUp];
    self.bundle = [NSBundle bundleForClass: [self class]];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark - Unit Tests for Private methods
- (void)testExtractTemplateFromURL
{
    NSDictionary *testDictionary = [[NSDictionary alloc] init];
    NSString *template = [testDictionary extractTemplateFromURL:@"https://www.exampleurl.com/section/another_section/{template.test}/section/"];
    XCTAssertEqualObjects(template, @"template.test", @"Error extracting template from URL");
}

- (void)testReplaceTemplateInURL
{
    NSDictionary *testDictionary = [[NSDictionary alloc] init];
    NSString *testURL = @"http://www.testurl.com/section1/{template.key}/section2/";
    NSString * output = [testDictionary replaceTemplateInURL:testURL withString:@"testString"];
    XCTAssertEqualObjects(@"http://www.testurl.com/section1/testString/section2/", output, @"Error while replacing template with string");
}

- (void)testExtractDocumentKeysFromString
{
    NSDictionary *testDictionary = [[NSDictionary alloc] init];
    NSArray *keys = [testDictionary extractDocumentKeysFromString:@"hello.world"];
    XCTAssertEqualObjects(keys[0], @"hello");
    XCTAssertEqualObjects(keys[1], @"world");
}

- (void)testExtractURLFromResourceDescription
{
    NSDictionary *dictionaryInput = @{ @"href" : @"/users/{something.test}/awesome/great/"};
    NSString *stringInput = @"/users/{users.id}/collections";

    NSDictionary *testDictionary = [[NSDictionary alloc] init];

    XCTAssertEqualObjects([testDictionary extractURLFromResourceDescription:dictionaryInput], @"/users/{something.test}/awesome/great/");
    XCTAssertEqualObjects([testDictionary extractURLFromResourceDescription:stringInput], @"/users/{users.id}/collections");
}

- (void)testCreateObjectKeysDictionary
{
    NSDictionary *input = [self JSONDictionaryFromResource:@"input5"];
    if (!input) {
        XCTFail(@"Error while loading input JSONT in \"%s\"", __PRETTY_FUNCTION__);
    }

    NSDictionary *output = [self JSONDictionaryFromResource:@"output5"];
    if (!output) {
        XCTFail(@"Error while loading input JSONT in \"%s\"", __PRETTY_FUNCTION__);
    }

    NSDictionary *testDictionary = [[NSDictionary alloc] init];
    NSDictionary *testOuptut = [testDictionary objectKeysDictionaryFromDictionary:input];
    XCTAssertEqualObjects(output, testOuptut);
}

#pragma mark - Integration Tests

/** http://jsonapi.org/format/ Second Example of URL Template Shorthands */

- (void)testSimpleLinksObjectParsing
{
    NSDictionary *input = [self JSONDictionaryFromResource:@"input1"];
    if (!input) {
        XCTFail(@"Error while loading input JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    NSDictionary *acceptance = [self JSONDictionaryFromResource:@"output1"];
    if (!acceptance) {
        XCTFail(@"Error while loading acceptance JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    XCTAssertEqualObjects([input parsedTemplateShorthands], acceptance, @"Wrong formated dictionary");
}

/** http://jsonapi.org/format/ Second Example of URL Template Shorthands */

- (void)testMultiNestedLinkObjectParsing
{
    NSDictionary *input = [self JSONDictionaryFromResource:@"input2"];
    if (!input) {
        XCTFail(@"Error while loading input JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    NSDictionary *acceptance = [self JSONDictionaryFromResource:@"output2"];
    if (!acceptance) {
        XCTFail(@"Error while loading acceptance JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    XCTAssertEqualObjects([input parsedTemplateShorthands], acceptance, @"Wrong formated dictionary");
}

/** http://jsonapi.org/format/ Third Example of URL Template Shorthands */

- (void)testHasOneRelationshipParsing
{
    NSDictionary *input = [self JSONDictionaryFromResource:@"input3"];
    if (!input) {
        XCTFail(@"Error while loading input JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    NSDictionary *acceptance = [self JSONDictionaryFromResource:@"output3"];
    if (!acceptance) {
        XCTFail(@"Error while loading acceptance JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    XCTAssertEqualObjects([input parsedTemplateShorthands], acceptance, @"Wrong formated dictionary");
}

/** http://jsonapi.org/format/ Third Example of URL Template Shorthands */

- (void)testCompoundDocument
{
    NSDictionary *input = [self JSONDictionaryFromResource:@"input4"];
    if (!input) {
        XCTFail(@"Error while loading input JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    NSDictionary *acceptance = [self JSONDictionaryFromResource:@"output4"];
    if (!acceptance) {
        XCTFail(@"Error while loading acceptance JSON in \"%s\"", __PRETTY_FUNCTION__);
    }

    XCTAssertEqualObjects([input parsedTemplateShorthands], acceptance, @"Wrong formated dictionary");
}


#pragma mark - Helper Methods

- (NSDictionary *) JSONDictionaryFromResource:(NSString *)resource
{
    NSError *error;
    NSString *path = [self.bundle pathForResource:resource ofType:@"json"];

    if (!path) {
        return nil;
    }
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error) {
        return nil;
    }

    return dictionary;
}

@end
