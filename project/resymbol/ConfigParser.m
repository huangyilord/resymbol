//
//  ConfigParser.m
//  resymbol
//
//  Created by huangyi on 8/11/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import "ConfigParser.h"

@interface ConfigParser()
{
    NSMutableDictionary*        symbolMap;
}

@end

@implementation ConfigParser

- (NSDictionary*)symbolMap
{
    return symbolMap;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        symbolMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)loadFile:(NSString*)fileName
{
    NSString* configStr = [NSString stringWithContentsOfFile:fileName encoding:NSASCIIStringEncoding error:nil];
    NSArray* lines = [configStr componentsSeparatedByString:@"\n"];
    NSMutableArray* configs = [[NSMutableArray alloc] init];
    for ( NSString* line in lines )
    {
        NSString* trimedStr = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( trimedStr.length > 0 )
        {
            NSArray* configsInLine = [trimedStr componentsSeparatedByString:@";"];
            [configs addObjectsFromArray:configsInLine];
        }
    }
    for ( NSString* config in configs )
    {
        if ( config.length > 0 )
        {
            NSArray* keyValue = [config componentsSeparatedByString:@"->"];
            if ( keyValue.count == 2 )
            {
                NSString* key = [keyValue[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString* value = [keyValue[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [symbolMap setObject:value forKey:key];
            }
            else
            {
                printf( "Format error: %s\n", [config UTF8String]);
            }
        }
    }
    return symbolMap.count > 0;
}

@end
