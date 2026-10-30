#import "hooks.h"
#import "il2cpp_loader.h"
#import "dobby.h"

bool g_BoolInfMoney = false;
bool g_BoolFreeUpgrades = false;
bool g_BoolFreeIAP = false;

// --- 1. Валюта (Spend и Earn) ---
static void (*orig_Spend)(void *self, int amount) = NULL;
static void hook_Spend(void *self, int amount) {
    if (g_BoolInfMoney) {
        return; // Деньги не списываются
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

// --- 2. Апгрейды (SetEngine) ---
static void (*orig_SetEngine)(void *self, int level) = NULL;
static void hook_SetEngine(void *self, int level) {
    if (g_BoolFreeUpgrades) {
        level = 5;
    }
    if (orig_SetEngine) orig_SetEngine(self, level);
}

// --- 3. IAP (Покупки) ---
// Метод принимает Il2CppString* (productID), возвращает bool
static bool (*orig_IsProductPurchased)(void *self, void *productID) = NULL;
static bool hook_IsProductPurchased(void *self, void *productID) {
    if (g_BoolFreeIAP) {
        return true; // Всегда "куплено"
    }
    if (orig_IsProductPurchased) {
        return orig_IsProductPurchased(self, productID);
    }
    return false;
}

// --- Установка хуков ---
void install_hooks(void) {
    add_log(@"Инициализация il2cpp...");
    
    if (!il2cpp_loader_init()) {
        add_log(@"ОШИБКА: il2cpp не инициализирован!");
        return;
    }

    // 1. Валюта (SilverCurrency)
    Il2CppClass *silverClass = il2cpp_find_class("TOJGAMES.Economy", "SilverCurrency");
    if (silverClass) {
        void *addrSpend = il2cpp_method_addr(silverClass, "Spend", 1);
        if (addrSpend) {
            DobbyHook(addrSpend, (void *)hook_Spend, (void **)&orig_Spend);
            add_log(@"SilverCurrency.Spend: OK");
        } else add_log(@"SilverCurrency.Spend: НЕ НАЙДЕН");
        
        void *addrEarn = il2cpp_method_addr(silverClass, "Earn", 1);
        if (addrEarn) {
            DobbyHook(addrEarn, (void *)hook_Earn, (void **)&orig_Earn);
            add_log(@"SilverCurrency.Earn: OK");
        } else add_log(@"SilverCurrency.Earn: НЕ НАЙДЕН");
    } else {
        add_log(@"SilverCurrency: КЛАСС НЕ НАЙДЕН");
    }

    // 2. Апгрейды (VehicleUpgraderAndTuner)
    Il2CppClass *upgraderClass = il2cpp_find_class("", "VehicleUpgraderAndTuner");
    if (upgraderClass) {
        void *addr = il2cpp_method_addr(upgraderClass, "SetEngine", 1);
        if (addr) {
            DobbyHook(addr, (void *)hook_SetEngine, (void **)&orig_SetEngine);
            add_log(@"VehicleUpgraderAndTuner.SetEngine: OK");
        } else add_log(@"SetEngine: НЕ НАЙДЕН");
    } else {
        add_log(@"VehicleUpgraderAndTuner: КЛАСС НЕ НАЙДЕН");
    }

    // 3. IAP (IAPManager)
    Il2CppClass *iapClass = il2cpp_find_class("TOJGAMES.Monetization", "IAPManager");
    if (iapClass) {
        void *addr = il2cpp_method_addr(iapClass, "IsProductPurchased", 1);
        if (addr) {
            DobbyHook(addr, (void *)hook_IsProductPurchased, (void **)&orig_IsProductPurchased);
            add_log(@"IAPManager.IsProductPurchased: OK");
        } else add_log(@"IsProductPurchased: НЕ НАЙДЕН");
    } else {
        add_log(@"IAPManager: КЛАСС НЕ НАЙДЕН");
    }
    
    add_log(@"Установка хуков завершена.");
}