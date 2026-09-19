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

# Caminho num campo de texto (VictorMono pelo gtk.css) em vez de botões
set_pref /last-location-bar      string ThunarLocationEntry
set_pref /last-side-pane         string THUNAR_SIDEPANE_TYPE_SHORTCUTS
set_pref /last-separator-position int    220
set_pref /last-menubar-visible   bool   false
set_pref /last-statusbar-visible bool   true
set_pref /last-show-hidden       bool   true
set_pref /last-image-preview-visible bool false

# Barra do design: voltar, avançar, caminho e busca; CSD desligado (o i3 já decora)
set_pref /misc-use-csd       bool   false
set_pref /last-toolbar-items string "menu:0,back:1,forward:1,open-parent:0,open-home:0,new-tab:0,new-window:0,toggle-split-view:0,undo:0,redo:0,zoom-out:0,zoom-in:0,zoom-reset:0,view-as-icons:0,view-as-detailed-list:0,view-as-compact-list:0,view-switcher:0,location-bar:1,reload:0,search:1"
