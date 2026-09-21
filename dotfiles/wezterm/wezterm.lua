local wezterm = require 'wezterm'
local config = wezterm.config_builder()


config.automatically_reload_config = true
config.use_ime = true
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

-- Font configuration
config.font = wezterm.font_with_fallback {
    {
        family = "Lilex",
        weight = "Regular",
        harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
    },
    {
        family = "IM Plex Sans JP",
        weight = "Regular",
    },
    "Symbols Nerd Font Mono"
}
config.font_size = 12.5

-- Shell configuration
config.default_domain = "WSL:FedoraLinux-44"
config.wsl_domains = {
    {
        name = "WSL:FedoraLinux-44",
        distribution = "FedoraLinux-44",
        default_cwd = "~",
    },
}

-- Window and tab configuration
-- -- Disable top bar
config.window_decorations = "RESIZE"
-- -- Show tab bar
config.show_tabs_in_tab_bar = true
-- -- Hide tab if only one tab is open
config.hide_tab_bar_if_only_one_tab = true

-- -- Shared black background for the terminal and the tab bar
local TERMINAL_BG = "#000000"
local TAB_PADDING = "  "
local TAB_BAR_LEFT_MARGIN = "  "
local TAB_COLORS = {
    inactive = { bg = TERMINAL_BG, fg = "#9a9a9a" },
    hover = { bg = "#1e1e1e", fg = "#ffffff" },
    active = { bg = "#3c3c3c", fg = "#ffffff" },
}
local TAB_EDGE_LEFT = wezterm.nerdfonts.ple_left_half_circle_thick
local TAB_EDGE_RIGHT = wezterm.nerdfonts.ple_right_half_circle_thick

-- -- Use the retro tab bar so the tab content is fully controlled below
config.use_fancy_tab_bar = false
config.window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
}
config.window_background_gradient = {
    colors = { TERMINAL_BG },
}

-- -- Hide the new-tab button
config.show_new_tab_button_in_tab_bar = false

-- -- Blend the tab bar into the black terminal background
config.colors = {
    tab_bar = {
        background = TERMINAL_BG,
        inactive_tab_edge = "none",
    },
}

-- -- Tab design: black like the terminal, rounded gray pill for the active tab
local TAB_DECORATION_WIDTH = wezterm.column_width(TAB_EDGE_LEFT)
    + wezterm.column_width(TAB_EDGE_RIGHT)
    + 2 * wezterm.column_width(TAB_PADDING)

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
    local color = TAB_COLORS.inactive
    if tab.is_active then
        color = TAB_COLORS.active
    elseif hover then
        color = TAB_COLORS.hover
    end

    local title = TAB_PADDING
        .. wezterm.truncate_right(tab.active_pane.title, math.max(max_width - TAB_DECORATION_WIDTH, 1))
        .. TAB_PADDING

    return {
        { Background = { Color = TERMINAL_BG } },
        { Foreground = { Color = color.bg } },
        { Text = TAB_EDGE_LEFT },
        { Background = { Color = color.bg } },
        { Foreground = { Color = color.fg } },
        { Text = title },
        { Background = { Color = TERMINAL_BG } },
        { Foreground = { Color = color.bg } },
        { Text = TAB_EDGE_RIGHT },
    }
end)

-- -- Small left margin for the tab bar (tabs stay left-aligned)
wezterm.on("update-status", function(window, _pane)
    window:set_left_status(TAB_BAR_LEFT_MARGIN)
end)

-- -- Full screen
wezterm.on('gui-startup', function()
    local _, _, window = wezterm.mux.spawn_window({})
    window:gui_window():toggle_fullscreen()
end)

return config
