#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#import <Foundation/Foundation.h>

// Глобальные флаги для меню
extern bool g_BoolInfMoney;
extern bool g_BoolFreeUpgrades;
extern bool g_BoolFreeIAP;

// Функция для логирования прямо в меню
void add_log(NSString *format, ...);

// Установка хуков
void install_hooks(void);

#ifdef __cplusplus
}
#endif