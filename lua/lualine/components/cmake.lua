
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

local default_options = {}

function M:init(options)
    M.super.init(self, options)
    self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
    default_options.separator = resolve(self.options.cmake_separator) or "|"
end

function M:update_status()
    if not cmake.is_cmake_project() then
        return ""
    end

    local status = ""
    local separator = ""

    local build_type = cmake.get_build_type()
    local has_build_type = build_type ~= nil and build_type ~= ""

    if has_build_type then
        status = string.format("%s%s", status, build_type)
    end

    local build_target = cmake.get_build_target()
    local has_build_target = build_target ~= nil and build_target ~= ""

    if has_build_target then
        if has_build_type then
            separator = default_options.separator
        end
        status = string.format("%s%s%s", status, separator, build_target)
    end
    return status
end

return M

