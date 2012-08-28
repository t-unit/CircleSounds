//
//  NSString+OSStatus.m
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import "NSString+OSStatus.h"

@implementation NSString (OSStatus)

+ (NSString*)stringWithOSStatus:(OSStatus)status
{
    char str[20];
    
	// see if it appears to be a 4-char-code
	*(UInt32 *)(str + 1) = CFSwapInt32HostToBig(status);
    
	if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
		str[0] = str[5] = '\'';
		str[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(str, "%d", (int)status);
    
    return [NSString stringWithUTF8String:str];
}

@end
