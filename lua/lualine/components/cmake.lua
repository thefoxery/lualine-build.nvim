
local PLUGIN_NAME = "lualine-cmake"

local is_cmake_plugin_installed, cmake = pcall(require, "cmake")
if not is_cmake_plugin_installed then
    error(string.format("%s plugin requires thefoxery/cmake.nvim plugin", PLUGIN_NAME))
end

local lualine = require("lualine_require")
local M = lualine.require("lualine.component"):extend()

local function resolve(opt)
    if type(opt) == "function" then
        return opt()
    else
        return opt
    end
end

local default_options = {
    format_string = "CMake Target: ${BUILD_TARGET} [${BUILD_TYPE}]",
    not_selected_text = "<not selected>",
}

local opt = {}

function M:init(options)
    M.super.init(self, options)
    self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
    opt.not_selected_text = resolve(self.options.not_selected_text) or default_options.not_selected_text
    opt.format_string = resolve(self.options.format_string) or default_options.format_string
end

function M:update_status()
    if not cmake.is_cmake_project() then
        return ""
    end

    if opt.format_string then
        local token_map = {
            ["BUILD_TARGET"] = cmake.get_build_target,
            ["BUILD_TYPE"] = cmake.get_build_type,
        }

        local text = opt.format_string
        for token, getter in pairs(token_map) do
            local value = getter()
            if value == "" then
                value = opt.not_selected_text
            end
            text = text:gsub("${" .. token .. "}", value)
        end

        return text
    end
end

return M

