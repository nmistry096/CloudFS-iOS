//
//  BitcasaSDKTests.m
//  BitcasaSDKTests
//
//  Created by Olga on 8/21/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Session.h"
#import "Credentials.h"
#import "BitcasaAPI.h"
#import "User.h"
#import "Account.h"
#import "Container.h"

@interface BitcasaSDKTests : XCTestCase

@end

@implementation BitcasaSDKTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    Session* session = [[Session alloc] initWithServerURL:@"https://w2krfscy4f.cloudfs.io"
                                                 clientId:@"aajNc4HKqv1cBR8y9g62YTrXyE6jn3zXJ_Nw8yXRQKU"
                                             clientSecret:@"yHTQD57owFI9kEJmKnjMDUyK-233Xx-dADxsf17MdaDd1zCCp2Vuiy8aGEj6GHFzeSxLntdJN51fPI2guTaGCw"];
    
    [session authenticateWithUsername:@"hchou@bitcasa.com"
                          andPassword:@"bitcasa543"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
