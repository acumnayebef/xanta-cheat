#import "hooks.h"
#import "il2cpp_loader.h"
#import "dobby.h"
#import <os/log.h>

bool g_BoolInfMoney = false;
bool g_BoolFreeUpgrades = false;
bool g_BoolFreeIAP = false;

// --- 1. Бесконечные деньги (CurrencyBase) ---
static void (*orig_SetBalance)(void *self, int newBalance) = NULL;
static void hook_SetBalance(void *self, int newBalance) {
    if (g_BoolInfMoney) {
        newBalance = 99999999;
    }
    if (orig_SetBalance) orig_SetBalance(self, newBalance);
}

// --- 2. Бесплатные апгрейды (VehicleUpgraderAndTuner) ---
static void (*orig_SetEngine)(void *self, int level) = NULL;
static void hook_SetEngine(void *self, int level) {
    if (g_BoolFreeUpgrades) {
        level = 5; // Максимальный уровень
    }
    if (orig_SetEngine) orig_SetEngine(self, level);
}

// --- Установка хуков ---
void install_hooks(void) {
    os_log(OS_LOG_DEFAULT, "[xantapers] Starting hook installation...");
    
    if (!il2cpp_loader_init()) {
        os_log(OS_LOG_DEFAULT, "[xantapers] Failed to init il2cpp loader!");
        return;
    }

    // Хук на валюту
    Il2CppClass *currencyClass = il2cpp_find_class("TOJGAMES.Economy", "CurrencyBase");
    if (currencyClass) {
        void *addr = il2cpp_method_addr(currencyClass, "SetBalance", 1);
        if (addr) {
            DobbyHook(addr, (void *)hook_SetBalance, (void **)&orig_SetBalance);
            os_log(OS_LOG_DEFAULT, "[xantapers] Money hook installed OK");
        } else {
            os_log(OS_LOG_DEFAULT, "[xantapers] SetBalance method not found!");
        }
    } else {
        os_log(OS_LOG_DEFAULT, "[xantapers] CurrencyBase class not found!");
    }

    // Хук на апгрейды
    Il2CppClass *upgraderClass = il2cpp_find_class("", "VehicleUpgraderAndTuner");
    if (upgraderClass) {
        void *addr = il2cpp_method_addr(upgraderClass, "SetEngine", 1);
        if (addr) {
            DobbyHook(addr, (void *)hook_SetEngine, (void **)&orig_SetEngine);
            os_log(OS_LOG_DEFAULT, "[xantapers] Upgrade hook installed OK");
        } else {
            os_log(OS_LOG_DEFAULT, "[xantapers] SetEngine method not found!");
        }
    } else {
        os_log(OS_LOG_DEFAULT, "[xantapers] VehicleUpgraderAndTuner class not found!");
    }
    
    os_log(OS_LOG_DEFAULT, "[xantapers] Hook installation finished.");
}