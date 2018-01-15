//
//  YESafetyPin.h
//
//

#import <Foundation/Foundation.h>

#define LOG_FLAG_ERROR    (1 << 0)  // 0...00001
#define LOG_FLAG_WARN     (1 << 1)  // 0...00010
#define LOG_FLAG_INFO     (1 << 2)  // 0...00100
#define LOG_FLAG_DEBUG    (1 << 3)  // 0...01000
#define LOG_FLAG_VERBOSE  (1 << 4)  // 0...10000

#define LOG_LEVEL_OFF     0
#define LOG_LEVEL_ERROR   (LOG_FLAG_ERROR)                                                                      // 0...00001
#define LOG_LEVEL_WARN    (LOG_FLAG_ERROR | LOG_FLAG_WARN)                                                      // 0...00011
#define LOG_LEVEL_INFO    (LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO)                                      // 0...00111
#define LOG_LEVEL_DEBUG   (LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO | LOG_FLAG_DEBUG)                     // 0...01111
#define LOG_LEVEL_VERBOSE (LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO | LOG_FLAG_DEBUG | LOG_FLAG_VERBOSE)  // 0...11111
#define LOG_LEVEL_ALL      0xFFFFFFFF // 1111....11111 (LOG_LEVEL_VERBOSE plus any other flags)

@interface YESafetyPin : NSObject

//+ (void)setLogEnabled:(BOOL)enabled;

@end
