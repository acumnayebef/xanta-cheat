#pragma once
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void* Il2CppDomain;
typedef void* Il2CppAssembly;
typedef void* Il2CppImage;
typedef void* Il2CppClass;
typedef void* Il2CppMethodInfo;
typedef void* Il2CppObject;
typedef void* Il2CppString;

extern Il2CppDomain (*il2cpp_domain_get)(void);
extern Il2CppAssembly* (*il2cpp_domain_assembly_open)(Il2CppDomain, const char*);
extern Il2CppImage* (*il2cpp_assembly_get_image)(Il2CppAssembly*);
extern Il2CppClass* (*il2cpp_class_from_name)(const Il2CppImage*, const char*, const char*);
extern Il2CppMethodInfo* (*il2cpp_class_get_method_from_name)(Il2CppClass*, const char*, int);
extern void* (*il2cpp_thread_attach)(Il2CppDomain);

bool il2cpp_loader_init(void);
Il2CppClass* il2cpp_find_class(const char *ns, const char *name);
void* il2cpp_method_addr(Il2CppClass *klass, const char *name, int argc);

#ifdef __cplusplus
}
#endif