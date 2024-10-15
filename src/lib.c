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
int inBackslash=-1;


#define IS_CONT(x) (((x) & 0xc0) == 0x80)

/*
 * convert cursor position from utf8 character space to char space eg. πabc -> π_abc since π is 2 chars long
 */
int utf8str_pos(char const* s, int utf8pos) {
    int i=0;
	unsigned char m4 = 128 + 64 + 32 + 16;
	unsigned char m3 = 128 + 64 + 32;
	unsigned char m2 = 128 + 64;
	for (int j=0; j<utf8pos; j++, i++) {
		char c = s[i];
		if ((c & m4) == m4 ) { i += 3; } 
        else if ((c & m3) == m3) { i += 2; } 
        else if ((c & m2) == m2) { i += 1; }
	}
	return i;
}

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

/*
 * Removes current char and replaces with utf8 string
 */
void modify_unicode(char *utf8, int m, char **line, int pos) {
    char* s = *line;
    int n = strlen(s), j=0;
    char *new_s = *line = calloc(n+m+1, 1);

    for (int i=0; i<n; i++) { 
        if (i!=(pos-1)) { new_s[j++] = s[i]; } 
        else { for (int k=0; k<m; k++) { new_s[j++] = utf8[k]; } }
    }
    free(s);
    inBackslash=false;
}

void modify_callback(char** line, int* cursor_pos, void* ud) {
    char* s = *line;
    int pos=utf8str_pos(s, *cursor_pos);
    char p = *(s+(pos-1));

    /* 
     * copy string without \ character 
     */
    if (p=='\\') {
        int n = strlen(s), j=0;
        char *new_s = *line = calloc(n-1, 1 );
        for (int i=0; i<n; i++) { if (i!=(pos-1)) { new_s[j++] = s[i]; } }
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

ReplxxActionResult key_press_handler(int ignored, void* ud) {
   	Replxx* replxx = (Replxx*)ud;
	ReplxxState state;
	replxx_get_state( replxx, &state );
    //get next char
	int l = (int)strlen( state.text );
	/*char* d = strdup( state.text );*/
	/*for ( int i = 0; i < l; ++ i ) {*/
		/*d[i] = toupper( d[i] );*/
	/*}*/
    char pi_utf8[] = {0xCF, 0x80, 0};
	char* d = strdup( pi_utf8 );
	state.text = d;
	/*state.cursorPosition /= 2;*/
	replxx_set_state( replxx, &state );
	free( d );
    return ( REPLXX_ACTION_RESULT_CONTINUE );

    /*if (c == '\\') {*/
        /*// Read next character*/
        /*int next_char = replxx_input_key();*/
        /*if (next_char == 'p') {*/
            /*replxx_insert(replxx, "π");*/
        /*} else {*/
            /*// If not a match, insert both characters*/
            /*char buf[2] = { '\\', 0 };*/
            /*replxx_insert(replxx, buf);*/
            /*buf[0] = (char)next_char;*/
            /*replxx_insert(replxx, buf);*/
        /*}*/
    /*} else {*/
        /*char buf[2] = { c, 0 };*/
        /*replxx_insert(replxx, buf);*/
    /*}*/
}

void init() {
    setlocale(LC_CTYPE, "");
	replxx = replxx_init();
	replxx_install_window_change_handler(replxx);
    replxx_set_modify_callback(replxx, modify_callback, NULL);
    /*replxx_bind_key(replxx, '\\', key_press_handler, replxx);*/
}

const BQNV input() {
    uint32_t buffer[1024] = {0};
    uint32_t *code_points = buffer;
    const char* utf8_bytes=replxx_input(replxx, "   ");

    if (utf8_bytes==NULL) { return bqn_makeF64(0); }

    size_t n=strlen(utf8_bytes);
    while (( *code_points++ = decode_code_point(&utf8_bytes) ));

    return bqn_makeC32Vec(n, buffer);
}

int main(int argc, char* argv[]) {
    init();
    /*while (true) { */
        input();
    /*}*/
    return 0;
}
