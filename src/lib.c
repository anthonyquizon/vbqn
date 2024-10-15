#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <wchar.h>
#include <locale.h>
#include "replxx.h"
#include "bqnffi.h"

Replxx* replxx;
bool inBackslash=false;


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

void modify_callback(char** line, int* cursorPosition, void* ud) {
	char* s = *line;
	char* p = strchr( s, '\\' );

    /*printf("%s\n", s);*/

    /*return;*/
    /*if (inBackslash){*/
        /*printf("backslash done\n");*/
        /*cursorPosition -= 1;*/
        /*inBackslash=false;*/
    /*}*/
    /*else if (p) {*/
        /*inBackslash=true;*/
		/*[>int len = (int)strlen( s );<]*/
		/*[>char* n = *line = calloc( len * 2, 1 );<]*/
		/*[>int i = (int)( p - s );<]*/
		/*[>strncpy(n, s, i);<]*/
		/*[>n += i;<]*/
		/*[>strncpy(n, s, i);<]*/
		/*[>n += i;<]*/
		/*[>strncpy(n, p + 1, len - i - 1);<]*/
		/*[>n += ( len - i - 1 );<]*/
		/*[>strncpy(n, p + 1, len - i - 1);<]*/
		/*[>*cursorPosition *= 2;<]*/
		/*[>free( s );<]*/
	/*}*/
}

void init() {
    setlocale(LC_CTYPE, "");
	replxx = replxx_init();
	replxx_install_window_change_handler(replxx);
    replxx_set_modify_callback(replxx, modify_callback, NULL);
}

const BQNV input(int *out) {
    uint32_t buffer[1024] = {0};
    uint32_t *code_points = buffer;
    const char* utf8_bytes=replxx_input(replxx, "   ");

    if (utf8_bytes==NULL) { return bqn_makeF64(0); }

    size_t n=strlen(utf8_bytes);
    while (( *code_points++ = decode_code_point(&utf8_bytes) ));

    return bqn_makeC32Vec(n, buffer);
}

