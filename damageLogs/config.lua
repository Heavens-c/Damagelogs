Config = {}

-- Maximum damage logs to show on screen
Config.MaxDamageLogs = 5

-- How long (in milliseconds) each floating damage text stays on the screen
Config.DisplayTime = 3000

-- Minimum time (in milliseconds) between client network events (rate limit / cooldown)
Config.NetworkCooldown = 300

-- UI Configuration for floating damage text
Config.UI = {
    x = 0.53,           -- Screen horizontal position (0.0 to 1.0)
    y = 0.50,           -- Screen vertical position (0.0 to 1.0)
    scale = 0.6,        -- Size of the text
    font = 2,           -- Text font ID (2 is usually standard thick font)
    centered = true,    -- Center align text
    spacing = 0.03,     -- Vertical spacing between multiple damage logs
    color = {
        r = 252,
        g = 78,
        b = 66
    }
}

-- Discord Log Settings (Server-side only)
Config.Discord = {
    Enabled = true,
    DamageWebhook = "YOUR_WEBHOOK_HERE",
    TotalDamageWebhook = "YOUR_WEBHOOK_HERE",
    Logo = "https://cdn.discordapp.com/attachments/873184959400149072/890646026044731412/dollar-black-poster.png",
    Username = "Heavens Logs",
    Color = 16711680 -- RGB Red in decimal
}

-- Server-side Protection Settings
Config.Protection = {
    RateLimit = 300,              -- Minimum time (in ms) allowed between client events per player
    MaxWarnings = 3,              -- Number of spam attempts before ignoring logs completely
    AlertAdminsOnExploit = true   -- Print exploit attempt warnings to server console
}
