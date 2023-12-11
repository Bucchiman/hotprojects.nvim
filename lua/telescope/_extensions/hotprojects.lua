#!/usr/bin/env lua
--
-- FileName:     hotprojects
-- Author:       8ucchiman
-- Email:        8ucchiman@gmail.com
-- CreatedDate:  2023-10-21 14:14:38
-- LastModified: 2023-12-12 00:34:02
-- Reference:    https://stackoverflow.com/questions/73358168/where-can-i-check-my-neovim-lua-runtimepath
-- Description:  ---
--


local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local utils = require("telescope.utils")
local sorters = require("telescope.sorters")
local make_entry = require("telescope.make_entry")
local api = vim.api


return require("telescope").register_extension {
    exports = {
        show_hotproject = function(opts)
            opts = opts or {}
            opts.cwd = opts.cwd or vim.fn.getcwd()
            local home_dir = os.getenv("HOME")
            if home_dir == nil then
                home_dir = os.getenv("UserProfile")
            end
            local hotstation_paty = home_dir .. "/.config/local/hotstation"
            local command = {"cat", hotstation_paty}
            -- local command = {"cat", "/Users/8ucchiman/.config/local/hotstation"}

            local seen = {};
            local string_entry_maker = make_entry.gen_from_string()
            opts.entry_maker = function(string)
                if (not seen[string]) then
                    seen[string] = true
                    return string_entry_maker(string)
                else
                    return nil
                end
            end

            pickers.new(opts, {
                prompt_title = 'Hot Project> ',
                finder = finders.new_oneshot_job(command, opts),
                sorter = sorters.get_generic_fuzzy_sorter(),
                attach_mappings = function(prompt_bufnr, map)
                    local list_hotproject = function()
                        local picker = action_state.get_current_picker(prompt_bufnr)
                        local selections = picker:get_multi_selection()
                        if next(selections) == nil then
                            selections = {picker:get_selection()}
                        end
                        actions.close(prompt_bufnr)

                        local hotprojects = {}
                        for _, c in ipairs(selections) do
                            table.insert(hotprojects, c[1])
                        end
                        -- api.nvim_put(hotprojects, "l", true, false)
                        vim.cmd("e " .. hotprojects[1])
                    end

                map('i', '<CR>', list_hotproject)
                map('n', '<CR>', list_hotproject)

                return true
                end,
            }):find()
    end,
  }
}
