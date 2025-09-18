
local PLUGIN_NAME = "lualine-build"

local lualine = require("lualine_require")
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
    format_string = "${PROVIDER_NAME} Target: ${BUILD_TARGET} [${BUILD_TYPE}]",
    not_selected_text = "",
    default_missing_value_text = "",
    missing_value_texts = {
        ["PROVIDER_NAME"] = "Unknown",
        ["BUILD_TARGET"] = "<no target>",
        ["BUILD_TYPE"] = "<no config>",
    },
    provider = {
        get_provider_name = dummy_provider,
        get_build_target = dummy_provider,
        get_build_type = dummy_provider,
    },
}

function M:init(user_opts)
    M.super.init(self, user_opts)
    user_opts = user_opts or {}
    self.opts = vim.tbl_deep_extend("force", {}, default_opts, resolve(user_opts) or {})
end

function M:update_status()
    local provider = resolve(self.opts.provider)
    if provider == nil or not provider.is_project_directory() then
        return ""
    end

    local format_string = resolve(self.opts.format_string) or default_opts.format_string
    if format_string then
        local token_map = {
            ["PROVIDER_NAME"] = resolve(provider.get_provider_name) or "",
            ["BUILD_TARGET"] = resolve(provider.get_build_target) or "",
            ["BUILD_TYPE"] = resolve(provider.get_build_type) or "",
        }

        local text = format_string

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

return M

