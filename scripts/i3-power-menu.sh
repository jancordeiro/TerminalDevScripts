#!/usr/bin/env bash

# Script pra menu com opções de energia (desligar, reiniciar e sair) usando dmenu

# Esquema de cores Cyberpunk lol
BG="#1a0033"        # Roxo escuro (Fundo normal)
FG="#00ffcc"        # Verde Neon / Ciano (Texto normal)
SEL_BG="#00ffcc"    # Verde Neon / Ciano (Fundo selecionado)
SEL_FG="#1a0033"    # Roxo escuro (Texto selecionado)
FONT="monospace-11"

# Opções com Emojis pra ficar estilozão haha
opcoes="🔒 Lock\n⟳ Reboot\n⏻ Shutdown\n↪ Logout"

# Executa o dmenu e captura a escolha
escolha=$(echo -e "$opcoes" | dmenu -fn "$FONT" -nb "$BG" -nf "$FG" -sb "$SEL_BG" -sf "$SEL_FG" -p "Power:" -i -l 4)

# Laço para executar a ação conforme escolha
case "$escolha" in
    *Lock) i3lock -i /home/jancordeiro/Imagens/cyberpunk-i3.png ;;
    *Reboot) desktop-session -r ;;   # Comando nativo do antiX para reiniciar
    *Shutdown) desktop-session -s ;; # Comando nativo do antiX para desligar
    *Logout) i3-msg exit ;;
esac
