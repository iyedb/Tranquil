#import "TQFFIType.h"
#import "TQBoxedObject.h"

@implementation TQFFIType
+ (ffi_type *)scalarTypeToFFIType:(const char *)aType
{
    switch(*aType) {
        case _C_ID:
        case _C_CLASS:
        case _C_SEL:
        case _C_PTR:
        case _C_CHARPTR:
            return &ffi_type_pointer;
        case _C_DBL:
            return &ffi_type_double;
        case _C_FLT:
            return &ffi_type_float;
        case _C_INT:
            return &ffi_type_sint;
        case _C_SHT:
            return &ffi_type_sshort;
        case _C_BOOL:
            return &ffi_type_uchar;
        case _C_LNG:
            return &ffi_type_slong;
        case _C_LNG_LNG:
            return &ffi_type_sint64;
        case _C_UINT:
            return &ffi_type_uint;
        case _C_USHT:
            return &ffi_type_ushort;
        case _C_ULNG:
            return &ffi_type_ulong;
        case _C_ULNG_LNG:
            return &ffi_type_uint64;
        case _C_VOID:
            return &ffi_type_void;
        default:
            NSLog(@"Unsupported scalar type %c!", *aType);
            return NULL;
    }
}

+ (TQFFIType *)typeWithEncoding:(const char *)aEncoding
{
    return [self typeWithEncoding:aEncoding nextType:NULL];
}
+ (TQFFIType *)typeWithEncoding:(const char *)aEncoding nextType:(const char **)aoNextType
{
    return [[[self alloc] initWithEncoding:aEncoding nextType:aoNextType] autorelease];
}

- (id)initWithEncoding:(const char *)aEncoding nextType:(const char **)aoNextType
{
    if(!(self = [super init]))
        return nil;
    _referencedTypes = [[NSMutableArray alloc] init];
    _encoding = aEncoding;
    _size = 0;

    const char *next = NSGetSizeAndAlignment(_encoding, &_size, NULL);
    if(aoNextType)
        *aoNextType = next;

    if([TQBoxedObject typeIsScalar:_encoding])
        _ffiType = [TQFFIType scalarTypeToFFIType:_encoding];
    else if(*_encoding == _C_STRUCT_B) {
        ffi_type type;
        _ffiType = (ffi_type*)malloc(sizeof(ffi_type));
        _ffiType->type = FFI_TYPE_STRUCT;
        _ffiType->size = _ffiType->alignment= 0;
        int numFields = 0;
        const char *fieldEncoding = strstr(_encoding, "=") + 1;
        if(*fieldEncoding != _C_STRUCT_E) {
            const char *currField = fieldEncoding;
            do {
                ++numFields;
            } while((currField = NSGetSizeAndAlignment(currField, NULL, NULL)) && *currField != _C_STRUCT_E);
        }
        _ffiType->size = type.alignment = 0;
        _ffiType->elements = (ffi_type **)malloc(sizeof(ffi_type*) * numFields + 1);

        for(int i = 0; i < numFields; i++) {
            TQFFIType *fieldType = [TQFFIType typeWithEncoding:fieldEncoding];
            [_referencedTypes addObject:fieldType];
            _ffiType->elements[i] = fieldType.ffiType;
            fieldEncoding = NSGetSizeAndAlignment(fieldEncoding, NULL, NULL);
        }
        _ffiType->elements[numFields] = NULL;
    } else
        // TODO: handle unions by returning a type matching the largest field?
        assert(NO);
    return self;
}

- (void)dealloc
{
    if(![TQBoxedObject typeIsScalar:_encoding]) {
        free(_ffiType->elements);
        free(_ffiType);
    }
    [_referencedTypes release];
    [super dealloc];
}
@end