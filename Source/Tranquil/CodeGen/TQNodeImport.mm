#import "TQNodeImport.h"
#import "../TQProgram.h"
#import "../TQProgram+Private.h"

using namespace llvm;

@implementation TQNodeImport
@synthesize path=_path;

+ (TQNodeImport *)nodeWithPath:(NSString *)aPath
{
    TQNodeImport *ret = (TQNodeImport *)[self node];
    ret->_path = [aPath retain];
    return ret;
}
- (void)dealloc
{
    [_path release];
    [super dealloc];
}

- (id)referencesNode:(TQNode *)aNode
{
    if([aNode isEqual:self])
        return self;
    return nil;
}


- (void)iterateChildNodes:(TQNodeIteratorBlock)aBlock
{
    // No subnodes
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<import: %@>", _path];
}

- (llvm::Value *)generateCodeInProgram:(TQProgram *)aProgram
                                 block:(TQNodeBlock *)aBlock
                                  root:(TQNodeRootBlock *)aRoot
                                 error:(NSError **)aoErr
{
    NSString *path = [aProgram _resolveImportPath:_path];
    if(!path)
        return NULL;
    if([[path pathExtension] isEqualToString:@"h"]) {
        [aProgram.objcParser parseHeader:path];
        return NULL;
    } else {
        TQNodeRootBlock *importedRoot = [aProgram _rootFromFile:path error:aoErr];
        Value *rootFun = [importedRoot generateCodeInProgram:aProgram block:aBlock root:importedRoot error:aoErr];
        return aBlock.builder->CreateCall(rootFun);
    }
}
@end