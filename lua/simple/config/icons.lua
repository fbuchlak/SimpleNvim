local M = {
    common = {
        Branch = "",
        Checkbox = "󰱒 ",
        CheckboxBlank = "󰄱 ",
        Error = " ",
        Info = "󰋼 ",
        Lightbulb = "󰌵 ",
        OutlineBoxMinus = "󰛲 ",
        OutlineBoxPencil = "󰏭 ",
        OutlineBoxPlus = "󰜄 ",
        OutlineBoxPlusMinus = "󰦓 ",
        OutlineBoxQuestionmark = "󱀶 ",
        Search = " ",
        Timer = "󰔛 ",
        VerticalLine = "▎",
        VerticalLineThin = "│",
        Warn = " ",
        Readonly = " ",
    },
}

M.diagnostic = { Error = M.common.Error, Warn = M.common.Warn, Hint = M.common.Lightbulb, Info = M.common.Info }

return M
