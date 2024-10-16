#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <wchar.h>
#include <locale.h>
#include "replxx.h"
#include "bqnffi.h"

Replxx* replxx;
typedef   int8_t i8; typedef  uint8_t u8; typedef  int16_t i16; typedef uint16_t u16; typedef  int32_t i32; typedef uint32_t u32; typedef  int64_t i64; typedef uint64_t u64; typedef double   f64; typedef float    f32; typedef size_t ux;
bool inBackslash=false;


#define IS_CONT(x) (((x) & 0xc0) == 0x80)

/*
 * convert cursor position from utf8 character space to char space eg. πabc -> π_abc since π is 2 chars long
 */
i32 utf8str_pos(char const* s, i32 utf8pos) {
    i32 i=0;
	unsigned char m4 = 128 + 64 + 32 + 16;
	unsigned char m3 = 128 + 64 + 32;
	unsigned char m2 = 128 + 64;
	for (i32 j=0; j<utf8pos; j++, i++) {
		char c = s[i];
		if ((c & m4) == m4 ) { i += 3; } 
        else if ((c & m3) == m3) { i += 2; } 
        else if ((c & m2) == m2) { i += 1; }
	}
	return i;
}

i32 decode_code_point(const char **s) {
    i32 k = **s ? __builtin_clz(~(**s << 24)) : 0; // Count # of leading 1 bits.
    i32 mask = (1 << (8 - k)) - 1;                 // All 1s with k leading 0s.
    i32 value = **s & mask;
    // k = 0 for one-byte code points; otherwise, k = #total bytes.
    for (++(*s), --k; k > 0 && IS_CONT(**s); --k, ++(*s)) {
        value <<= 6;
        value += (**s & 0x3F);
    }
    return value;
}

/*
 * Removes current char and replaces with utf8 string
 */
void modify_unicode(char *utf8, i32 m, char **line, i32 pos) {
    char* s = *line;
    i32 n = strlen(s), j=0;
    char *new_s = *line = calloc(n+m+1, 1);

    for (i32 i=0; i<n; i++) { 
        if (i!=(pos-1)) { new_s[j++] = s[i]; } 
        else { for (i32 k=0; k<m; k++) { new_s[j++] = utf8[k]; } }
    }
    free(s);
    inBackslash=false;
}

void modify_callback(char** line, i32* cursor_pos, void* ud) {
    char* s = *line;
    i32 pos=utf8str_pos(s, *cursor_pos);
    char p = *(s+(pos-1));

    /* 
     * copy string without \ character 
     */
    if (p=='\\') {
        i32 n = strlen(s), j=0;
        char *new_s = *line = calloc(n-1, 1 );
        for (i32 i=0; i<n; i++) { if (i!=(pos-1)) { new_s[j++] = s[i]; } }
        *cursor_pos-=1;
        inBackslash=true;
    }

    if (inBackslash) {
        switch (p) {
            case 'p': { char utf8[]={0xCF,0x80     }; modify_unicode(utf8, 2, line, pos); break; }
            case '[': { char utf8[]={0xE2,0x86,0x90}; modify_unicode(utf8, 3, line, pos); break; }
        }
    }
}

void init() {
    setlocale(LC_CTYPE, "");
	replxx = replxx_init();
	replxx_install_window_change_handler(replxx);
    replxx_set_modify_callback(replxx, modify_callback, NULL);
}

const BQNV input() {
    u32 buffer[1024] = {0};
    u32 *code_points = buffer;
    const char* utf8_bytes=replxx_input(replxx, "   ");

    if (utf8_bytes==NULL) { return bqn_makeF64(0); }

    ux n=strlen(utf8_bytes);
    while (( *code_points++ = decode_code_point(&utf8_bytes) ));

    return bqn_makeC32Vec(n, buffer);
}

i32 main(i32 argc, char* argv[]) {
    init();
    /*while (true) { */
        input();
    /*}*/
    return 0;
}
