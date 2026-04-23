#!/usr/bin/env bash
# ============================================================
# run.sh – Script de ejecución del analizador de logs
# Uso: ./run.sh [archivo_de_logs]
# ============================================================
set -euo pipefail
 
ANALYZER="./analyzer"
LOG_FILE="${1:-logs.txt}"
 
if [[ ! -f "$ANALYZER" ]]; then
   echo "[ERROR] El ejecutable '$ANALYZER' no existe. Ejecuta 'make' primero."
   exit 1
fi
 
if [[ ! -f "$LOG_FILE" ]]; then
   echo "[ERROR] Archivo de logs '$LOG_FILE' no encontrado."
   exit 1
fi
 
echo "=== Cloud Log Analyzer – Variante C ==="
echo "Analizando: $LOG_FILE"
echo "----------------------------------------"
cat "$LOG_FILE" | "$ANALYZER"
echo "----------------------------------------"
