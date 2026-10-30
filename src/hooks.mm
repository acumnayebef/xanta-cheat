#import "hooks.h"
#import "il2cpp_loader.h"
#import "dobby.h"
#import <os/log.h>

bool g_BoolInfMoney = false;
bool g_BoolFreeUpgrades = false;
bool g_BoolFreeIAP = false;

// --- 1. Валюта (Spend и Earn) ---
static void (*orig_Spend)(void *self, int amount) = NULL;
static void hook_Spend(void *self, int amount) {
    if (g_BoolInfMoney) {
        return; // Просто выходим, деньги не списываются
    }
    if (orig_Spend) orig_Spend(self, amount);
}

static void (*orig_Earn)(void *self, int amount) = NULL;
static void hook_Earn(void *self, int amount) {
    if (g_BoolInfMoney) {
        amount = 999999; // Начисляем много
    }
    if (orig_Earn) orig_Earn(self, amount);
}

// --- 2. Бесплатные апгрейды (VehicleUpgraderAndTuner) ---
static void (*orig_SetEngine)(void *self, int level) = NULL;
static void hook_SetEngine(void *self, int level) {
    if (g_BoolFreeUpgrades) {
        level = 5;
    }
    if (orig_SetEngine) orig_SetEngine(self, level);
}

// --- Установка хуков ---
void install_hooks(void) {
    os_log(OS_LOG_DEFAULT, "[xantapers] Starting hook installation...");
    
    if (!il2cpp_loader_init()) return;

    // Хук на валюту (CurrencyBase)
    Il2CppClass *currencyClass = il2cpp_find_class("TOJGAMES.Economy", "CurrencyBase");
    if (currencyClass) {
        void *addrSpend = il2cpp_method_addr(currencyClass, "Spend", 1);
        if (addrSpend) {
            DobbyHook(addrSpend, (void *)hook_Spend, (void **)&orig_Spend);
            os_log(OS_LOG_DEFAULT, "[xantapers] Spend hook installed OK");
        }
        void *addrEarn = il2cpp_method_addr(currencyClass, "Earn", 1);
        if (addrEarn) {
            DobbyHook(addrEarn, (void *)hook_Earn, (void **)&orig_Earn);
            os_log(OS_LOG_DEFAULT, "[xantapers] Earn hook installed OK");
        }
    }

    // Хук на апгрейды
    Il2CppClass *upgraderClass = il2cpp_find_class("", "VehicleUpgraderAndTuner");
    if (upgraderClass) {
        void *addr = il2cpp_method_addr(upgraderClass, "SetEngine", 1);
        if (addr) {
            DobbyHook(addr, (void *)hook_SetEngine, (void **)&orig_SetEngine);
            os_log(OS_LOG_DEFAULT, "[xantapers] Upgrade hook installed OK");
        }
    }
    
    os_log(OS_LOG_DEFAULT, "[xantapers] Hook installation finished.");
}