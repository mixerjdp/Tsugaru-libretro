# Plan de Implementación: Mapeo de Controles y Teclado en Libretro

## Estado Actual

### Controles (Gamepad)
**✓ YA IMPLEMENTADO:**
- Los 2 controles están mapeados en `src/libretro/libretro.cpp`
- Puerto 0 y Puerto 1 definidos en `input_descriptors`
- Mapeo básico: D-Pad (arriba/abajo/izq/der), A, B, X, Y, L, R, Start, Select
- Hay opciones de core para `tsugaru_port0_type` y `tsugaru_port1_type`

**✗ FALTA:**
- Descriptores dinámicos según el tipo de puerto elegido
- Soporte real para todos los tipos del standalone: `CYBERSTICK`, `LIBBLERABBLE`, `MARTYPAD`
- Mejor mapeo para mouse/analógico si se quiere exponer en RetroArch

### Teclado
**✓ YA IMPLEMENTADO:**
- Callback de teclado registrado en `retro_init()`
- Mapeo `RETROK_*` -> teclas FM Towns en `src/libretro/libretro.cpp`
- F1-F12, cursores, numpad y caracteres base ya llegan al emulador

**✗ FALTA / LIMITACIÓN:**
- RetroArch puede capturar `F1` como hotkey de frontend; eso no siempre llega al core
- Falta documentar o remapear hotkeys conflictivos si se quiere usar `F1` dentro del juego

---

## Tipos de Controles FM Towns (del standalone)

Del archivo `townsdef.h` y `gameport.h`:

### Tipos de Dispositivo (Device Types):
1. **NONE** - Sin dispositivo
2. **MOUSE** - Ratón
3. **GAMEPAD** - Gamepad estándar (2 botones)
4. **CYBERSTICK** - Joystick analógico CyberStick
5. **CAPCOMCPSF** - Control Capcom CPS Fighter (6 botones)
6. **GAMEPAD_6BTN** - Gamepad de 6 botones
7. **LIBBLERABBLE** - Gamepad especial Libble Rabble
8. **MARTYPAD** - Gamepad FM Towns Marty

### Tipos de Emulación (Emulation Types):
```cpp
TOWNS_GAMEPORTEMU_NONE
TOWNS_GAMEPORTEMU_MOUSE
TOWNS_GAMEPORTEMU_KEYBOARD
TOWNS_GAMEPORTEMU_PHYSICAL0-7        // Gamepad físico 0-7
TOWNS_GAMEPORTEMU_ANALOG0-7          // Joystick analógico 0-7
TOWNS_GAMEPORTEMU_PHYSICAL0-7_AS_CYBERSTICK
TOWNS_GAMEPORTEMU_MOUSE_BY_KEY
TOWNS_GAMEPORTEMU_MOUSE_BY_NUMPAD
TOWNS_GAMEPORTEMU_MOUSE_BY_PHYSICAL0-3
TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL0-3
TOWNS_GAMEPORTEMU_6BTN_BY_PHYSICAL0-3
TOWNS_GAMEPORTEMU_LIBBLERABBLE_BY_PHYSICAL0-3
```

---

## Plan de Implementación

### FASE 1: Opciones de Core para Tipo de Control

**Archivo:** `src/libretro/libretro.cpp`

**1.1. Agregar variables de configuración:**
```cpp
static const retro_variable variables[] = {
    { "tsugaru_model", "FM Towns Model; auto|MODEL2|2F|20F|UX|HR|MX|MARTY" },
    { "tsugaru_ram_mb", "RAM Size; 6|4|8|10|12|16" },
    { "tsugaru_mouse_mode", "Mouse Mode; relative|integrated" },
    
    // NUEVAS OPCIONES:
    { "tsugaru_port0_type", "Port 0 Device; gamepad|mouse|cyberstick|6button|capcom|libblerabble|martypad|none" },
    { "tsugaru_port1_type", "Port 1 Device; mouse|gamepad|cyberstick|6button|capcom|libblerabble|martypad|none" },
    
    { nullptr, nullptr },
};
```

**1.2. Función para convertir string a tipo de emulación:**
```cpp
unsigned int StringToGamePortEmu(const std::string& str) {
    if (str == "gamepad") return TOWNS_GAMEPORTEMU_PHYSICAL0;
    if (str == "mouse") return TOWNS_GAMEPORTEMU_MOUSE;
    if (str == "cyberstick") return TOWNS_GAMEPORTEMU_PHYSICAL0_AS_CYBERSTICK;
    if (str == "6button") return TOWNS_GAMEPORTEMU_6BTN_BY_PHYSICAL0;
    if (str == "capcom") return TOWNS_GAMEPORTEMU_CAPCOM_BY_PHYSICAL0;
    if (str == "libblerabble") return TOWNS_GAMEPORTEMU_LIBBLERABBLE_BY_PHYSICAL0;
    if (str == "martypad") return TOWNS_GAMEPORTEMU_PHYSICAL0; // Marty usa gamepad estándar
    if (str == "none") return TOWNS_GAMEPORTEMU_NONE;
    return TOWNS_GAMEPORTEMU_PHYSICAL0; // Default
}
```

**1.3. Aplicar configuración en `Runtime::load()`:**
```cpp
// Leer opciones de core
retro_variable var;
var.key = "tsugaru_port0_type";
if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
    argv.gamePort[0] = StringToGamePortEmu(var.value);
}
var.key = "tsugaru_port1_type";
if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
    argv.gamePort[1] = StringToGamePortEmu(var.value);
}
```

**Estado actual:** implementado.

**1.4. Actualizar descriptores de entrada según tipo:**
```cpp
void UpdateInputDescriptors() {
    std::vector<retro_input_descriptor> descriptors;
    
    // Puerto 0
    if (port0_type == GAMEPAD || port0_type == GAMEPAD_6BTN) {
        descriptors.push_back({ 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_LEFT, "D-Pad Left" });
        // ... resto de botones
        if (port0_type == GAMEPAD_6BTN) {
            descriptors.push_back({ 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_X, "Button X" });
            descriptors.push_back({ 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_Y, "Button Y" });
            descriptors.push_back({ 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_L, "Button L" });
            descriptors.push_back({ 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_R, "Button R" });
        }
    }
    
    // Puerto 1 (similar)
    
    descriptors.push_back({ 0, 0, 0, 0, nullptr });
    environ_cb(RETRO_ENVIRONMENT_SET_INPUT_DESCRIPTORS, descriptors.data());
}
```

**Estado actual:** no implementado. Hoy los descriptores son fijos.

---

### FASE 2: Mapeo de Teclado

**Inspiración:** XM62026 `mfc_inp.cpp` líneas 857-950

**2.1. Crear tabla de mapeo RetroArch → FM Towns:**

```cpp
// Basado en keyboard/keytrans.cpp del standalone
static const unsigned char RetroKeyToTownsKey[RETROK_LAST] = {
    [RETROK_ESCAPE] = TOWNS_JISKEY_ESC,        // 0x01
    [RETROK_1] = TOWNS_JISKEY_1,               // 0x02
    [RETROK_2] = TOWNS_JISKEY_2,               // 0x03
    [RETROK_3] = TOWNS_JISKEY_3,               // 0x04
    [RETROK_4] = TOWNS_JISKEY_4,               // 0x05
    [RETROK_5] = TOWNS_JISKEY_5,               // 0x06
    [RETROK_6] = TOWNS_JISKEY_6,               // 0x07
    [RETROK_7] = TOWNS_JISKEY_7,               // 0x08
    [RETROK_8] = TOWNS_JISKEY_8,               // 0x09
    [RETROK_9] = TOWNS_JISKEY_9,               // 0x0A
    [RETROK_0] = TOWNS_JISKEY_0,               // 0x0B
    [RETROK_MINUS] = TOWNS_JISKEY_MINUS,       // 0x0C
    [RETROK_CARET] = TOWNS_JISKEY_HAT,         // 0x0D (^)
    [RETROK_BACKSLASH] = TOWNS_JISKEY_YEN,     // 0x0E (\)
    [RETROK_BACKSPACE] = TOWNS_JISKEY_BACKSPACE, // 0x0F
    
    [RETROK_TAB] = TOWNS_JISKEY_TAB,           // 0x10
    [RETROK_q] = TOWNS_JISKEY_Q,               // 0x11
    [RETROK_w] = TOWNS_JISKEY_W,               // 0x12
    // ... continuar con todas las teclas
    
    [RETROK_F1] = TOWNS_JISKEY_F1,             // 0x63
    [RETROK_F2] = TOWNS_JISKEY_F2,             // 0x64
    // ... F3-F10
    
    [RETROK_LEFT] = TOWNS_JISKEY_LEFT,         // 0x3B
    [RETROK_UP] = TOWNS_JISKEY_UP,             // 0x3C
    [RETROK_RIGHT] = TOWNS_JISKEY_RIGHT,       // 0x3D
    [RETROK_DOWN] = TOWNS_JISKEY_DOWN,         // 0x3E
    
    // Teclado numérico
    [RETROK_KP0] = TOWNS_JISKEY_NUM_0,         // 0x4F
    [RETROK_KP1] = TOWNS_JISKEY_NUM_1,         // 0x4B
    // ... resto del numpad
};
```

**Estado actual:** implementado en `src/libretro/libretro.cpp`.

**2.2. Implementar callback de teclado:**

```cpp
void retro_keyboard_event(bool down, unsigned keycode, uint32_t character, uint16_t key_modifiers) {
    if (keycode >= RETROK_LAST) return;
    
    unsigned char townsKey = RetroKeyToTownsKey[keycode];
    if (townsKey == TOWNS_JISKEY_NULL) return;
    
    if (down) {
        // Enviar tecla presionada al emulador
        if (runtime && runtime->towns) {
            runtime->towns->keyboard.PushFifo(townsKey);
        }
    } else {
        // Enviar tecla liberada (código | 0x80)
        if (runtime && runtime->towns) {
            runtime->towns->keyboard.PushFifo(townsKey | 0x80);
        }
    }
}
```

**Estado actual:** implementado.

**2.3. Registrar callback en `retro_init()`:**

```cpp
TSUGARU_RETRO_API void retro_init(void) {
    // ... código existente ...
    
    // Habilitar teclado
    struct retro_keyboard_callback kb_callback = { retro_keyboard_event };
    if (environ_cb) {
        environ_cb(RETRO_ENVIRONMENT_SET_KEYBOARD_CALLBACK, &kb_callback);
    }
}
```

**Estado actual:** implementado.

---

### FASE 3: Mapeo Extendido de Controles

**Basado en:** XM62026 `mfc_inp.cpp` líneas 2000-2300

**3.1. Soporte para controles de 6 botones (CAPCOM CPSF):**

```cpp
void UpdateGamePadState(unsigned port) {
    if (!input_poll_cb || !input_state_cb) return;
    
    input_poll_cb();
    
    bool left = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_LEFT);
    bool right = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_RIGHT);
    bool up = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_UP);
    bool down = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_DOWN);
    bool a = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_A);
    bool b = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_B);
    bool x = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_X);
    bool y = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_Y);
    bool l = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_L);
    bool r = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_R);
    bool start = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_START);
    bool select = input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_SELECT);
    
    if (port0_type == CAPCOMCPSF) {
        runtime->towns->gameport.state.ports[port].SetCAPCOMCPSFState(
            left, right, up, down, a, b, x, y, l, r, start, select, 
            runtime->towns->state.townsTime
        );
    } else {
        // Gamepad estándar
        runtime->towns->SetGamePadState(port, a, b, left, right, up, down, start, select, false);
    }
}
```

**3.2. Soporte para CyberStick (analógico):**

```cpp
void UpdateCyberStickState(unsigned port) {
    if (!input_poll_cb || !input_state_cb) return;
    
    input_poll_cb();
    
    int16_t x = input_state_cb(port, RETRO_DEVICE_ANALOG, RETRO_DEVICE_INDEX_ANALOG_LEFT, RETRO_DEVICE_ID_ANALOG_X);
    int16_t y = input_state_cb(port, RETRO_DEVICE_ANALOG, RETRO_DEVICE_INDEX_ANALOG_LEFT, RETRO_DEVICE_ID_ANALOG_Y);
    int16_t z = input_state_cb(port, RETRO_DEVICE_ANALOG, RETRO_DEVICE_INDEX_ANALOG_RIGHT, RETRO_DEVICE_ID_ANALOG_X);
    int16_t w = input_state_cb(port, RETRO_DEVICE_ANALOG, RETRO_DEVICE_INDEX_ANALOG_RIGHT, RETRO_DEVICE_ID_ANALOG_Y);
    
    // Leer botones como máscara de bits
    unsigned int trig = 0;
    if (input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_A)) trig |= 1;
    if (input_state_cb(port, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_B)) trig |= 2;
    // ... hasta 32 botones
    
    runtime->towns->gameport.state.ports[port].SetCyberStickState(
        x, y, z, w, trig, runtime->towns->state.townsTime
    );
}
```

---

## Resumen de Cambios Necesarios

### Archivos a Modificar:

1. **`src/libretro/libretro.cpp`**
   - Ya tiene variables de core, `StringToGamePortEmu()`, `retro_keyboard_event()` y `DevicePolling()`
   - Falta: descriptores dinámicos y soporte real de `cyberstick`/`libblerabble`/`martypad`

2. **`src/libretro/libretro.h`** (si es necesario)
   - No parece necesario para el estado actual

### Archivos de Referencia:

- **XM62026:** `mfc/mfc_inp.cpp`, `mfc/mfc_inp.h`
- **Tsugaru standalone:** `towns/keyboard/keytrans.cpp`, `towns/gameport/gameport.cpp`

---

## Prioridades

1. **ALTA:** Resolver el conflicto `F1` vs hotkeys de RetroArch
2. **ALTA:** Soporte real de `cyberstick`, `libblerabble` y `martypad`
3. **MEDIA:** Descriptores dinámicos por tipo de puerto
4. **BAJA:** Soporte analógico fino si se decide exponerlo en libretro
