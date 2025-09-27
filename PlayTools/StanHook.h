//# coding by unknown0xff

#ifndef StanHook_h
#define StanHook_h

#import <Foundation/Foundation.h>
#import <objc/objc.h>
#import <objc/objc-api.h>
#import <objc/runtime.h>

#define __Xclass(x, y) \
@interface ___##x: y @end\
@interface __##x: ___##x @end \
@implementation ___##x \
+ (__unsafe_unretained id)xself { \
    return stanhook_get_xself(self, object_getClass(__##x.class)); \
} \
- (__unsafe_unretained id)xself { \
    return stanhook_get_xself(self, __##x.class); \
} \
+ (void)load { stanhook_apply(#x, "__"#x, "___"#x); } \
@end \
@implementation __##x \

#define Xclass(x) __Xclass(x, NSObject)
#define Xself ((__typeof(self))super.xself)
#define Xend @end

#define _asm_func __attribute__((naked))
#define _unused __attribute__((unused))

#define XinstancetypeInit(x) CFRetain((__bridge CFTypeRef)x)

static Class stanhook_xself_class;
static Class stanhook_xself_meta_class;

typedef struct {
    __unsafe_unretained id receiver;
    __unsafe_unretained Class current_class;
} objc_super_t;

__thread static objc_super_t thread_objc_super;

_unused static void *
get_thread_objc_super(void) {
    return &thread_objc_super;
}

_asm_func static void
shellcode_handler(void) {
__asm__ __volatile__ (
    "sub sp, sp, #(16 * 10)\n"
    "stp x29, x30, [sp, #(16 * 8)]\n"

    "stp x16, x1, [sp, #(16*0)]\n"
    "stp x2, x3, [sp, #(16*1)]\n"
    "stp x4, x5, [sp, #(16*2)]\n"
    "stp x6, x7, [sp, #(16*3)]\n"
    
    "mov x0, %0\n"
    "blr x0\n"

    "ldp x16, x1, [sp, #(16*0)]\n"
    "ldp x2, x3, [sp, #(16*1)]\n"
    "ldp x4, x5, [sp, #(16*2)]\n"
    "ldp x6, x7, [sp, #(16*3)]\n"

    "ldp x29, x30, [sp,#(16 * 8)]\n"
    "add sp, sp, #(16 * 10)\n"
    
    "b _objc_msgSendSuper2\n"
    :
    :"r"(get_thread_objc_super)
    :"x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15", "x16", "x17"
);
}

_unused static id
stanhook_get_xself(__unsafe_unretained id self, __unsafe_unretained Class cls) {
    thread_objc_super.receiver = self;
    thread_objc_super.current_class = cls;
    return stanhook_xself_class;
}

_unused static void
add_method(Class cls, Class clst, Method new_m) {
    const char* typeEncoding = method_getTypeEncoding(new_m);
    IMP new_imp = method_getImplementation(new_m);
    SEL sel = method_getName(new_m);
    
    Class superClass = cls;
    Method m = nil;
    
    while (superClass && !m) {
        superClass = class_getSuperclass(superClass);
        m = class_getInstanceMethod(superClass, sel);
    }
    
    if (m) {
        IMP imp = method_getImplementation(m);
        class_addMethod(stanhook_xself_meta_class, sel, shellcode_handler, typeEncoding);
        class_addMethod(clst, sel, imp, typeEncoding);
    }
    
    class_addMethod(cls, sel, new_imp, typeEncoding);
}

_unused static void
hook_method(Class cls, Class clst, Method m, Method new_m) {
    IMP imp = method_getImplementation(m);
    IMP new_imp = method_getImplementation(new_m);
    SEL sel = method_getName(m);
    
    const char* typeEncoding = method_getTypeEncoding(m);
    
    class_addMethod(stanhook_xself_meta_class, sel, shellcode_handler, typeEncoding);
    class_addMethod(clst, sel, imp, typeEncoding);
    
    method_setImplementation(m, new_imp);
}

_unused static void
stanhook_hook_methods(Class clsa, Class clsb, Class clst) {
    unsigned int count = 0;
    Method* mlist = class_copyMethodList(clsb, &count);
    
    for (unsigned int i = 0; i <count; ++i) {
        Method mb = mlist[i];
        SEL sel = method_getName(mb);
        Method ma = class_getInstanceMethod(clsa, sel);
        
        if (ma) {
            hook_method(clsa, clst, ma, mb);
        } else {
            add_method(clsa, clst, mb);
        }
    }
}

_unused static void
stanhook_apply(const char* classa, const char* classb, const char* classt) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stanhook_xself_class = objc_allocateClassPair(NSObject.class, "_xcls_", 0);
        stanhook_xself_meta_class = object_getClass(stanhook_xself_class);
    });
    
    Class clsa = objc_getClass(classa);
    Class clsb = objc_getClass(classb);
    Class clst = objc_getClass(classt);
    
    stanhook_hook_methods(clsa, clsb, clst);
    
    clsa = object_getClass(clsa);
    clsb = object_getClass(clsb);
    clst = object_getClass(clst);
    stanhook_hook_methods(clsa, clsb, clst);
}

#endif /* StanHook_h */
