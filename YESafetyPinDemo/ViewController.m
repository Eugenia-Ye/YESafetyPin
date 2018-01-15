//
//  ViewController.m
//  YESafetyPinDemo
//
//  Created by Eugenia Ye on 18/06/2017.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSArray *array = @[@"a", @"b"];
    NSMutableArray *mutableArray = [@[@"aa", @"bb"] mutableCopy];
    
    // Object at index
    NSLog(@"%@", array[10]);
    NSLog(@"%@", mutableArray[100]);
    
    // add object
    NSString *nilString;
    [mutableArray addObject:nilString];
    
    // Insert object
    [mutableArray insertObject:nilString atIndex:0];
    [mutableArray insertObject:@"cc" atIndex:10];
    
    // Replace object
    [mutableArray replaceObjectAtIndex:0 withObject:nilString];
    [mutableArray replaceObjectAtIndex:10 withObject:@"cc"];
    
    // Dictionary
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    mutableDictionary[nilString] = @"1";
    mutableDictionary[@"1"] = nilString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
