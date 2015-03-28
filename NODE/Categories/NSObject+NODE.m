//
//  NSObject+NODE.m
//  NODE
//
//  Created by Marko Hlebar on 28/03/2015.
//  Copyright (c) 2015 Marko Hlebar. All rights reserved.
//

#import "NSObject+NODE.h"
#import <objc/runtime.h>

@implementation NSObject (NODE)

#pragma mark - Parent-Child operations

- (void)node_addChild:(id)node {
    if (![self.nod_mutableChildren containsObject:node]) {
        [self.nod_mutableChildren addObject:node];
        [node setNode_parent:self];
    }
}

- (void)node_removeChild:(id)node {
    [self.nod_mutableChildren removeObject:node];
    [node setNode_parent:nil];
}

- (void)node_removeAllChildren {
    [self.nod_mutableChildren makeObjectsPerformSelector:@selector(setNode_parent:)
                                              withObject:nil];
    [self.nod_mutableChildren removeAllObjects];
}

- (id)node_root {
    NSObject *parent = self;
    while (parent.node_parent) {
        parent = parent.node_parent;
    }
    return parent;
}

- (NSArray *)node_ancestors {
    NSMutableArray *ancestors = [NSMutableArray new];
    NSObject *parent = self;
    while (parent.node_parent) {
        [ancestors addObject:parent.node_parent];
        parent = parent.node_parent;
    }
    return ancestors.copy;
}

- (id)node_parent {
    return objc_getAssociatedObject(self, @selector(node_parent));
}

- (void)setNode_parent:(id)parent {
    objc_setAssociatedObject(self, @selector(node_parent), parent, OBJC_ASSOCIATION_ASSIGN);
}

- (NSArray *)node_children {
    return self.nod_mutableChildren.copy;
}

#pragma mark - Index Paths

- (NSIndexPath *)node_indexPath {
    NSUInteger *indexes = self.node_createIndexes;
    NSUInteger length = self.node_ancestors.count + 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
                                                        length:length];
    free(indexes);
    return indexPath;
}

- (id)node_nodeAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Private

- (NSUInteger *)node_createIndexes {
    NSUInteger depth = self.node_ancestors.count + 1;
    NSUInteger *indexes = calloc(depth, sizeof(NSUInteger));
    
    __block NSObject *child = self;
    NSArray *ancestors = self.node_ancestors;
    [ancestors enumerateObjectsUsingBlock:^(NSObject *object, NSUInteger index, BOOL *stop) {
        NSUInteger childIndex = [object.node_children indexOfObject:child];
        child = object;
        indexes[ancestors.count - index] = childIndex;
    }];
    
    return indexes;
}

- (NSMutableArray *)nod_mutableChildren {
    NSMutableArray *children = objc_getAssociatedObject(self, @selector(nod_mutableChildren));
    if (!children) {
        children = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(nod_mutableChildren), children, OBJC_ASSOCIATION_RETAIN);
    }
    return children;
}

@end
