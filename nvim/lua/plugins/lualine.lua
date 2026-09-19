-- Barra de status no design Stratus: blocos retos, sem separadores powerline
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "", right = "" }
  end,
}
