#import "il2cpp_loader.h"
#import <dlfcn.h>
#import <os/log.h>

Il2CppDomain (*il2cpp_domain_get)(void) = NULL;
Il2CppAssembly* (*il2cpp_domain_assembly_open)(Il2CppDomain, const char*) = NULL;
Il2CppImage* (*il2cpp_assembly_get_image)(Il2CppAssembly*) = NULL;
Il2CppClass* (*il2cpp_class_from_name)(const Il2CppImage*, const char*, const char*) = NULL;
Il2CppMethodInfo* (*il2cpp_class_get_method_from_name)(Il2CppClass*, const char*, int) = NULL;
void* (*il2cpp_method_get_pointer)(const Il2CppMethodInfo*) = NULL;
void* (*il2cpp_thread_attach)(Il2CppDomain) = NULL;

// ИСПРАВЛЕНИЕ: добавили il2cpp_##name в макрос, чтобы он искал правильные переменные
#define RESOLVE(name) do { \
    *(void **)(&il2cpp_##name) = dlsym(RTLD_DEFAULT, "il2cpp_" #name); \
    if (!il2cpp_##name) { os_log(OS_LOG_DEFAULT, "[xantapers] missing: il2cpp_%s", #name); return false; } \
} while (0)

bool il2cpp_loader_init(void) {
    void *h = dlopen("UnityFramework", RTLD_NOW | RTLD_GLOBAL);
    if (!h) h = dlopen("@executable_path/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW | RTLD_GLOBAL);
    if (!h) return false;

    RESOLVE(domain_get);
    RESOLVE(domain_assembly_open);
    RESOLVE(assembly_get_image);
    RESOLVE(class_from_name);
    RESOLVE(class_get_method_from_name);
    RESOLVE(method_get_pointer);
    RESOLVE(thread_attach);

    os_log(OS_LOG_DEFAULT, "[xantapers] il2cpp initialized OK");
    return true;
}

Il2CppClass* il2cpp_find_class(const char *ns, const char *name) {
    static Il2CppImage *img = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        Il2CppDomain d = il2cpp_domain_get(); // ИСПРАВЛЕНИЕ: убрали *
        Il2CppAssembly *a = il2cpp_domain_assembly_open(d, "Assembly-CSharp");
        if (a) img = il2cpp_assembly_get_image(a);
    });
    return img ? il2cpp_class_from_name(img, ns, name) : NULL;
}

void* il2cpp_method_addr(Il2CppClass *klass, const char *name, int argc) {
    if (!klass) return NULL;
    Il2CppMethodInfo *m = il2cpp_class_get_method_from_name(klass, name, argc);
    return m ? il2cpp_method_get_pointer(m) : NULL;
}