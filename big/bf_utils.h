// bf_utils.h
#ifndef __BF_UTILS_H__
#define __BF_UTILS_H__

static struct bf_context_t bf_context;
static int bf_retval;

inline static bf_context_t *get_bf_context(void) {
    return &bf_context;
}

inline static int get_bf_retval (void) {
    return bf_retval;
}

inline static void set_bf_retval (int retval) {
    bf_retval = retval;
}

#endif