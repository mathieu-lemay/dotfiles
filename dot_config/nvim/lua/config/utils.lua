local focus_win = function(winid)
    local win = vim.fn.bufwinid(winid)
    if win > -1 then
        vim.api.nvim_set_current_win(win)
    end
end

return {
    focus_win = focus_win,
}
