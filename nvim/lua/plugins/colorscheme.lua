return {
  -- Adiciona o plugin do tema Nord
  { "shaunsingh/nord.nvim" },

  -- Configura o LazyVim para usar o Nord como tema padrão
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
