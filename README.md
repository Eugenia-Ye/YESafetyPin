![App Icon](https://github.com/Eugenia-Ye/YESafetyPin/blob/master/YESafetyPinDemo/Images.xcassets/AppIcon.appiconset/Icon-App-40x40%403x.png) # YESafetyPin
----------
# What is the library for ?
NSArray, NSMutableArray, NSSet, NSMutableSet, NSDictionary and  NSMutableDictionary are pretty common collections we used in iOS development. While enjoying the convenience of these classes, they also bring us some trouble. 

For example, we might accidentally pass an nil when we call addObject, or possibly pass an **out of bounds** index to objectAtIndex. 
Especially when you use data **out of your control**, e.g. data from another system or depends on server's response, that may cause App crash. Recently I have met some crashes related to it.


# What can I do ?

Fix it! Of course but how? 
- The first straightway solution is to wrap these functions, such as objectAtIndex, we wrote the following function
>

    - (id)safeObjectAtIndex:(NSUInteger)index
    {	
    	if (index >= self.count)
    	{
    		return nil;
    	}
    	return [self objectAtIndex:index];
    }

Then each call objectAtIndex: could be replaced with code to our own safeObjectAtIndex:, but that would make for a ton of duplicated boilerplate code. 

- **Overriding with Category** would be another possibility. But according to Apple's document:
> Although the Objective-C language currently allows you to use a category to override methods the class inherits, or even methods declared in the class interface, you are strongly discouraged from doing so. A category is not a substitute for a subclass. There are several significant shortcomings to using a category to override methods:
A category cannot reliably override methods declared in another category of the same class.
This issue is of particular significance because many of the Cocoa classes are implemented using categories. A framework-defined method you try to override may itself have been implemented in a category, and so which implementation takes precedence is not defined.

- Fortunately, there is another way: **method swizzling** from a category.

## Why method swizzling ?

Objective-C messaging is dynamic, this means that when the runtime sends a message to that object, will always find the overridden method, no matter what you import.

## How to use

Import **YESafetyCollection.h** and **YESafetyCollection.m** directly into the project. That's all done ! Don't have to modify your code.


## Demo
Code would be crashed if I call in the traditional way
> 

    NSArray *array = @[@"a", @"b"];
    NSMutableArray *mutableArray = [@[@"aa", @"bb"] mutableCopy];
    
    // Object at index
    NSLog(@"%@", array[10]);
    NSLog(@"%@", mutableArray[100]);
    
    // add object
    [mutableArray addObject:nil];
    
    // Insert object
    [mutableArray insertObject:nil atIndex:0];
    [mutableArray insertObject:@"cc" atIndex:10];
    
    // Replace object
    [mutableArray replaceObjectAtIndex:0 withObject:nil];
    [mutableArray replaceObjectAtIndex:10 withObject:@"cc"];
    
    // Dictionary
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    
    [mutableDictionary setObject:nil forKey:@"1"];
    
    //Set
    NSSet *set = [NSSet setWithObjects:@0, @1, @2, @3, @4, @5, nil];
    NSMutableSet *mutableSet = [@[@0, @1, @2, @3, @4, @5] mutableCopy];
    
    // add object
    [mutableSet addObject:nil];

You would find crash file like this.

    *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[__NSArrayM insertObject:atIndex:]: object cannot be nil'
    *** First throw call stack:
    (0x182e6422c 0x194b300e4 0x182d4b160 0x1002b8778 0x1878f7d5c 0x187a16cf0 0x187a16940 0x187ade160 0x1879151ec 0x187addfb4 0x1879151ec 0x1878fe2c8 0x187addbec 0x1879151ec 0x1878fe2c8 0x187914b88 0x1878d3da8 0x182e1bff0 0x182e18f7c 0x182e1935c 0x182d44f74 0x18c79f6fc 0x187946d94 0x1002ed620 0x1951daa08)
    libc++abi.dylib: terminating with uncaught exception of type NSException

But if you use **YESafetyPin**, you will not get crash anymore and will find details information in log.
>
> [__NSArrayI objectAtIndex:] index {10} beyond bounds [0...1] ============= call stack ========== 
(
	0   Gamma                               0x00000001002ac074 safetyCollectionLogMessage + 224
	1   Gamma                               0x00000001002ac238 -[NSArray(YESafe) ye_objectAtIndexI:] + 276
	2   Gamma                               0x00000001002769c4 -[ContactsRootViewController viewWillAppear:] + 4420
…