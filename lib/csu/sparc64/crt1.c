/*-
 * Copyright 2001 David E. O'Brien.
 * All rights reserved.
 * Copyright (c) 1995, 1998 Berkeley Software Design, Inc.
 * All rights reserved.
 * Copyright 1996-1998 John D. Polstra.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the authors may not be used to endorse or promote products
 *    derived from this software without specific prior written permission
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef lint
#ifndef __GNUC__
#error "GCC is needed to compile this file"
#endif
#endif /* lint */

#include <stdlib.h>

#include "libc_private.h"
#include "crtbrand.c"

struct Struct_Obj_Entry;
struct ps_strings;

extern int _DYNAMIC;
#pragma weak _DYNAMIC

typedef void (*fptr)(void);

extern void _fini(void);
extern void _init(void);
extern int main(int, char **, char **);
extern void _start(char **, void (*)(void), struct Struct_Obj_Entry *, 
    struct ps_strings *);
extern void __sparc_utrap_setup(void);

#ifdef GCRT
extern void _mcleanup(void);
extern void monstartup(void *, void *);
extern int eprol;
extern int etext;
#endif

char **environ;
const char *__progname = "";

/*
 * Grab %g1 before it gets used for anything by the compiler.
 * Sparc ELF psABI specifies a termination routine (if any) will be in
 * %g1
 */
static __inline fptr
get_term(void)
{
	fptr retval;

#if 0
#ifdef	__GNUC__
	__asm__ volatile("mov %%g1,%0" : "=r"(retval));
#else
	retval = (fptr)0; /* XXXX Fix this for other compilers */
#endif
#else
	retval = (fptr)0; /* XXXX temporary */
#endif
	return(retval);
}

/* The entry function. */
/*
 * %o0 holds ps_strings pointer.  For Solaris compat and/or shared
 * libraries, if %g1 is not 0, it is a routine to pass to atexit().
 * (By passing the pointer in the usual argument register, we avoid
 * having to do any inline assembly, except to recover %g1.)
 *
 * Note: kernel may (is not set in stone yet) pass ELF aux vector in %o1,
 * but for now we do not use it here.
 */
/* ARGSUSED */
void
_start(char **ap, void (*cleanup)(void), struct Struct_Obj_Entry *obj __unused,
    struct ps_strings *ps_strings __unused)
{
	void (*term)(void);	
	int argc;
	char **argv;
	char **env;
	const char *s;

	term = get_term();

	argc = *(long *)(void *)ap;
	argv = ap + 1;
	env  = ap + 2 + argc;
	environ = env;
	if (argc > 0 && argv[0] != NULL) {
		__progname = argv[0];
		for (s = __progname; *s != '\0'; s++)
			if (*s == '/')
				__progname = s + 1;
	}

	__sparc_utrap_setup();

	/*
	 * If the kernel or a shared library wants us to call
	 * a termination function, arrange to do so.
	 */
	if (term)
		atexit(term);

	if (&_DYNAMIC != NULL)
		atexit(cleanup);

#ifdef GCRT
	atexit(_mcleanup);
#endif
	atexit(_fini);
#ifdef GCRT
	monstartup(&eprol, &etext);
#endif
	_init();
	exit( main(argc, argv, env) );
}

#ifdef GCRT
__asm__(".text");
__asm__("eprol:");
__asm__(".previous");
#endif

__asm__(".ident\t\"$FreeBSD: src/lib/csu/sparc64/crt1.c,v 1.11 2002/09/20 22:23:32 markm Exp $\"");
