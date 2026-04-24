// ============================================================
// Práctica 4.2 – Mini Cloud Log Analyzer  |  Variante C
// Detectar el primer evento crítico (código HTTP 503)
//
// Descripción:
//   Lee líneas de stdin una por una (byte a byte). En cuanto
//   encuentra la primera línea que contiene exactamente el
//   código HTTP 503, imprime el número de línea en que ocurrió
//   y termina. Si se llega al EOF sin encontrar un 503, se
//   informa que no hubo ningún evento crítico.
//
// Uso:
//   cat logs.txt | ./analyzer
//
// Convenciones AArch64 Linux (AAPCS64):
//   x0–x7   : argumentos y valores de retorno (caller-saved)
//   x8       : número de syscall (uso especial en Linux)
//   x9–x15  : temporales (caller-saved)
//   x19–x28 : variables persistentes (callee-saved)
//   x29 (fp): frame pointer  |  x30 (lr): link register
//   x31 (sp): stack pointer  |  xzr: cero
//
// Syscalls usadas (ARM64 Linux):
//   63  = read(fd, buf*, count)
//   64  = write(fd, buf*, count)
//   93  = exit(code)
// ============================================================

// ── Constantes ──────────────────────────────────────────────
    .equ SYS_READ,   63
    .equ SYS_WRITE,  64
    .equ SYS_EXIT,   93
    .equ STDIN,       0
    .equ STDOUT,      1
    .equ TARGET_CODE, 503

// ── Datos de sólo lectura ───────────────────────────────────
    .section .rodata
    .align 3

msg_alert:
    .ascii "ALERTA: Primer evento critico 503 en linea "
    .equ   MSG_ALERT_LEN, . - msg_alert

msg_nl:
    .ascii "\n"

msg_none:
    .ascii "INFO: No se encontro ningun evento critico 503.\n"
    .equ   MSG_NONE_LEN, . - msg_none

// ── Datos en BSS ────────────────────────────────────────────
    .section .bss
    .align 3
char_buf:   .skip 1
num_buf:    .skip 24

// ── Código ──────────────────────────────────────────────────
    .section .text
    .global _start

// ============================================================
// _start: punto de entrada
//
// Registros callee-saved usados:
//   x19 = número de línea actual (empieza en 1)
//   x20 = acumulador numérico del código de la línea actual
//   x21 = 1 si ya leímos al menos un dígito en la línea, 0 si no
// ============================================================
_start:
    mov     x19, #1
    mov     x20, #0
    mov     x21, #0

// ──────────────────────────────────────────────────────
// read_loop: leer un byte por iteración
// ──────────────────────────────────────────────────────
read_loop:
    mov     x8,  #SYS_READ
    mov     x0,  #STDIN
    adr     x1,  char_buf
    mov     x2,  #1
    svc     #0
    cmp     x0, #0
    ble     handle_eof

    adr     x1,  char_buf
    ldrb    w9,  [x1]

    // ¿Es dígito?
    cmp     w9,  #'0'
    blt     check_newline
    cmp     w9,  #'9'
    bgt     check_newline

    // Acumular dígito
    mov     x21, #1
    sub     w9,  w9,  #'0'
    mov     x10, #10
    mul     x20, x20, x10
    uxtw    x9,  w9
    add     x20, x20, x9
    b       read_loop

check_newline:
    cmp     w9,  #'\n'
    bne     read_loop

    cbz     x21, advance_line

    mov     x10, #TARGET_CODE
    cmp     x20, x10
    beq     found_503

advance_line:
    add     x19, x19, #1
    mov     x20, #0
    mov     x21, #0
    b       read_loop

// ──────────────────────────────────────────────────────
// handle_eof
// ──────────────────────────────────────────────────────
handle_eof:
    cbz     x21, print_none
    mov     x10, #TARGET_CODE
    cmp     x20, x10
    beq     found_503
    b       print_none

// ──────────────────────────────────────────────────────
// found_503: imprimir mensaje con número de línea (x19)
// ──────────────────────────────────────────────────────
found_503:
    // Mensaje de alerta
    mov     x8,  #SYS_WRITE
    mov     x0,  #STDOUT
    adr     x1,  msg_alert
    mov     x2,  #MSG_ALERT_LEN
    svc     #0

    // Convertir x19 → ASCII en num_buf (de atrás hacia adelante)
    adr     x4,  num_buf
    add     x5,  x4,  #20
    mov     x6,  x19
    mov     x7,  #10

digit_loop:
    udiv    x3,  x6,  x7
    msub    x2,  x3,  x7,  x6
    add     w2,  w2,  #'0'
    sub     x5,  x5,  #1
    strb    w2,  [x5]
    mov     x6,  x3
    cbnz    x6,  digit_loop

    // Longitud de la cadena
    adr     x4,  num_buf
    add     x4,  x4,  #20
    sub     x2,  x4,  x5

    // Escribir número
    mov     x8,  #SYS_WRITE
    mov     x0,  #STDOUT
    mov     x1,  x5
    svc     #0

    // Salto de línea
    mov     x8,  #SYS_WRITE
    mov     x0,  #STDOUT
    adr     x1,  msg_nl
    mov     x2,  #1
    svc     #0

    mov     x8,  #SYS_EXIT
    mov     x0,  #0
    svc     #0

// ──────────────────────────────────────────────────────
// print_none
// ──────────────────────────────────────────────────────
print_none:
    mov     x8,  #SYS_WRITE
    mov     x0,  #STDOUT
    adr     x1,  msg_none
    mov     x2,  #MSG_NONE_LEN
    svc     #0

    mov     x8,  #SYS_EXIT
    mov     x0,  #0
    svc     #0
