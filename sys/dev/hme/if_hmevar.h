/*-
 * Copyright (c) 1999 The NetBSD Foundation, Inc.
 * All rights reserved.
 *
 * This code is derived from software contributed to The NetBSD Foundation
 * by Paul Kranenburg.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *        This product includes software developed by the NetBSD
 *        Foundation, Inc. and its contributors.
 * 4. Neither the name of The NetBSD Foundation nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 *	from: NetBSD: hmevar.h,v 1.5 2000/06/25 01:10:04 eeh Exp
 *
 * $FreeBSD: src/sys/dev/hme/if_hmevar.h,v 1.2 2002/03/23 19:37:11 tmm Exp $
 */

#include <sys/callout.h>

/*
 * Number of receive and transmit descriptors. For each receive descriptor,
 * an mbuf cluster is allocated and set up to receive a packet, and a dma map
 * is created. Therefore, this number should not be too high to not waste
 * memory.
 * TX descriptors have less static cost (a dma map is allocated which could
 * cause bounce buffers to be reserved; other that that, the only required
 * memory is sizeof(struct hme_txdesc)).
 */
#define HME_NRXDESC	128
#define HME_NTXDESC	64

/* Maximum size of a mapped RX buffer. */
#define	HME_BUFSZ	1600

/*
 * RX DMA descriptor. The descriptors are preallocated; the dma map is
 * reused.
 */
struct hme_rxdesc {
	struct mbuf	*hrx_m;
	bus_dmamap_t	hrx_dmamap;
	int		hrx_offs;
	bus_size_t	hrx_len;
};

struct hme_txdesc {
	struct mbuf	*htx_m;
	bus_dmamap_t	htx_dmamap;
	int		htx_flags;
};

/* Value for htx_flags */
#define	HTXF_MAPPED	1

struct hme_ring {
	/* Ring Descriptors */
	caddr_t		rb_membase;	/* Packet buffer: CPU address */
	bus_addr_t	rb_dmabase;	/* Packet buffer: DMA address */
	caddr_t		rb_txd;		/* Transmit descriptors */
	bus_addr_t	rb_txddma;	/* DMA address of same */
	caddr_t		rb_rxd;		/* Receive descriptors */
	bus_addr_t	rb_rxddma;	/* DMA address of same */

	/* Ring Descriptor state */
	int	rb_tdhead, rb_tdtail;
	int	rb_rdtail;
	int	rb_td_nbusy;

	/* Descriptors */
	struct hme_rxdesc rb_rxdesc[HME_NRXDESC];
	struct hme_txdesc rb_txdesc[HME_NTXDESC];

	bus_dmamap_t	rb_spare_dmamap;
};

struct hme_softc {
	struct arpcom	sc_arpcom;
	struct ifmedia	sc_ifmedia;
	device_t	sc_dev;
	device_t	sc_miibus;
	struct mii_data	*sc_mii;	/* MII media control */
	struct callout	sc_tick_ch;	/* tick callout */

	/* The following bus handles are to be provided by the bus front-end */
	bus_dma_tag_t	sc_pdmatag;	/* bus dma parent tag */
	bus_dma_tag_t	sc_cdmatag;	/* control bus dma tag */
	bus_dmamap_t	sc_cdmamap;	/* control bus dma handle */
	bus_dma_tag_t	sc_rdmatag;	/* RX bus dma tag */
	bus_dma_tag_t	sc_tdmatag;	/* RX bus dma tag */
	bus_space_handle_t sc_sebh;	/* HME Global registers */
	bus_space_handle_t sc_erxh;	/* HME ERX registers */
	bus_space_handle_t sc_etxh;	/* HME ETX registers */
	bus_space_handle_t sc_mach;	/* HME MAC registers */
	bus_space_handle_t sc_mifh;	/* HME MIF registers */
	bus_space_tag_t	sc_sebt;	/* HME Global registers */
	bus_space_tag_t	sc_erxt;	/* HME ERX registers */
	bus_space_tag_t	sc_etxt;	/* HME ETX registers */
	bus_space_tag_t	sc_mact;	/* HME MAC registers */
	bus_space_tag_t	sc_mift;	/* HME MIF registers */
	bus_addr_t	sc_sebo;	/* HME Global registers */
	bus_addr_t	sc_erxo;	/* HME ERX registers */
	bus_addr_t	sc_etxo;	/* HME ETX registers */
	bus_addr_t	sc_maco;	/* HME MAC registers */
	bus_addr_t	sc_mifo;	/* HME MIF registers */
	int		sc_burst;	/* DVMA burst size in effect */
	int		sc_phys[2];	/* MII instance -> PHY map */

	int		sc_pci;		/* XXXXX -- PCI buses are LE. */

	/* Ring descriptor */
	struct hme_ring		sc_rb;

	int			sc_debug;

	/* Special hardware hooks */
	void	(*sc_hwreset)(struct hme_softc *);
	void	(*sc_hwinit)(struct hme_softc *);
};

extern devclass_t hme_devclass;

int	hme_config(struct hme_softc *);
void	hme_intr(void *);

/* MII methods & callbacks */
int	hme_mii_readreg(device_t, int, int);
int	hme_mii_writereg(device_t, int, int, int);
void	hme_mii_statchg(device_t);
