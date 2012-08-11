#import "TQNodeNil.h"
#import "../TQProgram.h"

using namespace llvm;

@implementation TQNodeNil

+ (TQNodeNil *)node
{
    return (TQNodeNil *)[super node];
}

- (id)referencesNode:(TQNode *)aNode
{
    return nil;
}

- (void)iterateChildNodes:(TQNodeIteratorBlock)aBlock
{
    // Nothing to iterate
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<nil>"];
}

- (llvm::Value *)generateCodeInProgram:(TQProgram *)aProgram
                                 block:(TQNodeBlock *)aBlock
                                 error:(NSError **)aoError
{
    return ConstantPointerNull::get(aProgram.llInt8PtrTy);
}
@end
