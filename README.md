[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/QtRYN9D3)
[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=23669084)

# Mini Cloud Log Analyzer – Variante C
### Práctica 4.2 | ARM64 Assembly | GNU Assembler 
#### Saenz Gallegos Javier 22210352
---

## Descripción

Programa en ensamblador ARM64 que detecta el primer evento crítico HTTP **503** en un archivo de logs suministrado por stdin.

```bash
cat logs.txt | ./analyzer
```

---

## Salida esperada

| Situación | Salida |
|---|---|
| Se encuentra un 503 | `ALERTA: Primer evento critico 503 en linea <N>` |
| No hay ningún 503 | `INFO: No se encontro ningun evento critico 503.` |

---

## Diseño y lógica

### Flujo general

```
stdin ──► leer byte a byte ──► acumular dígitos por línea
                                      │
                           ¿'\n' o EOF?
                                      │
                            ¿acumulado == 503?
                               /          \
                             SÍ            NO
                              │             │
                        imprimir       siguiente línea
                        nro. línea     y reiniciar
                        + exit(0)
```

### Registros utilizados (callee-saved)

| Registro | Uso |
|---|---|
| `x19` | Número de línea actual (empieza en 1) |
| `x20` | Acumulador numérico del código HTTP de la línea actual |
| `x21` | Flag: 1 si ya se leyó al menos un dígito en la línea |

### Algoritmo de análisis carácter a carácter

1. Se lee un byte por syscall (`read`, nº 63).
2. Si el byte es dígito ASCII (`'0'`–`'9'`), se convierte a valor entero y se acumula:
   ```
   acumulador = acumulador × 10 + dígito
   ```
3. Si el byte es `'\n'` y hubo dígitos:
   - Se compara el acumulador con `503`.
   - Si coincide → se imprime el número de línea y se termina.
   - Si no → se incrementa el contador de línea y se reinician acumulador y flag.
4. Al llegar a EOF se verifica si la última línea (sin `\n` final) es `503`.
5. Si se agota el archivo sin encontrar `503` → se imprime mensaje informativo.

### Conversión entero → ASCII

Para imprimir el número de línea se usa división sucesiva entre 10, construyendo los dígitos de atrás hacia adelante en un búfer local (`num_buf`):

```asm
udiv  x3, x6, x7       // cociente
msub  x2, x3, x7, x6   // resto (dígito actual)
add   w2, w2, #'0'      // convertir a ASCII
```

### Syscalls empleadas

| Nombre | Número | Uso |
|---|---|---|
| `read` | 63 | Leer 1 byte de stdin |
| `write` | 64 | Escribir mensajes a stdout |
| `exit` | 93 | Terminar el proceso |

---

## Compilación

```bash
make          # compila analyzer.s → analyzer
make clean    # elimina objetos y ejecutable
```

## Ejecución

```bash
cat logs.txt | ./analyzer
# o con el script incluido:
./run.sh
./run.sh mi_archivo.log
```

---

## Pruebas

```bash
make test
```

Salida esperada de `make test`:

```
=== Test 1: 503 en línea 3 ===
ALERTA: Primer evento critico 503 en linea 3

=== Test 2: sin ningún 503 ===
INFO: No se encontro ningun evento critico 503.

=== Test 3: 503 en primera línea ===
ALERTA: Primer evento critico 503 en linea 1

=== Test 4: 503 en última línea (sin newline final) ===
ALERTA: Primer evento critico 503 en linea 2
```

---

## Restricciones cumplidas

- ✅ Lógica implementada íntegramente en ARM64 Assembly
- ✅ Sin uso de C, Python ni llamadas a libc
- ✅ Entrada por stdin (compatible con pipe `cat logs.txt | ./analyzer`)
- ✅ Compilado con GNU Assembler (`as`) y enlazado con `ld`
- ✅ Archivo `Makefile` incluido


Restricciones cumplidas
✅ Lógica implementada íntegramente en ARM64 Assembly
✅ Sin uso de C, Python ni llamadas a libc
✅ Entrada por stdin (compatible con pipe cat logs.txt | ./analyzer)
✅ Compilado con GNU Assembler (as) y enlazado con ld
✅ Archivo Makefile incluido

