<div align="center">
  <img src="avatar.png" alt="Logo" width="115" height="115" style="border-radius: 22px;">
  <h1>⚡ Task Bar Hero Auto Stash (Haruki Edition)</h1>
  <p><b>Smart Inventory Sensor, Sequential Multi-Tab Stasher & Discord Webhook Reporter for Taskbar Hero</b></p>

  <p>
    <img src="https://img.shields.io/badge/Version-2.0.0-89DCEB?style=for-the-badge" alt="Version">
    <img src="https://img.shields.io/badge/Platform-Windows-A6E3A1?style=for-the-badge&logo=windows" alt="Platform">
    <img src="https://img.shields.io/badge/Language-AutoHotkey_v1.1-CBA6F7?style=for-the-badge" alt="Language">
    <a href="https://discord.gg/gardenofdream">
      <img src="https://img.shields.io/badge/Discord-Garden_of_Dream-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord">
    </a>
  </p>
</div>

---

## ✨ Overview
**TBH Auto-Stasher** is a lightweight desktop utility built for **Taskbar Hero** players who want to AFK farm without worrying about full inventories. Instead of blindly spamming clicks and hijacking your cursor, the app uses a **9-Point Smart Pixel Grid Sensor** to silently monitor your inventory in the background and only acts when items reach your designated trigger slot.

## 🚀 Key Features
* 🎯 **Non-Intrusive 9-Point Grid Sensor:** Silently monitors your chosen inventory trigger slot in the background. Your mouse is only used for ~0.5 seconds when the inventory actually needs stashing.
* 🧩 **Full DLC Customization:**
  * **Material Stash DLC Support:** Always prioritizes stashing materials into the Material Tab first before sorting weapons and armor into standard tabs.
  * **+3 Stash Slots DLC Support:** Seamlessly toggles between Base Game mode (**2 Tabs**) and DLC mode (**5 Tabs**).
* 🔄 **Sequential Tab Switching:** Automatically detects when the current Stash Tab is full (via bottom-right slot sensing) and advances to the next tab (`1 ➔ 2 ➔ 3 ➔ 4 ➔ 5`). Automatically stops when all tabs are completely full.
* 🪟 **Dynamic Window Tracking & DPI Aware:** Tracks the game window position dynamically even if you move it across your screen. Supports 100%, 125%, and 150% Windows Display Scaling.
* 💾 **Persistent Configuration (`config.ini`):** Saves your calibrated coordinates, DLC preferences, scan interval, and Webhook URL automatically. Calibrate once, use forever!
* 📸 **Discord Webhook Integration:** Automatically captures a clean screenshot of your game window and sends a formatted status report (Stash Count, Active Tab, Run Time) to your Discord channel every time your inventory is stashed or when all stashes are full.
* 📊 **Modern Dark UI & Live Session Stats:** Custom borderless dark theme featuring a real-time **Run Time Clock (`00:00:00`)** and **Total Stashed Counter**.

---

## 🛠️ How to Use

### 1. First-Time Calibration (`F1`)
1. Open both the **STASH** and **HERO (Inventory)** windows in-game.
2. Select your owned DLCs under **DLC CONFIGURATION** (`Material Stash DLC` / `+3 Stash Slots DLC`).
3. Press **`F1`** (or click **1. Calibrate**) and follow the on-screen prompts. Hover your mouse over each requested point and press **`F1`** or **`~` (tilde/backtick)** to confirm:
   * **Step 1:** `[Stash All]` button.
   * **Step 2:** `[Material Tab]` *(Only asked if Material DLC is enabled)*.
   * **Step 3:** Stash `[Tab 1]`.
   * **Step 4:** Last Stash Tab (`[Tab 2]` or `[Tab 5]`).
   * **Step 5:** Center of the **Last Empty Slot** in Stash (Bottom-Right corner — must be empty during calibration).
   * **Step 6:** Center of an **Empty Trigger Slot** in your Inventory (must be empty during calibration).

### 2. Hotkeys
| Hotkey | Action |
| :---: | :--- |
| **`F1`** | Start Calibration / Confirm calibration point |
| **`F2`** | Start / Pause Auto-Stasher |
| **`F3`** | Force Stash Immediately (Manual Test) |

---

## 📦 Installation
* **Option A (Standalone App):** Download `TBH_AutoStasher_Haruki.exe` directly from this repository or the [Releases](../../releases) page and launch it (no installation required).
* **Option B (Run from Source):**
  1. Install [AutoHotkey v1.1](https://www.autohotkey.com/).
  2. Download this repository (keep `avatar.png` in the same folder).
  3. Double-click `TBH_AutoStasher.ahk` to launch.

---

## ❤️ Credits & Community
* **Created by:** Haruki
* 💬 **Discord:** `haruki_kino`
* 🌐 **Discord Server:** [Garden of Dream](https://discord.gg/gardenofdream)