
local PLUGIN_NAME = "lualine-cmake"

local is_cmake_plugin_installed, cmake = pcall(require, "cmake")
if not is_cmake_plugin_installed then
    error(string.format("%s plugin requires thefoxery/cmake.nvim plugin", PLUGIN_NAME))
end

local lualine = require("lualine_require")
local M = lualine.require("lualine.component"):extend()

local default_options = {
    cmake_separator = "|"
}

function M:init(options)
    M.super.init(self, options)
    self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
end

function M:update_status()
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
            separator = self.options.cmake_separator
        end
        status = string.format("%s%s%s", status, separator, build_target)
    end
    return status
end

return M

