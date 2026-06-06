# Modern FiveM Damage Logs

A highly optimized, secure, and standalone damage logging system for FiveM. This resource tracks bone-specific hit locations, remaining HP/Armor, and weapon damage, logging them directly to Discord webhooks with zero client-side string trust.

## 🚀 Key Features

- **🛡️ Secure-by-Design**: The client never constructs log strings. All event parameters are strictly verified and sanitized server-side, preventing executor abuse, spoofed messages, and Discord webhook spam.
- **⚡ Zero Idle Overhead (0.00ms)**: The resource replaces resource-intensive client loops with event-driven `gameEventTriggered` hooks. Floating damage numbers draw on-screen using a dynamic self-terminating thread.
- **📦 Fully Standalone**: Removed ESX/framework dependencies. Ready to run on any standard FiveM server.
- **🎛️ Unified Config**: Easily customize UI positions, text formatting, webhooks, rate limits, and protection settings in one file.

## 🔧 Installation & Setup

1. Copy the `damageLogs` folder into your resources directory.
2. Open `config.lua` and configure your settings and Discord Webhook URLs:
   ```lua
   Config.Discord.DamageWebhook = "YOUR_DISCORD_WEBHOOK_URL"
   Config.Discord.TotalDamageWebhook = "YOUR_DISCORD_WEBHOOK_URL"
   ```
3. Add `ensure damageLogs` to your `server.cfg`.

## ⚙️ Configuration Options (`config.lua`)

| Option | Description | Default |
|--------|-------------|---------|
| `Config.MaxDamageLogs` | Maximum number of floating damage logs shown on screen | `5` |
| `Config.DisplayTime` | Time (ms) each damage log text remains on screen | `3000` |
| `Config.NetworkCooldown` | Throttling time (ms) for client logs and server webhook events | `300` |
| `Config.UI` | Position, colors, scale, and font styling for floating damage numbers | *Customizable* |
| `Config.Protection.RateLimit` | Server-side event throttle rate limit (ms) per player | `300` |
| `Config.Protection.MaxWarnings` | Warnings before ignoring suspicious client events | `3` |
| `Config.Protection.AlertAdminsOnExploit` | Print detailed warnings to console on exploit attempts | `true` |
