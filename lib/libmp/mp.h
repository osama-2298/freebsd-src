/* $FreeBSD: src/lib/libmp/mp.h,v 1.1 2001/07/29 08:49:15 dd Exp $ */

#ifndef _MP_H_
#define _MP_H_

#include <openssl/bn.h>

typedef struct _mint {
	BIGNUM *bn;
} MINT;

void gcd(const MINT *, const MINT *, MINT *);
MINT *itom(short);
void madd(const MINT *, const MINT *, MINT *);
int mcmp(const MINT *, const MINT *);
void mdiv(const MINT *, const MINT *, MINT *, MINT *);
void mfree(MINT *);
void min(MINT *);
void mout(const MINT *);
void move(const MINT *, MINT *);
void msqrt(const MINT *, MINT *, MINT *);
void msub(const MINT *, const MINT *, MINT *);
char *mtox(const MINT *);
void mult(const MINT *, const MINT *, MINT *);
void pow(const MINT *, const MINT *, const MINT *, MINT *);
void rpow(const MINT *, short, MINT *);
void sdiv(const MINT *, short, MINT *, short *);
MINT *xtom(const char *);

#endif /* !_MP_H_ */
