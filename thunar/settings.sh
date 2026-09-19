#!/usr/bin/env bash
# Preferências do Thunar no layout do design Stratus (artboard "Files").
# Ficam no xfconf, que reescreve o próprio xml e não aceita symlink; por isso um script.
# Idempotente: pode rodar de novo a qualquer momento.

set_pref() {
    local property="$1" type="$2" value="$3"
    xfconf-query -c thunar -p "$property" -n -t "$type" -s "$value"
}

# Lista em detalhes com Nome / Tamanho / Modificado e ícones de 16px
set_pref /last-view                         string ThunarDetailsView
set_pref /last-details-view-zoom-level      string THUNAR_ZOOM_LEVEL_25_PERCENT
set_pref /last-details-view-visible-columns string THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_DATE_MODIFIED

# Caminho em segmentos (um botão por pasta), estilizados no gtk.css como o campo do design
set_pref /last-location-bar      string ThunarLocationButtons
set_pref /last-side-pane         string THUNAR_SIDEPANE_TYPE_SHORTCUTS
set_pref /last-separator-position int    220
set_pref /last-menubar-visible   bool   false
set_pref /last-statusbar-visible bool   true
set_pref /last-show-hidden       bool   true
set_pref /last-image-preview-visible bool false

# Barra do design: voltar, avançar, caminho e busca; CSD desligado (o i3 já decora)
set_pref /misc-use-csd       bool   false
set_pref /last-toolbar-items string "menu:0,back:1,forward:1,open-parent:0,open-home:0,new-tab:0,new-window:0,toggle-split-view:0,undo:0,redo:0,zoom-out:0,zoom-in:0,zoom-reset:0,view-as-icons:0,view-as-detailed-list:0,view-as-compact-list:0,view-switcher:0,location-bar:1,reload:0,search:1"

# Lateral como no design: só pasta pessoal, atalhos do gtk-3.0/bookmarks e dispositivos
xfconf-query -c thunar -p /hidden-bookmarks -r 2>/dev/null
xfconf-query -c thunar -p /hidden-bookmarks -n -a \
    -t string -s "computer:///" -t string -s "recent:///" -t string -s "trash:///" \
    -t string -s "network:///" -t string -s "file://$HOME/Desktop"

# Colunas do design: "7 itens" nas pastas, tamanhos decimais (kB) e data curta ("20 May")
set_pref /misc-folder-item-count string THUNAR_FOLDER_ITEM_COUNT_ALWAYS
set_pref /misc-file-size-binary  bool   false
set_pref /misc-date-style        string THUNAR_DATE_STYLE_CUSTOM
set_pref /misc-date-custom-style string "%d %b"

# Com o destaque de arquivos (cores por arquivo) ligado, o Thunar pinta a seleção por
# conta própria em accent sólido e ignora o gtk.css; desligado, vale a seleção elevated
set_pref /misc-highlighting-enabled bool false
