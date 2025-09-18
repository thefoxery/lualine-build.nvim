
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

-- TODO: consider a default value. i.e. "n/a" or "provider_not_set"
local dummy_provider = function() return "" end

local default_opts = {
    label = "",
    format_string = "Project: ${BUILD_TARGET} [${BUILD_TYPE}]",
    not_selected_text = "<not selected>",
    provider = {
        get_build_target = dummy_provider,
        get_build_type = dummy_provider,
    },
    icon = {
        enabled = false,
        f_name = "CMakeLists.txt",
        f_extension = "txt",
        colored = false,
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
            ["BUILD_TARGET"] = provider.get_build_target,
            ["BUILD_TYPE"] = provider.get_build_type,
        }

        local label = resolve(self.opts.label) or default_opts.label
        local text = string.format("%s%s", label, format_string)
        if text == nil then
            return ""
        end

        for token, getter in pairs(token_map) do
            local value = getter()
            if value == "" then
                value = resolve(self.opts.not_selected_text) or resolve(default_opts.not_selected_text)
            end
            text = text:gsub("${" .. token .. "}", value)
        end

        return text
    end
end

function M:apply_icon()
    if not self.opts.icon.enabled then
        return
    end

    local icon

    local ok, devicons = pcall(require, "nvim-web-devicons")
    if ok then
        icon, _ = devicons.get_icon(
            self.opts.icon.f_name,
            self.opts.icon.f_extension
        )
    end

    if not icon then
        return
    end

    self.status = string.format("%s %s", icon, self.status)
end

return M

