#import "TQNodeString.h"
#import "TQNode+Private.h"
#import "TQNodeBlock.h"
#import "TQProgram.h"

using namespace llvm;

@implementation TQNodeString
@synthesize value=_value;

+ (TQNodeString *)nodeWithString:(NSMutableString *)aStr
{
    TQNodeString *node = [self new];
    node.value = aStr;
    return [node autorelease];
}

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _embeddedValues = [NSMutableArray new];
    return self;
}

- (void)dealloc
{
    [_value release];
    [_embeddedValues release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<str@ \"%@\">", _value];
}
- (NSString *)toString
{
    return _value;
}

- (TQNode *)referencesNode:(TQNode *)aNode
{
    // All string refs must be unique since they are mutable
    TQNode *ref = [_embeddedValues tq_referencesNode:aNode];
    if(ref)
        return ref;
    return nil;
}

- (void)iterateChildNodes:(TQNodeIteratorBlock)aBlock
{
    for(TQNode *node in _embeddedValues) {
        aBlock(node);
    }
}

- (void)append:(NSString *)aStr
{
    [_value appendString:aStr];
}

- (BOOL)replaceChildNodesIdenticalTo:(TQNode *)aNodeToReplace with:(TQNode *)aNodeToInsert
{
    NSUInteger idx = [_embeddedValues indexOfObject:aNodeToReplace];
    if(idx == NSNotFound)
        return NO;
    [_embeddedValues replaceObjectAtIndex:idx withObject:aNodeToInsert];
    return YES;
}

- (llvm::Value *)generateCodeInProgram:(TQProgram *)aProgram
                                 block:(TQNodeBlock *)aBlock
                                  root:(TQNodeRootBlock *)aRoot
                                 error:(NSError **)aoErr
{
    Module *mod = aProgram.llModule;

    // Returns [NSMutableString stringWithUTF8String:_value]
    Value *klass    = mod->getOrInsertGlobal("OBJC_CLASS_$_NSMutableString", aProgram.llInt8Ty);
    Value *selector = [aProgram getSelector:@"stringWithUTF8String:" inBlock:aBlock root:aRoot];

    Value *strValue = [aProgram getGlobalStringPtr:_value inBlock:aBlock];
    strValue = aBlock.builder->CreateCall3(aProgram.objc_msgSend, klass, selector, strValue);

    // If there are embedded values we must create a string using strValue as its format
    if([_embeddedValues count] > 0) {
        Value *formatSelector = [aProgram getSelector:@"stringWithFormat:" inBlock:aBlock root:aRoot];
        std::vector<Value*> args;
        args.push_back(klass);
        args.push_back(formatSelector);
        args.push_back(strValue);
        for(TQNode *value in _embeddedValues) {
            args.push_back([value generateCodeInProgram:aProgram block:aBlock root:aRoot error:aoErr]);
        }
        strValue = aBlock.builder->CreateCall(aProgram.objc_msgSend, args);
        [self _attachDebugInformationToInstruction:strValue inProgram:aProgram block:aBlock root:aRoot];
    }
    return strValue;
}
@end

@implementation TQNodeConstString
+ (TQNodeConstString *)nodeWithString:(NSString *)aStr
{
    return (TQNodeConstString *)[super nodeWithString:[[aStr mutableCopy] autorelease]];
}

- (llvm::Value *)generateCodeInProgram:(TQProgram *)aProgram
                                 block:(TQNodeBlock *)aBlock
                                  root:(TQNodeRootBlock *)aRoot
                                 error:(NSError **)aoErr
{
    if(!aProgram.useAOTCompilation) {
        NSString *str = [[NSString stringWithString:self.value] retain];
        return ConstantExpr::getIntToPtr(ConstantInt::get(aProgram.llLongTy, (uintptr_t)str), aProgram.llInt8PtrTy);
    }
    // Todo: make this use a NSConstantString
    Module *mod = aProgram.llModule;

    NSString *globalName = [NSString stringWithFormat:@"TQConstNSStr_%ld", (unsigned long)[self.value hash]];

    Value *str = mod->getGlobalVariable([globalName UTF8String], true);
    if(!str) {
         Function *rootFunction = aRoot.function;
        IRBuilder<> rootBuilder(&rootFunction->getEntryBlock(), rootFunction->getEntryBlock().begin());

        Value *klass    = mod->getOrInsertGlobal("OBJC_CLASS_$_NSString", aProgram.llInt8Ty);
        Value *selector = [aProgram getSelector:@"stringWithUTF8String:" withBuilder:&rootBuilder root:aRoot];

        Value *result = rootBuilder.CreateCall3(aProgram.objc_msgSend, klass, selector, [aProgram getGlobalStringPtr:self.value withBuilder:&rootBuilder]);
        result = rootBuilder.CreateCall(aProgram.objc_retain, result);

        str = new GlobalVariable(*mod, aProgram.llInt8PtrTy, false, GlobalVariable::PrivateLinkage,
                                 ConstantPointerNull::get(aProgram.llInt8PtrTy), [globalName UTF8String]);

        rootBuilder.CreateStore(result, str);

    }
    return aBlock.builder->CreateLoad(str);
}
@end
