# ============================================================
# Makefile – Mini Cloud Log Analyzer  |  Variante C
# Compilación para ARM64 Linux con GNU Assembler
# ============================================================

AS      = as
LD      = ld
ASFLAGS = -g                        # info de depuración (opcional)
LDFLAGS =                           # sin flags extra necesarios
TARGET  = analyzer
SRC     = analyzer.s

.PHONY: all clean run test

all: $(TARGET)

# Ensamblar: .s → .o
$(TARGET).o: $(SRC)
	$(AS) $(ASFLAGS) -o $@ $<

# Enlazar: .o → ejecutable
$(TARGET): $(TARGET).o
	$(LD) $(LDFLAGS) -o $@ $<

# Ejecutar con el archivo de logs de ejemplo
run: $(TARGET)
	cat logs.txt | ./$(TARGET)

# Prueba rápida (sin logs.txt externo)
test: $(TARGET)
	@echo "=== Test 1: 503 en línea 3 ==="
	@printf "200\n404\n503\n200\n" | ./$(TARGET)
	@echo "=== Test 2: sin ningún 503 ==="
	@printf "200\n201\n404\n400\n" | ./$(TARGET)
	@echo "=== Test 3: 503 en primera línea ==="
	@printf "503\n200\n" | ./$(TARGET)
	@echo "=== Test 4: 503 en última línea (sin newline final) ==="
	@printf "200\n503" | ./$(TARGET)

clean:
	rm -f $(TARGET).o $(TARGET)
