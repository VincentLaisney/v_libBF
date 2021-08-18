// bf_utils.h
#ifndef __BF_UTILS_H__
#define __BF_UTILS_H__

// to be able to initialize the three libraries in one context
static struct bf_context_t bf_context;
static struct bf_context_t bf_context_float;
static struct bf_context_t bf_context_dec;
static int bf_retval;

inline static bf_context_t *get_bf_context(void) {
    return &bf_context;
}

inline static bf_context_t *get_bf_context_float(void) {
    return &bf_context_float;
}

inline static bf_context_t *get_bf_context_dec(void) {
    return &bf_context_dec;
}

inline static int get_bf_retval (void) {
    return bf_retval;
}

inline static void set_bf_retval (int retval) {
    bf_retval = retval;
}

#endif