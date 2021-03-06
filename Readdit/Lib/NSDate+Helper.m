//
//  NSDate+Helper.m
//  Codebook
//
//  Created by Billy Gray on 2/26/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [calendar components:(NSDayCalendarUnit) 
                         fromDate:self
                         toDate:[NSDate date]
                        options:0];
  return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
  // get a midnight version of ourself:
  NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
  [mdf setDateFormat:@"yyyy-MM-dd"];
  NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
  [mdf release];
  
  return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
  return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
  NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
  NSString *text = nil;
  switch (daysAgo) {
    case 0:
      text = @"Today";
      break;
    case 1:
      text = @"Yesterday";
      break;
    default:
      text = [NSString stringWithFormat:@"%d days ago", daysAgo];
  }
  return text;
}

+ (NSString *)dbFormatString {
  return @"yyyy-MM-dd HH:mm:ss";
}

+ (NSDate *)dateFromString:(NSString *)string {
  NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
  [inputFormatter setDateFormat:[NSDate dbFormatString]];
  NSDate *date = [inputFormatter dateFromString:string];
  [inputFormatter release];
  return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:format];
  NSString *timestamp_str = [outputFormatter stringFromDate:date];
  [outputFormatter release];
  return timestamp_str;
}

+ (NSString *)stringFromDate:(NSDate *)date {
  return [NSDate stringFromDate:date withFormat:[NSDate dbFormatString]];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
  /* 
   * if the date is in today, display 12-hour time with meridian,
   * if it is within the last 7 days, display weekday name (Friday)
   * if within the calendar year, display as Jan 23
   * else display as Nov 11, 2008
   */
  
  NSDate *today = [NSDate date];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
                           fromDate:today];
  
  NSDate *midnight = [calendar dateFromComponents:offsetComponents];
  
  NSDateFormatter *displayFormatter = [[[NSDateFormatter alloc] init] autorelease];
  
  // comparing against midnight
  if ([date compare:midnight] == NSOrderedDescending) {
    [displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
  } else {
    // check if date is within last 7 days
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:-7];
    NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
    [componentsToSubtract release];
    if ([date compare:lastweek] == NSOrderedDescending) {
      [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
    } else {
      // check if same calendar year
      NSInteger thisYear = [offsetComponents year];
      
      NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
                               fromDate:date];
      NSInteger thatYear = [dateComponents year];     
      if (thatYear >= thisYear) {
        [displayFormatter setDateFormat:@"MMM d"];
      } else {
        [displayFormatter setDateFormat:@"MMM d, YYYY"];
      }
    }
  }
  
  // use display formatter to return formatted date string
  return [displayFormatter stringFromDate:date];
}

+ (NSString *)fastStringForDisplayFromDate:(NSDate *)date {
  /* 
   * if the date is in today, display 12-hour time with meridian,
   * if it is within the last 7 days, display weekday name (Friday)
   * if within the calendar year, display as Jan 23
   * else display as Nov 11, 2008
   */
  
  static NSDateFormatter *formatter = nil;
  static NSCalendar *calendar;
  static NSDateComponents *offset;
  static NSDate *midnight, *lastweek;
  NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | 
                      NSDayCalendarUnit);
  
  if (! formatter) {
    formatter = [[NSDateFormatter alloc] init];
    calendar = [[NSCalendar currentCalendar] retain];
    offset = [[calendar components:units fromDate:[NSDate date]] retain];
    midnight = [[calendar dateFromComponents:offset] retain];
    NSDateComponents *c = [[[NSDateComponents alloc] init] autorelease];
    [c setDay:-7];
    lastweek = [[calendar dateByAddingComponents:c toDate:[NSDate date]
                                         options:0] retain];
  }
  
  if ([date compare:midnight] == NSOrderedDescending) // after midnight?
    [formatter setDateFormat:@"h:mm a"]; // 11:30 am
  else if ([date compare:lastweek] == NSOrderedDescending) // within last 7 days
    [formatter setDateFormat:@"EEEE"]; // Tuesday
  else if ([[calendar components:units fromDate:date] year] >= [offset year])
    [formatter setDateFormat:@"MMM d"];
  else [formatter setDateFormat:@"MMM d, YYYY"];
  
  return [formatter stringFromDate:date];
}

@end