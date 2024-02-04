local M = {}

---@param fname string
---@return boolean
function M.is_binary(fname)
    local fd = vim.loop.fs_open(fname, "r", 1)
    if not fd then return false end

    local ret = vim.loop.fs_read(fd, 1024):find("\0") ~= nil
    vim.loop.fs_close(fd)

    return ret
end

---@param fname string
---@param min_bytes number
---@return boolean
function M.has_min_bytes_per_line(fname, min_bytes)
    local has_fsize, fsize = pcall(vim.fn.getfsize, fname)
    if not has_fsize then return false end
    local has_lines, lines = pcall(vim.fn.readfile, fname)
    return has_lines and #lines * min_bytes < fsize
end

---@param winid number|nil
---@return boolean
function M.is_win_floating(winid) return nil ~= vim.api.nvim_win_get_config(winid or 0).zindex end

---@return string
function M.get_visual_selection()
    if vim.fn.mode() ~= "n" then
        local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
        vim.api.nvim_feedkeys(esc, "x", false)
    end

    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    if nil == s_start or nil == s_end then return "" end

    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1] or "", s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, "\n")
end

---@param filenames string[]
---@param bufnr number|nil
---@return boolean
function M.has_root_file(filenames, bufnr) return nil ~= M.get_root_file(filenames, bufnr) end

---@param filenames string[]
---@param bufnr number|nil
---@return string|nil
function M.get_root_file(filenames, bufnr)
    return vim.fs.find(filenames, { path = vim.api.nvim_buf_get_name(bufnr or 0), upward = true })[1] or nil
end

---@param ms number
---@param fn function
---@return function
function M.debounce(ms, fn)
    local timer = vim.loop.new_timer()
    return function(...)
        local argv = { ... }
        timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
        end)
    end
end

return M
