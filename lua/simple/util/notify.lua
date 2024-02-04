local M = {}

---@param message string
function M.debug(message) vim.notify(message, vim.log.levels.DEBUG) end

---@param message string
function M.error(message) vim.notify(message, vim.log.levels.ERROR) end

---@param message string
function M.info(message) vim.notify(message, vim.log.levels.INFO) end

---@param message string
function M.warn(message) vim.notify(message, vim.log.levels.WARN) end

return M
