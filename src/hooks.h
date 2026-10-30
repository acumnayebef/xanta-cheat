#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

// Глобальные флаги (включаются/выключаются в меню)
extern bool g_BoolInfMoney;
extern bool g_BoolFreeUpgrades;
extern bool g_BoolFreeIAP;

void install_hooks(void);

#ifdef __cplusplus
}
#endif