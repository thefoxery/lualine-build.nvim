
# lualine-build

Lualine component to show build configuration details from your build system

NOTE: In early development. Expect changes. When things settle down a bit I will 
    look into tags, versioning, docs etc.

# installation

```
# lazy

{
    "thefoxery/lualine-build.nvim",
    dependencies = {
        "nvim-lualine/lualine.nvim",
        "nvim-tree/nvim-web-devicons",
    },
}
```

# configuration

```
# in lualine config

{
    sections = {
        lualine_x = {
            {
                "build-configuration",
                format_string = "Project: ${BUILD_TARGET} [${BUILD_TYPE}]",
                missing_value_texts = {
                    ["BUILD_TARGET"] = "<no target>",
                },
                provider = function()
                    return {
                        get_build_type = "Debug",
                        get_build_target = "",
                    }
                end,
                not_selected_text = "<not selected>",
            }
        },
    },
}
```

# upcoming features

- Add label, to prefix string with (with custom coloring)
    - i.e. enables you to show an icon to make information more compact

# thanks / inspiration

What got me started
- [lualine-cmake4vim](https://github.com/SantinoKeupp/lualine-cmake4vim.nvim)

