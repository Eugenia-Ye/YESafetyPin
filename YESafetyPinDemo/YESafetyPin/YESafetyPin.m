//
//  YESafetyPin.m
//
//

#import "YESafetyPin.h"
#import <objc/runtime.h>

#if __has_feature(objc_arc)
#warning "Should disable arc (-fno-objc-arc)"
#endif

#if DEBUG
static int logLevel = LOG_LEVEL_VERBOSE;
#else
static int logLevel = LOG_LEVEL_ERROR;
#endif



#define YE_LOG_MESSAGE(...) safetyCollectionLogMessage(__VA_ARGS__)

void safetyCollectionLogMessage(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

void safetyCollectionLogMessage(NSString *format, ...)
{
    if (!logLevel)
    {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *content = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"%@", content);
    va_end(args);
    
    if(logLevel >= LOG_LEVEL_VERBOSE)
        NSLog(@" ============= call stack ========== \n%@", [NSThread callStackSymbols]);
}

#pragma mark - NSArray

@interface NSArray (YESafe)

@end

@implementation NSArray (YESafe)


+ (Method)methodOfSelector:(SEL)selector
{
    return class_getInstanceMethod(NSClassFromString(@"__NSArrayI"),selector);
}

- (id)ye_objectAtIndexI:(NSUInteger)index
{
    if (index >= self.count)
    {
        YE_LOG_MESSAGE(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
    
    return [self ye_objectAtIndexI:index];
}

+ (id)ye_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    id validObjects[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i])
        {
            validObjects[count] = objects[i];
            count++;
        }
        else
        {
            YE_LOG_MESSAGE(@"[%@ %@] NIL object at index {%lu}",
                    NSStringFromClass([self class]),
                    NSStringFromSelector(_cmd),
                    (unsigned long)i);
            
        }
    }
    
    return [self ye_arrayWithObjects:validObjects count:count];
}

@end

#pragma mark - NSMutableArray

@interface NSMutableArray (YESafe)

@end

@implementation NSMutableArray (YESafe)

+ (Method)methodOfSelector:(SEL)selector
{
    return class_getInstanceMethod(NSClassFromString(@"__NSArrayM"),selector);
}

- (id)ye_objectAtIndexM:(NSUInteger)index
{
    if (index >= self.count)
    {
        YE_LOG_MESSAGE(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
    
    return [self ye_objectAtIndexM:index];
}

- (void)ye_addObject:(id)anObject
{
    if (!anObject)
    {
        YE_LOG_MESSAGE(@"[%@ %@], NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        //https://stackoverflow.com/questions/2057910/how-to-add-nil-to-nsmutablearray
        [self ye_addObject:[NSNull null]];
        
        return;
    }
    [self ye_addObject:anObject];
}

- (void)ye_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index >= self.count)
    {
        YE_LOG_MESSAGE(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        YE_LOG_MESSAGE(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        [self ye_replaceObjectAtIndex:index withObject:[NSNull null]];
        
        return;
    }
    
    [self ye_replaceObjectAtIndex:index withObject:anObject];
}

- (void)ye_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (index > self.count)
    {
        YE_LOG_MESSAGE(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        YE_LOG_MESSAGE(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        [self ye_insertObject:[NSNull null] atIndex:index];
        
        return;
    }
    
    [self ye_insertObject:anObject atIndex:index];
}

@end

#pragma mark - NSDictionary

@interface NSDictionary (YESafe)

@end

@implementation NSDictionary (YESafe)

+ (instancetype)ye_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    id validObjects[cnt];
    id<NSCopying> validKeys[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        //if (objects[i] && keys[i])
        if (keys[i])
        {
            if (!objects[i]) {
                validObjects[count] = [NSNull null];
            } else {
                validObjects[count] = objects[i];
            }
            
            validKeys[count] = keys[i];
            count ++;
    
        } else {
            YE_LOG_MESSAGE(@"[%@ %@] NIL object or key at index{%lu}.",
                    NSStringFromClass(self),
                    NSStringFromSelector(_cmd),
                    (unsigned long)i);
        }
    }
    
    return [self ye_dictionaryWithObjects:validObjects forKeys:validKeys count:count];
}

@end

#pragma mark - NSMutableDictionary

@interface NSMutableDictionary (YESafe)

@end

@implementation NSMutableDictionary (YESafe)

+ (Method)methodOfSelector:(SEL)selector
{
    return class_getInstanceMethod(NSClassFromString(@"__NSDictionaryM"),selector);
}

- (void)ye_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (!aKey)
    {
        YE_LOG_MESSAGE(@"[%@ %@] NIL key.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    if (!anObject)
    {
        YE_LOG_MESSAGE(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        //https://stackoverflow.com/questions/12008365/ios-why-cant-i-set-nil-to-nsdictionary-value
        //https://stackoverflow.com/questions/13810875/inserting-nil-objects-into-an-nsdictionary
        [self ye_setObject:[NSNull null] forKey:aKey];
        
        return;
    }
    
    [self ye_setObject:anObject forKey:aKey];
}

@end


#pragma mark - NSString
 
 @interface NSString (YESafe)
 
 @end
 
@implementation NSString (YESafe)

- (NSString *)ye_substringFromIndex:(NSUInteger)from
{
    if (from <= self.length) {
        return [self ye_substringFromIndex:from];
    }
    YE_LOG_MESSAGE(@"[%@ %@] NIL object because from{%lu} out of NSString len{%lu}.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)from, (unsigned long)self.length);
    return nil;
}

- (NSString *)ye_substringToIndex:(NSUInteger)to
{
    if (to <= self.length) {
        return [self ye_substringToIndex:to];
    }
    return self;
}

- (NSString *)ye_substringWithRange:(NSRange)range
{
    if (range.location + range.length <= self.length) {
        return [self ye_substringWithRange:range];
    }else if (range.location < self.length){
        return [self ye_substringWithRange:NSMakeRange(range.location, self.length-range.location)];
    }
    
    YE_LOG_MESSAGE(@"[%@ %@] return NIL object because range's location{%lu} out of NSString len{%lu}.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)range.location, (unsigned long)self.length);
    return nil;
}

@end



/*
 - (NSArray<NSTextCheckingResult *> *)matchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
 - (NSUInteger)numberOfMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
 - (nullable NSTextCheckingResult *)firstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
 - (NSRange)rangeOfFirstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
 */

//NSRegularExpression
#pragma mark - NSString

@interface NSRegularExpression (YESafe)

@end

@implementation NSRegularExpression (YESafe)

- (NSArray<NSTextCheckingResult *> *)ye_matchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range {
    if (range.location + range.length <= string.length) {
        return [self ye_matchesInString:string options:options range:range];
    }else if (range.location < string.length){
        return [self ye_matchesInString:string options:options range:NSMakeRange(range.location, string.length-range.location)];
    }
    
    YE_LOG_MESSAGE(@"[%@ %@] return NIL object because range's location{%lu} out of NSRegularExpression len{%lu}.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)range.location, (unsigned long)string.length);
    return nil;
}

//- (NSUInteger)numberOfMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;

- (nullable NSTextCheckingResult *)ye_firstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range {
    if (range.location + range.length <= string.length) {
        return [self ye_firstMatchInString:string options:options range:range];
    }else if (range.location < string.length){
        return [self ye_firstMatchInString:string options:options range:NSMakeRange(range.location, string.length-range.location)];
    }
    
    YE_LOG_MESSAGE(@"[%@ %@] return NIL object because range's location{%lu} out of NSRegularExpression len{%lu}.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)range.location, (unsigned long)string.length);
    return nil;
}

- (NSRange)ye_rangeOfFirstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range {
    if (range.location + range.length <= string.length) {
        return [self ye_rangeOfFirstMatchInString:string options:options range:range];
    }else if (range.location < string.length){
        return [self ye_rangeOfFirstMatchInString:string options:options range:NSMakeRange(range.location, string.length-range.location)];
    }
    
    YE_LOG_MESSAGE(@"[%@ %@] return NSMakeRange(0, 0) because range's location{%lu} out of NSRegularExpression len{%lu}.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)range.location, (unsigned long)string.length);
    return NSMakeRange(0, 0);
}

@end


#pragma mark -

@implementation YESafetyPin

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // NSArray
        [self exchangeOriginalMethod:[NSArray methodOfSelector:@selector(objectAtIndex:)] withNewMethod:[NSArray methodOfSelector:@selector(ye_objectAtIndexI:)]];
        [self exchangeOriginalMethod:class_getClassMethod([NSArray class], @selector(arrayWithObjects:count:))
                       withNewMethod:class_getClassMethod([NSArray class], @selector(ye_arrayWithObjects:count:))];
        // NSMutableArray
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(objectAtIndex:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(ye_objectAtIndexM:)]];
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(replaceObjectAtIndex:withObject:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(ye_replaceObjectAtIndex:withObject:)]];
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(addObject:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(ye_addObject:)]];
        [self exchangeOriginalMethod:[NSMutableArray methodOfSelector:@selector(insertObject:atIndex:)] withNewMethod:[NSMutableArray methodOfSelector:@selector(ye_insertObject:atIndex:)]];
        // NSDictionary
        [self exchangeOriginalMethod:class_getClassMethod([NSDictionary class], @selector(dictionaryWithObjects:forKeys:count:))
                       withNewMethod:class_getClassMethod([NSDictionary class], @selector(ye_dictionaryWithObjects:forKeys:count:))];
        // NSMutableDictionary
        [self exchangeOriginalMethod:[NSMutableDictionary methodOfSelector:@selector(setObject:forKey:)] withNewMethod:[NSMutableDictionary methodOfSelector:@selector(ye_setObject:forKey:)]];
        
        
        //NSString
        [self exchangeOriginalMethod:class_getClassMethod([NSString class], @selector(substringFromIndex:))
                       withNewMethod:class_getClassMethod([NSString class], @selector(ye_substringFromIndex:))];
        
        [self exchangeOriginalMethod:class_getClassMethod([NSString class], @selector(substringToIndex:))
                       withNewMethod:class_getClassMethod([NSString class], @selector(ye_substringToIndex:))];
        
        
        [self exchangeOriginalMethod:class_getClassMethod([NSString class], @selector(substringWithRange:))
                       withNewMethod:class_getClassMethod([NSString class], @selector(ye_substringWithRange:))];
        
        /*
         - (NSArray<NSTextCheckingResult *> *)matchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
         - (NSUInteger)numberOfMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
         - (nullable NSTextCheckingResult *)firstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
         - (NSRange)rangeOfFirstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
         */
        
        //NSRegularExpression
        [self exchangeOriginalMethod:class_getClassMethod([NSRegularExpression class], @selector(matchesInString:options:range:))
                       withNewMethod:class_getClassMethod([NSRegularExpression class], @selector(ye_matchesInString:options:range:))];
        
        [self exchangeOriginalMethod:class_getClassMethod([NSRegularExpression class], @selector(firstMatchInString:options:range:))
                       withNewMethod:class_getClassMethod([NSRegularExpression class], @selector(ye_firstMatchInString:options:range:))];
        
        
        [self exchangeOriginalMethod:class_getClassMethod([NSRegularExpression class], @selector(rangeOfFirstMatchInString:options:range:))
                       withNewMethod:class_getClassMethod([NSRegularExpression class], @selector(ye_rangeOfFirstMatchInString:options:range:))];
        
        //NSTextCheckingResult
        //- (NSRange)rangeAtIndex:(NSUInteger)idx NS_AVAILABLE(10_7, 4_0);
        
//        [self exchangeOriginalMethod:class_getClassMethod([NSTextCheckingResult class], @selector(rangeAtIndex:))
//                       withNewMethod:class_getClassMethod([NSTextCheckingResult class], @selector(ye_rangeAtIndex:))];
    });
}

+ (void)exchangeOriginalMethod:(Method)originalMethod withNewMethod:(Method)newMethod
{
    method_exchangeImplementations(originalMethod, newMethod);
}

+ (void)setLogLevel:(int)LOG_LEVEL_XXX
{
    logLevel = LOG_LEVEL_XXX;
}

@end
