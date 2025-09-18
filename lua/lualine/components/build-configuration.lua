
local PLUGIN_NAME = "lualine-build"

local lualine = require("lualine_require")

local modules = lualine.lazy_require {
    highlight = "lualine.highlight",
    utils = "lualine.utils.utils",
}

local M = lualine.require("lualine.component"):extend()

local function resolve(opt)
    if type(opt) == "function" then
        return opt()
    else
        return opt
    end
end

local dummy_provider = function() return "" end

local default_opts = {
    format_string = "Target: ${BUILD_TARGET} [${BUILD_TYPE}]",
    default_missing_value_text = "",
    missing_value_texts = {
        ["PROVIDER_NAME"] = "Unknown",
        ["BUILD_TARGET"] = "<no target>",
        ["BUILD_TYPE"] = "<no config>",
    },
    provider = {
        get_build_system_type = dummy_provider,
        get_build_target = dummy_provider,
        get_build_type = dummy_provider,
    },
    icon = {
        enabled = false,
        f_name = ".clang-tidy",
        f_extension = "",
    },
}

function M:init(user_opts)
    M.super.init(self, user_opts)
    user_opts = user_opts or {}
    user_opts.icon = user_opts.icon or {}
    self.opts = vim.tbl_deep_extend("force", {}, default_opts, resolve(user_opts) or {})

    self.opts.icon = self.opts.icon or {}
    self.opts.icon.enabled = resolve(user_opts.icon.enabled) or default_opts.icon.enabled
    self.opts.icon.f_name = resolve(user_opts.icon.f_name) or default_opts.icon.f_name
    self.opts.icon.f_extension = resolve(user_opts.icon.f_extension) or default_opts.icon.f_extension
    self.opts.icon.colored = resolve(user_opts.icon.colored) or default_opts.icon.colored

    self.icon_hl_cache = {}
end

function M:update_status()
    local provider = resolve(self.opts.provider)
    if provider == nil or not provider.is_project_directory() then
        return ""
    end

    local format_string = resolve(self.opts.format_string) or default_opts.format_string
    if format_string then
        local token_map = {
            ["PROVIDER_NAME"] = resolve(provider.get_build_system_type) or "",
            ["BUILD_TARGET"] = resolve(provider.get_build_target) or "",
            ["BUILD_TYPE"] = resolve(provider.get_build_type) or "",
        }

        local text = string.format("%s", format_string)

        for token, value in pairs(token_map) do
            if value == "" then
                value = resolve(self.opts.missing_value_texts[token]) or default_opts.missing_value_texts[token] or default_opts.default_missing_value_text
            end
            if value ~= nil then
                text = text:gsub("${" .. token .. "}", value)
            end
        end

        return text
    end
end

local function get_icon(f_name, f_extension)
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if ok then
        local icon, _ = devicons.get_icon(
            f_name,
            f_extension
        )
        if icon then
            return icon
        end
    end
end

function M:apply_icon()
    if self.options.icons_enabled or self.opts.icon.enabled then
        local icon = get_icon(
            self.opts.icon.f_name,
            self.opts.icon_f_extension
        )

        if not icon then
            return
        end

        self.status = string.format("%s %s", icon, self.status)
    end
end

return M

