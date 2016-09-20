//
//  ConfigParser.h
//  resymbol
//
//  Created by huangyi on 8/11/16.
//  Copyright © 2016 huangyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigParser : NSObject

@property (nonatomic, readonly) NSDictionary* symbolMap;

- (BOOL)loadFile:(NSString*)fileName;

@end
