#!/bin/bash

# Script di monitoring per Open-LLM-VTuber

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurazioni
SERVICE_NAME="open-llm-vtuber"
PORT=12393
LOG_FILE="/var/log/vtuber-monitor.log"

# Funzioni di utility
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_service() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}✅ Servizio $SERVICE_NAME è attivo${NC}"
        return 0
    else
        echo -e "${RED}❌ Servizio $SERVICE_NAME non è attivo${NC}"
        return 1
    fi
}

check_port() {
    if netstat -tuln | grep -q ":$PORT "; then
        echo -e "${GREEN}✅ Porta $PORT è in ascolto${NC}"
        return 0
    else
        echo -e "${RED}❌ Porta $PORT non è in ascolto${NC}"
        return 1
    fi
}

check_health() {
    if curl -sf "http://localhost:$PORT/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Health check OK${NC}"
        return 0
    else
        echo -e "${RED}❌ Health check fallito${NC}"
        return 1
    fi
}

check_memory() {
    local pid=$(pgrep -f "run_server.py")
    if [ -n "$pid" ]; then
        local memory=$(ps -p "$pid" -o rss= | awk '{print $1/1024}')
        echo -e "${GREEN}📊 Memoria utilizzata: ${memory}MB${NC}"
        
        # Alert se memoria > 2GB
        if (( $(echo "$memory > 2048" | bc -l) )); then
            echo -e "${YELLOW}⚠️ Attenzione: Uso memoria elevato${NC}"
            log "WARNING: High memory usage: ${memory}MB"
        fi
    else
        echo -e "${RED}❌ Processo non trovato${NC}"
    fi
}

check_disk() {
    local usage=$(df /opt/open-llm-vtuber | awk 'NR==2 {print $5}' | sed 's/%//')
    echo -e "${GREEN}💾 Uso disco: ${usage}%${NC}"
    
    # Alert se disco > 80%
    if [ "$usage" -gt 80 ]; then
        echo -e "${YELLOW}⚠️ Attenzione: Spazio disco basso${NC}"
        log "WARNING: Low disk space: ${usage}%"
    fi
}

check_logs() {
    local errors=$(tail -n 100 /opt/open-llm-vtuber/logs/debug_*.log 2>/dev/null | grep -i error | wc -l)
    echo -e "${GREEN}📝 Errori recenti nei log: $errors${NC}"
    
    if [ "$errors" -gt 10 ]; then
        echo -e "${YELLOW}⚠️ Attenzione: Molti errori nei log${NC}"
        log "WARNING: High error count in logs: $errors"
    fi
}

restart_service() {
    echo -e "${YELLOW}🔄 Riavviando il servizio...${NC}"
    systemctl restart "$SERVICE_NAME"
    sleep 10
    
    if check_service && check_health; then
        echo -e "${GREEN}✅ Servizio riavviato con successo${NC}"
        log "INFO: Service restarted successfully"
    else
        echo -e "${RED}❌ Errore nel riavvio del servizio${NC}"
        log "ERROR: Service restart failed"
    fi
}

# Monitoring completo
full_check() {
    echo "🔍 Controllo completo del sistema..."
    echo "=================================="
    
    local issues=0
    
    check_service || ((issues++))
    check_port || ((issues++))
    check_health || ((issues++))
    check_memory
    check_disk
    check_logs
    
    echo "=================================="
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✅ Tutti i controlli superati!${NC}"
        log "INFO: All checks passed"
    else
        echo -e "${RED}❌ Trovati $issues problemi${NC}"
        log "WARNING: Found $issues issues"
        
        # Auto-restart se ci sono problemi critici
        if [ $issues -ge 2 ]; then
            echo -e "${YELLOW}🔄 Tentativo di auto-riparazione...${NC}"
            restart_service
        fi
    fi
}

# Comando principale
case "${1:-check}" in
    "check")
        full_check
        ;;
    "restart")
        restart_service
        ;;
    "logs")
        tail -f /opt/open-llm-vtuber/logs/debug_*.log
        ;;
    "status")
        systemctl status "$SERVICE_NAME"
        ;;
    *)
        echo "Uso: $0 {check|restart|logs|status}"
        echo "  check   - Controllo completo del sistema"
        echo "  restart - Riavvia il servizio"
        echo "  logs    - Mostra i log in tempo reale"
        echo "  status  - Mostra lo status del servizio"
        exit 1
        ;;
esac
