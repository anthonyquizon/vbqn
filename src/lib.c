#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <wchar.h>
#include <locale.h>
#include "replxx.h"
#include "bqnffi.h"

Replxx* replxx;

void init() {
    setlocale(LC_CTYPE, "");
	replxx = replxx_init();
	replxx_install_window_change_handler(replxx);
}

#define IS_CONT(x) (((x) & 0xc0) == 0x80)

int decode_code_point(const char **s) {
    int k = **s ? __builtin_clz(~(**s << 24)) : 0; // Count # of leading 1 bits.
    int mask = (1 << (8 - k)) - 1;                 // All 1s with k leading 0s.
    int value = **s & mask;
    // k = 0 for one-byte code points; otherwise, k = #total bytes.
    for (++(*s), --k; k > 0 && IS_CONT(**s); --k, ++(*s)) {
        value <<= 6;
        value += (**s & 0x3F);
    }
    return value;
}


const BQNV input(int *out) {
    uint32_t buffer[1024] = {0};
    uint32_t *code_points = buffer;
    const char* utf8_bytes=replxx_input(replxx, "   ");
    size_t shape[3] = {1};

    if (utf8_bytes==NULL) { return 0; }

    while (( *code_points++ = decode_code_point(&utf8_bytes) ));

    return bqn_makeC32Arr(1, shape, buffer);
}

