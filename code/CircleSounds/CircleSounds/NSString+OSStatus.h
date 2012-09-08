//
//  NSString+OSStatus.h
//  RecordPlayThrough
//
//  Created by Tobias Ottenweller on 08.07.12.
//  Copyright (c) 2012 Tobias Ottenweller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OSStatus)

/**
 Class Method creating a NSString object using a OSStatus value. 
 Returns a NSString either with the decimal value or a 4 character represenation ofthe supplied status.
 
 This method is based on the CheckError function of Chris Adamson and Kevin Avila 
 (availible at http://www.informit.com/content/images/9780321636843/instructorresources/9780321636843_learning-core-audio-xcode4-projects.zip ).
*/
+ (NSString *)stringWithOSStatus:(OSStatus)status;

@end
