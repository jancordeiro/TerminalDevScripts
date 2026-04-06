#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

#############################
## Get PHP Version Function #
#############################
get_php_version() {
    php -v | head -n 1 | cut -d " " -f 2 | cut -c 1-3 2>/dev/null
}

#########################
## MAIN FUNCTIONS #######
#########################
# (-c)     Check Status
# (-i)     Install
# (-a/-d)  Active/Disable
# (-u)     Uninstall
#########################

check_status() {
    echo -e "${BLUE}--- TAMP STACK STATUS ---${NC}"
    systemctl is-active --quiet apache2 && echo -e "Apache2:  ${GREEN}ON${NC}" || echo -e "Apache2:  ${RED}OFF${NC}"
    systemctl is-active --quiet mysql && echo -e "MySQL:    ${GREEN}ON${NC}" || echo -e "MySQL:    ${RED}OFF${NC}"
    PHP_V=$(get_php_version)
    if [ -n "$PHP_V" ]; then
        systemctl is-active --quiet "php$PHP_V-fpm" && echo -e "PHP $PHP_V:   ${GREEN}ON${NC}" || echo -e "PHP $PHP_V:   ${RED}OFF (or Apache module)${NC}"
    else
        echo -e "PHP:      ${RED}Not Found${NC}"
    fi
}

install_service() {
    sudo apt-get update
    case $1 in
        "apache")
            echo -e "${CYAN}Installing Apache2...${NC}"
            sudo apt-get install -y apache2
            ;;
        "mysql")
            echo -e "${CYAN}Installing MySQL Server...${NC}"
            sudo apt-get install -y mysql-server
            ;;
        "php")
            echo -e "${CYAN}Installing PHP and common extensions...${NC}"
            sudo apt-get install -y php libapache2-mod-php php-mysql php-gd php-mbstring php-xml php-curl
            ;;
        "all")
            echo -e "${BLUE}Installint Complete TAMP Stack...${NC}"
            sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql php-gd php-mbstring php-xml php-curl
            ;;
        *) echo -e "${RED}Invalid item for instalation.${NC}" ; return ;;
    esac
    echo -e "${GREEN}Instalation of '$1' done!${NC}"
}

active_service() {
    case $1 in
        "apache") sudo systemctl start apache2 ;;
        "mysql")  sudo systemctl start mysql ;;
        "php")    sudo systemctl start "php$(get_php_version)-fpm" 2>/dev/null ;;
        "all")    
            sudo systemctl start apache2 mysql
            sudo systemctl start "php$(get_php_version)-fpm" 2>/dev/null
            ;;
    esac
    echo -e "${GREEN}Serviço(s) '$1' ativado(s).${NC}"
}

disable_service() {
    case $1 in
        "apache") sudo systemctl stop apache2 ;;
        "mysql")  sudo systemctl stop mysql ;;
        "php")    sudo systemctl stop "php$(get_php_version)-fpm" 2>/dev/null ;;
        "all")    
            sudo systemctl stop apache2 mysql
            sudo systemctl stop "php$(get_php_version)-fpm" 2>/dev/null
            ;;
    esac
    echo -e "${YELLOW}Serviço(s) '$1' encerrado(s).${NC}"
}

uninstall_service() {
    echo -e "${RED}CUIDADO: Isso removerá pacotes e configurações de: $1${NC}"
    read -p "Confirmar desinstalação? (s/n): " confirm
    if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
        echo -e "${BLUE}Operação cancelada.${NC}"
        return
    fi

    case $1 in
        "apache") sudo apt-get purge -y apache2* ; sudo apt-get autoremove -y ;;
        "mysql")  sudo apt-get purge -y mysql-server* mysql-client* ; sudo rm -rf /etc/mysql /var/lib/mysql ; sudo apt-get autoremove -y ;;
        "php")    sudo apt-get purge -y php* ; sudo apt-get autoremove -y ;;
        "all")    
            disable_service "all"
            sudo apt-get purge -y apache2* mysql-server* mysql-client* php*
            sudo apt-get autoremove -y
            ;;
    esac
    echo -e "${GREEN}Desinstalação de '$1' concluída.${NC}"
}

# --- LÓGICA DE ARGUMENTOS ---

if [ -z "$1" ]; then
    echo -e "${BLUE}TAMP Manager - Terminal Apache, MySQL and PHP${NC}"
    echo "  tamp -i | --install [item]   Instala (all, apache, mysql, php)"
    echo "  tamp -c | --check            Verifica Status"
    echo "  tamp -a | --active [item]    Ativa (all, apache, mysql, php)"
    echo "  tamp -d | --disable [item]   Desativa (all, apache, mysql, php)"
    echo "  tamp -u | --uninstall [item] Remove (all, apache, mysql, php)"
    exit 0
fi

case $1 in
    "-i"|"--install")
        if [ -z "$2" ]; then echo -e "${RED}Especifique o item.${NC}"; else install_service "$2"; fi ;;
    "-c"|"--check")
        check_status ;;
    "-a"|"--active")
        if [ -z "$2" ]; then echo -e "${RED}Especifique o item.${NC}"; else active_service "$2"; fi ;;
    "-d"|"--disable")
        if [ -z "$2" ]; then echo -e "${RED}Especifique o item.${NC}"; else disable_service "$2"; fi ;;
    "-u"|"--uninstall")
        if [ -z "$2" ]; then echo -e "${RED}Especifique o item.${NC}"; else uninstall_service "$2"; fi ;;
    *)
        echo -e "${RED}Comando inválido. Use 'tamp' para ajuda.${NC}" ;;
esac
