//
//  ModMusicaTests.m
//  ModMusicaTests
//
//  Created by Travis Henspeter on 10/27/14.
//  Copyright (c) 2014 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ModMusicaTests : XCTestCase

@end

@implementation ModMusicaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPlist
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Shaders" ofType:@"plist"];
    XCTAssertNotNil(path);
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
    XCTAssertNotNil(plist);
    NSLog(@"plist: %@",plist);
    NSDictionary *testShaderDictionary = plist[@"test"];
    XCTAssertNotNil(testShaderDictionary);
    NSDictionary *shaders = testShaderDictionary[@"shaders"];
    XCTAssertNotNil(shaders);
    NSDictionary *uniforms = testShaderDictionary[@"uniforms"];
    XCTAssertNotNil(uniforms);
    NSDictionary *attributes = testShaderDictionary[@"attributes"];
    XCTAssertNotNil(attributes);
    NSDictionary *textures = testShaderDictionary[@"textures"];
    XCTAssertNotNil(textures);
    
}

- (void)testGetShaderStuff
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Shaders" ofType:@"plist"];
    XCTAssertNotNil(path);
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
    XCTAssertNotNil(plist);
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
