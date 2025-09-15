
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
    part_separator = " | ",
    label = "",
    format_string = "",
    not_available_text = "<not set>",
}

local opt = {}

function M:init(options)
    M.super.init(self, options)
    self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
    opt.part_separator = resolve(self.options.part_separator) or default_options.part_separator
    opt.label = resolve(self.options.label) or default_options.label
    opt.format_string = resolve(self.options.format_string) or default_options.format_string
    opt.not_available_text = resolve(self.options.not_available_text) or default_options.not_available_text
end

function M:update_status()
    if not cmake.is_cmake_project() then
        return ""
    end

    if opt.format_string then
        local tokens = {}

        local split_parts = vim.split(opt.format_string, "|")
        for _, part in ipairs(split_parts) do
            part = vim.trim(part)
            if part ~= "" then
                table.insert(tokens, part)
            end
        end

        local token_map = {
            ["${BUILD_TARGET}"] = cmake.get_build_target,
            ["${BUILD_TYPE}"] = cmake.get_build_type,
        }

        local parts = {}
        for _, token in ipairs(tokens) do
            if token_map[token] == nil then
                if opt.not_available_text ~= nil or opt.not_available_text == "" then
                    table.insert(parts, opt.not_available_text)
                end
            else
                local getter = token_map[token]
                local value = getter()
                if value == nil or value == "" then
                    if opt.not_available_text ~= nil and opt.not_available_text ~= "" then
                        value = opt.not_available_text
                    end
                end

                if value ~= "" then
                    table.insert(parts, value)
                end
            end
        end

        local text = opt.label
        for i, section in ipairs(parts) do
            if i > 1 then
                text = string.format("%s%s", text, opt.part_separator)
            end
            text = string.format("%s%s", text, section)
        end

        return text
    else
        local parts = {}

        local build_target = cmake.get_build_target()
        if build_target == nil or build_target == "" then
            table.insert(parts, opt.not_available_text)
        else
            table.insert(parts, build_target)
        end

        local build_type = cmake.get_build_type()
        if build_type ~= nil and build_type ~= "" then
            table.insert(parts, build_type)
        end

        local text = opt.label
        for i, part in ipairs(parts) do
            if i > 1 then
                text = string.format("%s%s", text, opt.part_separator)
            end
            text = string.format("%s%s", text, part)
        end

        return text
    end
end

return M

