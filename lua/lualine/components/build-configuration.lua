
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

-- TODO: consider a default value. i.e. "n/a" or "provider_not_set"
local dummy_provider = function() return "" end

local default_opts = {
    format_string = "Project: ${BUILD_TARGET} [${BUILD_TYPE}]",
    not_selected_text = "<not selected>",
    provider = {
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
            ["BUILD_TARGET"] = provider.get_build_target,
            ["BUILD_TYPE"] = provider.get_build_type,
        }

        local text = format_string
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

return M

