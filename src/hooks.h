#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#import <Foundation/Foundation.h>

// Только объявления (extern), без инициализации!
extern bool g_BoolInfMoney;
extern bool g_BoolFreeUpgrades;
extern bool g_BoolFreeIAP;

void add_log(NSString *format, ...);
void install_hooks(void);

#ifdef __cplusplus
}
#endif