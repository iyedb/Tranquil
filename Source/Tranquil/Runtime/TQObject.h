// The root class of Tranquil which classes created using Tranquil inherit from by default
// Subclasses of TQObject should never accept or return anything but objects from their methods

// Boolean returns from TQObject methods return nil on success and any object on success (Convention is TQNumberTrue=1.0)
#import <Foundation/Foundation.h>

@class TQNumber;

@interface TQObject : NSObject
+ (id)addMethod:(NSString *)aSel withBlock:(id)aBlock replaceExisting:(id)shouldReplace;
+ (id)addMethod:(NSString *)aSel withBlock:(id)aBlock;
+ (id)accessor:(NSString *)aPropName initialValue:(id<NSCopying>)aInitial;
+ (id)accessor:(NSString *)aPropName;
+ (NSArray *)classMethods;
+ (NSArray *)instanceMethods;
- (NSArray *)methods;
- (id)respondsTo:(NSString *)aSelector;
- (id)isa:(Class)aClass;
- (id)isNil;
- (id)isIdenticalTo:(id)obj;
- (id)isEqualTo:(id)b;
- (id)notEqualTo:(id)b;
- (id)isLesserThan:(id)b;
- (id)isGreaterThan:(id)b;
- (id)isLesserOrEqualTo:(id)b;
- (id)isGreaterOrEqualTo:(id)b;

- (id)perform:(NSString *)aSelector withArguments:(NSArray *)aArguments;
- (id)perform:(NSString *)aSelector;
- (id)perform:(NSString *)aSelector :(id)a1;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6 :(id)a7;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6 :(id)a7 :(id)a8;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6 :(id)a7 :(id)a8 :(id)a9;
@end
