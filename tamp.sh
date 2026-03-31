#!/bin/bash

##
## TAMP - Terminal Apache, MySQL & PHP
## A bash-script to install, unistall, check status, active and disable Apache, MySQL and PHP.
##
clear

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Detectar versão do PHP
get_php_version() {
    php -v | head -n 1 | cut -d " " -f 2 | cut -c 1-3 2>/dev/null
}

# Função para verificar status
check_status() {
    echo -e "${BLUE}--- Status do Stack TAMP ---${NC}"
    systemctl is-active --quiet apache2 && echo -e "Apache2:  ${GREEN}ON${NC}" || echo -e "Apache2:  ${RED}OFF${NC}"
    systemctl is-active --quiet mysql && echo -e "MySQL:    ${GREEN}ON${NC}" || echo -e "MySQL:    ${RED}OFF${NC}"
    
    PHP_V=$(get_php_version)
    if [ -n "$PHP_V" ]; then
        systemctl is-active --quiet "php$PHP_V-fpm" && echo -e "PHP $PHP_V:   ${GREEN}ON${NC}" || echo -e "PHP $PHP_V:   ${RED}OFF (ou módulo Apache)${NC}"
    else
        echo -e "PHP:      ${RED}Não encontrado${NC}"
    fi
}

# Função para ativar
active_service() {
    case $1 in
        "apache") sudo systemctl start apache2 ;;
        "mysql")  sudo systemctl start mysql ;;
        "php")    sudo systemctl start "php$(get_php_version)-fpm" 2>/dev/null ;;
        "all")    
            sudo systemctl start apache2 mysql
            sudo systemctl start "php$(get_php_version)-fpm" 2>/dev/null
            ;;
        *) echo -e "${RED}Item inválido.${NC}" ; return ;;
    esac
    echo -e "${GREEN}Serviço(s) '$1' ativado(s).${NC}"
}

# Função para desativar
disable_service() {
    case $1 in
        "apache") sudo systemctl stop apache2 ;;
        "mysql")  sudo systemctl stop mysql ;;
        "php")    sudo systemctl stop "php$(get_php_version)-fpm" 2>/dev/null ;;
        "all")    
            sudo systemctl stop apache2 mysql
            sudo systemctl stop "php$(get_php_version)-fpm" 2>/dev/null
            ;;
        *) echo -e "${RED}Item inválido.${NC}" ; return ;;
    esac
    echo -e "${YELLOW}Serviço(s) '$1' encerrado(s).${NC}"
}

# Função para desinstalar
uninstall_service() {
    echo -e "${RED}CUIDADO: Isso removerá pacotes e configurações de: $1${NC}"
    read -p "Confirmar desinstalação? (s/n): " confirm
    if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
        echo -e "${BLUE}Operação cancelada.${NC}"
        return
    fi

    case $1 in
        "apache")
            sudo apt-get purge -y apache2 apache2-utils apache2-bin
            sudo apt-get autoremove -y
            ;;
        "mysql")
            sudo apt-get purge -y mysql-server mysql-client mysql-common
            sudo rm -rf /etc/mysql /var/lib/mysql
            sudo apt-get autoremove -y
            ;;
        "php")
            PHP_V=$(get_php_version)
            sudo apt-get purge -y "php$PHP_V" "php$PHP_V-*" php-common
            sudo apt-get autoremove -y
            ;;
        "all")
            disable_service "all"
            sudo apt-get purge -y apache2* mysql-server* mysql-client* php*
            sudo apt-get autoremove -y
            ;;
        *) echo -e "${RED}Item inválido.${NC}" ; return ;;
    esac
    echo -e "${GREEN}Desinstalação de '$1' concluída.${NC}"
}

# Lógica principal de argumentos
if [ -z "$1" ]; then
    echo -e "${BLUE}TAMP Manager${NC}"
    echo "  tamp -c | --check            Status"
    echo "  tamp -a | --active [item]    Ativa (all, apache, mysql, php)"
    echo "  tamp -d | --disable [item]   Desativa (all, apache, mysql, php)"
    echo "  tamp -u | --uninstall [item] Remove (all, apache, mysql, php)"
    exit 0
fi

case $1 in
    "-c"|"--check")
        check_status
        ;;
    "-a"|"--active")
        if [ -z "$2" ]; then echo -e "${RED}Especifique o item (all/apache/mysql/php)${NC}"; else active_service "$2"; fi
        ;;
    "-d"|"--disable")
        if [ -z "$2" ]; then echo -e "${RED}Especifique o item (all/apache/mysql/php)${NC}"; else disable_service "$2"; fi
        ;;
    "-u"|"--uninstall")
        if [ -z "$2" ]; then echo -e "${RED}Especifique o item (all/apache/mysql/php)${NC}"; else uninstall_service "$2"; fi
        ;;
    *)
        echo -e "${RED}Comando inválido. Use 'tamp' sem argumentos para ajuda.${NC}"
        ;;
esac
