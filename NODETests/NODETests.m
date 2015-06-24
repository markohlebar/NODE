//
//  NODETests.m
//  NODETests
//
//  Created by Marko Hlebar on 28/03/2015.
//  Copyright (c) 2015 Marko Hlebar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+NODE.h"

@interface TestObject : NSObject
@end

@implementation TestObject
@end

@interface NODETests : XCTestCase

@end

@implementation NODETests
{
    NSObject *_root;
}

- (void)setUp {
    [super setUp];

    _root = [NSObject new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    _root = nil;
}

- (void)testAddingAChild {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    XCTAssertEqualObjects(_root, child.node_parent, @"When a child is added, a parent should be assigned");
    XCTAssertEqualObjects([_root.node_children firstObject], child, @"When a child is added, a parent should have it's reference");
}

- (void)testAddingTheSameChildTwiceIsNotAllowed {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    [_root node_addChild:child];
    XCTAssertTrue(_root.node_children.count == 1, @"Should not add the same object to the array twice");
}

- (void)testAddingMultipleChildren {
    NSObject *child = [NSObject new];
    NSObject *child2 = [NSObject new];

    NSArray *children = @[child, child2];
    [_root node_addChildren:children];
    
    XCTAssertEqualObjects(_root.node_children, children, @"Children should match the passed children array");
}

- (void)testRemovingAChild {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    [_root node_removeChild:child];
    
    XCTAssertTrue(_root.node_children.count == 0, @"Should not contain children");
    XCTAssertNil(child.node_parent, @"Should not have a reference to it's parent after being removed");
}

- (void)testRemovingAllChildren {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    
    NSObject *child2 = [NSObject new];
    [_root node_addChild:child2];
    
    [_root node_removeAllChildren];
    
    XCTAssertTrue(_root.node_children.count == 0, @"Should not contain children");
    XCTAssertNil(child.node_parent, @"Should not have a reference to it's parent after being removed");
    
    XCTAssertTrue(_root.node_children.count == 0, @"Should not contain children");
    XCTAssertNil(child2.node_parent, @"Should not have a reference to it's parent after being removed");
}

- (void)testSettingMutableChildrenUsesTheMutableArrayThatIsSet {
    NSMutableArray *children = @[[NSObject new], [NSObject new]].mutableCopy;
    [_root node_setMutableChildren:children];
    
    XCTAssertEqualObjects(_root.node_children, children, @"The mutable children that are set should be used");
}

- (void)testRootOfRootIsRootItself {
    XCTAssertEqualObjects(_root.node_root, _root, @"The root of root is the root itself");
}

- (void)testRootOfAChildIsRoot {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    XCTAssertEqualObjects(child.node_root, _root, @"The root of a child is root");
}

- (void)testRootOfTwoGenerations {
    NSObject *grandchild = [NSObject new];
    NSObject *child = [NSObject new];
    [child node_addChild:grandchild];
    [_root node_addChild:child];
    XCTAssertEqualObjects(grandchild.node_root, _root, @"The root of a grandchild is root");
}

- (void)testAncestorsAreEmptyForRoot {
    XCTAssertEqualObjects(_root.node_ancestors, @[], @"Root's ancestors is an empty array.");
}

- (void)testAncestorsIsRootWhenRootHasAChild {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    XCTAssertEqualObjects(child.node_ancestors, @[_root], @"Child's ancestors has root.");
}

- (void)testIndexPathForRootIs0 {
    NSIndexPath *indexPath = [_root node_indexPath];
    XCTAssertTrue([indexPath indexAtPosition:0] == 0, @"IndexPath of root is 0");
}

- (void)testIndexPathForFirstChildIs0_0 {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    NSIndexPath *indexPath = [child node_indexPath];
    NSUInteger indexes[2];
    [indexPath getIndexes:indexes];
    
    XCTAssertTrue(indexes[0] == 0 && indexes[1] == 0, @"IndexPath of child is 0-0");
}

- (void)testIndexPathForSecondChildIs0_1 {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    
    NSObject *child2 = [NSObject new];
    [_root node_addChild:child2];
    
    NSIndexPath *indexPath = [child2 node_indexPath];
    NSUInteger indexes[2];
    [indexPath getIndexes:indexes];
    
    XCTAssertTrue(indexes[0] == 0 && indexes[1] == 1, @"IndexPath of child2 is 0-1");
}

- (void)testIndexPathComplexTree {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    
    NSObject *child2 = [NSObject new];
    [_root node_addChild:child2];
    
    NSObject *grandChild = [NSObject new];
    [child node_addChild:grandChild];
    
    NSObject *grandChild2 = [NSObject new];
    [child node_addChild:grandChild2];
    
    NSIndexPath *indexPath = [grandChild node_indexPath];
    NSUInteger indexes[3];
    [indexPath getIndexes:indexes];
    
    XCTAssertTrue(indexes[0] == 0 && indexes[1] == 0 && indexes[2] == 0, @"IndexPath of grandChild is 0-0-0");

    indexPath = [grandChild2 node_indexPath];
    [indexPath getIndexes:indexes];
    
    XCTAssertTrue(indexes[0] == 0 && indexes[1] == 0 && indexes[2] == 1, @"IndexPath of grandChild2 is 0-0-1");
}

- (void)testNodeAtIndexPath0IsRoot {
    NSObject *node = [_root node_nodeAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    XCTAssertEqual(node, _root, @"Node at index path 0 is root");
}

- (void)testNodeAtIndexPath0_0IsChild {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    NSIndexPath *indexPath = [child node_indexPath];
    NSObject *node = [_root node_nodeAtIndexPath:indexPath];
    XCTAssertEqual(node, child, @"Node at index path 0-0 is child");
}

- (void)testNodeAtIndexPathForSecondChildIs0_1 {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    
    NSObject *child2 = [NSObject new];
    [_root node_addChild:child2];
    
    NSIndexPath *indexPath = [child2 node_indexPath];
    NSObject *node = [_root node_nodeAtIndexPath:indexPath];

    XCTAssertEqual(node, child2, @"Node at index path 0-1 is child2");
}

- (void)testDebugDescription {
    NSObject *child = [NSObject new];
    [_root node_addChild:child];
    
    NSObject *child2 = [NSObject new];
    [_root node_addChild:child2];
    
    NSObject *grandChild = [NSObject new];
    [child node_addChild:grandChild];
    
    NSObject *grandChild2 = [NSObject new];
    [child node_addChild:grandChild2];
    
    NSLog(@"\n%@", [_root node_debugDescription]);
}

- (void)testPerformance {
    NSObject *child = [NSObject new];

    [self measureBlock:^{
        [_root node_addChild:child];
        [_root node_removeChild:child];
    }];
}

@end
