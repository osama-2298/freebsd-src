#
# Copyright (c) 1998-2001 Sendmail, Inc. and its suppliers.
#	All rights reserved.
# Copyright (c) 1983, 1995 Eric P. Allman.  All rights reserved.
# Copyright (c) 1988, 1993
#	The Regents of the University of California.  All rights reserved.
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the sendmail distribution.
#
# $FreeBSD: src/contrib/sendmail/cf/m4/cfhead.m4,v 1.3.6.3 2001/03/06 01:38:23 gshapiro Exp $
#

######################################################################
######################################################################
#####
#####		SENDMAIL CONFIGURATION FILE
#####
ifdef(`unix', `dnl
ifdef(`TEMPFILE', `dnl', `define(`TEMPFILE', maketemp(/tmp/cfXXXXXX))dnl
syscmd(sh _CF_DIR_`'sh/makeinfo.sh _CF_DIR_ > TEMPFILE)dnl
include(TEMPFILE)dnl
syscmd(rm -f TEMPFILE)dnl')', `dnl')
#####
######################################################################
######################################################################

divert(-1)

changecom()
undefine(`format')
undefine(`hpux')
ifdef(`pushdef', `',
	`errprint(`You need a newer version of M4, at least as new as
System V or GNU')
	include(NoSuchFile)')
define(`PUSHDIVERT', `pushdef(`__D__', divnum)divert($1)')
define(`POPDIVERT', `divert(__D__)popdef(`__D__')')
define(`OSTYPE',
	`PUSHDIVERT(-1)
	ifdef(`__OSTYPE__', `errprint(`duplicate OSTYPE'($1)
)')
	define(`__OSTYPE__', $1)
	define(`_ARG_', $2)
	include(_CF_DIR_`'ostype/$1.m4)POPDIVERT`'')
## helpful functions
define(`lower', `translit(`$1', `ABCDEFGHIJKLMNOPQRSTUVWXYZ', `abcdefghijklmnopqrstuvwx')')
define(`strcasecmp', `ifelse(lower($1), lower($2), `1', `0')')
## new FEATUREs
define(`_DNSBL_R_',`')
## access to further arguments in FEATURE/HACK
define(`_ACC_ARG_1_',`$1')
define(`_ACC_ARG_2_',`$2')
define(`_ACC_ARG_3_',`$3')
define(`_ACC_ARG_4_',`$4')
define(`_ACC_ARG_5_',`$5')
define(`_ACC_ARG_6_',`$6')
define(`_ACC_ARG_7_',`$7')
define(`_ACC_ARG_8_',`$8')
define(`_ACC_ARG_9_',`$9')
define(`_ARG1_',`_ACC_ARG_1_(_ARGS_)')
define(`_ARG2_',`_ACC_ARG_2_(_ARGS_)')
define(`_ARG3_',`_ACC_ARG_3_(_ARGS_)')
define(`_ARG4_',`_ACC_ARG_4_(_ARGS_)')
define(`_ARG5_',`_ACC_ARG_5_(_ARGS_)')
define(`_ARG6_',`_ACC_ARG_6_(_ARGS_)')
define(`_ARG7_',`_ACC_ARG_7_(_ARGS_)')
define(`_ARG8_',`_ACC_ARG_8_(_ARGS_)')
define(`_ARG9_',`_ACC_ARG_9_(_ARGS_)')
dnl define if not yet defined: if `$1' is not defined it will be `$2'
define(`_DEFIFNOT',`ifdef(`$1',`',`define(`$1',`$2')')')
dnl ----------------------------------------
dnl add a char $2 to a string $1 if it is not there
define(`_ADDCHAR_',`define(`_I_',`eval(index(`$1',`$2') >= 0)')`'ifelse(_I_,`1',`$1',`$1$2')')
dnl ----
dnl delete a char $2 from a string $1 if it is there
define(`_DELCHAR_',`define(`_IDX_',`index(`$1',`$2')')`'define(`_I_',`eval(_IDX_ >= 0)')`'ifelse(_I_,`1',`substr(`$1',0,_IDX_)`'substr(`$1',eval(_IDX_+1))',`$1')')
dnl ----
dnl apply a macro to a whole string by recursion (one char at a time)
dnl $1: macro
dnl $2: first argument to macro
dnl $3: list that is split up into characters
define(`_AP_',`ifelse(`$3',`',`$2',`_AP_(`$1',$1(`$2',substr(`$3',0,1)),substr(`$3',1))')')
dnl ----
dnl MODIFY_MAILER_FLAGS: append tail of $2 to $1_MF_A/D_
dnl A if head($2) = +
dnl D if head($2) = -
dnl $1_MF_ is set otherwise; set _A/D_ to `'
define(`MODIFY_MAILER_FLAGS',`define(`_hd_',`substr(`$2',0,1)')define(`_tl_',`substr(`$2',1)')`'ifelse(_hd_,`+',`ifdef($1`'_MF_A_, `define($1`'_MF_A_,$1_MF_A_`'_tl_)', `define($1`'_MF_A_, _tl_)')',_hd_,`-',`ifdef($1`'_MF_D_, `define($1`'_MF_D_,$1_MF_D_`'_tl_)', `define($1`'_MF_D_,_tl_)')',`define($1`'_MF_,`$2')define($1`'_MF_A_,`')define($1`'_MF_D_,`')')')
dnl ----
dnl actually modify flags:
dnl $1: flags (strings) to modify
dnl $2: name of flags (just first part) to modify
dnl WARNING: the order might be important: if someone adds and delete the
dnl same characters, he does not deserve any better, does he?
dnl this could be coded more efficiently... (do not apply the macro if _MF_A/D_ is undefined)
define(`_MODMF_',`ifdef($2`'_MF_,`$2_MF_',`_AP_(`_ADDCHAR_',_AP_(`_DELCHAR_',$1,ifdef($2`'_MF_D_,`$2_MF_D_',`')),ifdef($2`'_MF_A_,`$2_MF_A_',`'))')')
dnl usage:
dnl MODIFY_MAILER_FLAGS(`LOCAL',`+FlaGs')dnl
dnl in MAILER.m4: _MODMF_(LMF,`LOCAL')
dnl ----------------------------------------
define(`MAILER',
`define(`_M_N_', `ifelse(`$2', `', `$1', `$2')')dnl
ifdef(_MAILER_`'_M_N_`'_, `dnl`'',
`define(_MAILER_`'_M_N_`'_, `')define(`_ARG_', `$2')define(`_ARGS_', `shift($@)')PUSHDIVERT(7)include(_CF_DIR_`'mailer/$1.m4)POPDIVERT`'')')
define(`DOMAIN', `PUSHDIVERT(-1)define(`_ARG_', `$2')include(_CF_DIR_`'domain/$1.m4)POPDIVERT`'')
define(`FEATURE', `PUSHDIVERT(-1)define(`_ARG_', `$2')define(`_ARGS_', `shift($@)')include(_CF_DIR_`'feature/$1.m4)POPDIVERT`'')
define(`HACK', `PUSHDIVERT(-1)define(`_ARG_', `$2')define(`_ARGS_', `shift($@)')include(_CF_DIR_`'hack/$1.m4)POPDIVERT`'')
define(`_DPO_',`')
define(`DAEMON_OPTIONS', `define(`_DPO_', defn(`_DPO_')
O DaemonPortOptions=`$1')')
define(`_MAIL_FILTERS_', `')
define(`MAIL_FILTER', `define(`_MAIL_FILTERS_', defn(`_MAIL_FILTERS_')
X`'$1`, '`$2')')
define(`INPUT_MAIL_FILTER', `MAIL_FILTER(`$1', `$2')
ifelse(defn(`confINPUT_MAIL_FILTERS')X, `X',
`define(`confINPUT_MAIL_FILTERS', $1)',
`define(`confINPUT_MAIL_FILTERS', defn(`confINPUT_MAIL_FILTERS')`, '`$1')')')
define(`CF_LEVEL', `9')dnl
define(`VERSIONID', ``#####  $1  #####'')
define(`LOCAL_RULE_0', `divert(3)')
define(`LOCAL_RULE_1',
`divert(9)dnl
#######################################
###  Ruleset 1 -- Sender Rewriting  ###
#######################################

Ssender=1
')
define(`LOCAL_RULE_2',
`divert(9)dnl
##########################################
###  Ruleset 2 -- Recipient Rewriting  ###
##########################################

Srecipient=2
')
define(`LOCAL_RULESETS',
`divert(9)

')
define(`LOCAL_RULE_3', `divert(2)')
define(`LOCAL_CONFIG', `divert(6)')
define(`MAILER_DEFINITIONS', `divert(7)')
define(`LOCAL_NET_CONFIG', `define(`_LOCAL_RULES_', 1)divert(1)')
define(`UUCPSMTP', `R DOL(*) < @ $1 .UUCP > DOL(*)	DOL(1) < @ $2 > DOL(2)')
define(`CONCAT', `$1$2$3$4$5$6$7')
define(`DOL', ``$'$1')
define(`SITECONFIG',
`CONCAT(D, $3, $2)
define(`_CLASS_$3_', `')dnl
ifelse($3, U, Cw$2 $2.UUCP, `dnl')
define(`SITE', `ifelse(CONCAT($'2`, $3), SU,
		CONCAT(CY, $'1`),
		CONCAT(C, $3, $'1`))')
sinclude(_CF_DIR_`'siteconfig/$1.m4)')
define(`EXPOSED_USER', `PUSHDIVERT(5)C{E}$1
POPDIVERT`'dnl`'')
ifdef(`_FFR_EXPOSED_USER_FILE', `define(`EXPOSED_USER_FILE', `PUSHDIVERT(5)F{E}$1
POPDIVERT`'dnl`'')', `dnl')
define(`LOCAL_USER', `PUSHDIVERT(5)C{L}$1
POPDIVERT`'dnl`'')
define(`MASQUERADE_AS', `define(`MASQUERADE_NAME', $1)')
define(`MASQUERADE_DOMAIN', `PUSHDIVERT(5)C{M}$1
POPDIVERT`'dnl`'')
define(`MASQUERADE_EXCEPTION', `PUSHDIVERT(5)C{N}$1
POPDIVERT`'dnl`'')
define(`MASQUERADE_DOMAIN_FILE', `PUSHDIVERT(5)F{M}$1
POPDIVERT`'dnl`'')
define(`LOCAL_DOMAIN', `PUSHDIVERT(5)C{w}$1
POPDIVERT`'dnl`'')
define(`CANONIFY_DOMAIN', `PUSHDIVERT(5)C{Canonify}$1
POPDIVERT`'dnl`'')
define(`CANONIFY_DOMAIN_FILE', `PUSHDIVERT(5)F{Canonify}$1
POPDIVERT`'dnl`'')
define(`GENERICS_DOMAIN', `PUSHDIVERT(5)C{G}$1
POPDIVERT`'dnl`'')
define(`GENERICS_DOMAIN_FILE', `PUSHDIVERT(5)F{G}$1
POPDIVERT`'dnl`'')
define(`LDAPROUTE_DOMAIN', `PUSHDIVERT(5)C{LDAPRoute}$1
POPDIVERT`'dnl`'')
define(`LDAPROUTE_DOMAIN_FILE', `PUSHDIVERT(5)F{LDAPRoute}$1
POPDIVERT`'dnl`'')
define(`VIRTUSER_DOMAIN', `PUSHDIVERT(5)C{VirtHost}$1
define(`_VIRTHOSTS_')
POPDIVERT`'dnl`'')
define(`VIRTUSER_DOMAIN_FILE', `PUSHDIVERT(5)F{VirtHost}$1
define(`_VIRTHOSTS_')
POPDIVERT`'dnl`'')
define(`RELAY_DOMAIN', `PUSHDIVERT(5)C{R}$1
POPDIVERT`'dnl`'')
define(`RELAY_DOMAIN_FILE', `PUSHDIVERT(5)F{R}$1
POPDIVERT`'dnl`'')
define(`TRUST_AUTH_MECH', `PUSHDIVERT(5)C{TrustAuthMech}$1
POPDIVERT`'dnl`'')
define(`_OPTINS', `ifdef(`$1', `$2$1$3')')


m4wrap(`include(_CF_DIR_`m4/proto.m4')')

# default location for files
ifdef(`MAIL_SETTINGS_DIR', , `define(`MAIL_SETTINGS_DIR', `/etc/mail/')')

# set our default hashed database type
define(`DATABASE_MAP_TYPE', `hash')

# set up default values for options
define(`ALIAS_FILE', `MAIL_SETTINGS_DIR`'aliases')
define(`confMAILER_NAME', ``MAILER-DAEMON'')
define(`confFROM_LINE', `From $g $d')
define(`confOPERATORS', `.:%@!^/[]+')
define(`confSMTP_LOGIN_MSG', `$j Sendmail $v/$Z; $b')
define(`_REC_AUTH_', `$.$?{auth_type}(authenticated')
define(`_REC_FULL_AUTH_', `$.$?{auth_type}(authenticated as ${auth_authen} $?{auth_author}for ${auth_author} $.with ${auth_type}')
define(`_REC_HDR_', `$?sfrom $s $.$?_($?s$|from $.$_)')
define(`_REC_END_', `for $u; $|;
	$.$b$?g
	(envelope-from $g)$.')
define(`_REC_TLS_', `(using ${tls_version} with cipher ${cipher} (${cipher_bits} bits) verified ${verify})$.$?u')
define(`_REC_BY_', `$.by $j ($v/$Z)$?r with $r$. id $i$?{tls_version}')
define(`confRECEIVED_HEADER', `_REC_HDR_
	_REC_AUTH_$?{auth_ssf} (${auth_ssf} bits)$.)
	_REC_BY_
	_REC_TLS_
	_REC_END_')
define(`confSEVEN_BIT_INPUT', `False')
define(`confEIGHT_BIT_HANDLING', `pass8')
define(`confALIAS_WAIT', `10')
define(`confMIN_FREE_BLOCKS', `100')
define(`confBLANK_SUB', `.')
define(`confCON_EXPENSIVE', `False')
define(`confDELIVERY_MODE', `background')
define(`confTEMP_FILE_MODE', `0600')
define(`confMCI_CACHE_SIZE', `2')
define(`confMCI_CACHE_TIMEOUT', `5m')
define(`confUSE_ERRORS_TO', `False')
define(`confLOG_LEVEL', `9')
define(`confCHECK_ALIASES', `False')
define(`confOLD_STYLE_HEADERS', `True')
define(`confPRIVACY_FLAGS', `authwarnings')
define(`confSAFE_QUEUE', `True')
define(`confTO_QUEUERETURN', `5d')
define(`confTO_QUEUEWARN', `4h')
define(`confTIME_ZONE', `USE_SYSTEM')
define(`confCW_FILE', `MAIL_SETTINGS_DIR`'local-host-names')
define(`confMIME_FORMAT_ERRORS', `True')
define(`confFORWARD_PATH', `$z/.forward.$w:$z/.forward')
define(`confCR_FILE', `-o MAIL_SETTINGS_DIR`'relay-domains')
define(`confMILTER_MACROS_CONNECT', ``j, _, {daemon_name}, {if_name}, {if_addr}'')
define(`confMILTER_MACROS_HELO', ``{tls_version}, {cipher}, {cipher_bits}, {cert_subject}, {cert_issuer}'')
define(`confMILTER_MACROS_ENVFROM', ``i, {auth_type}, {auth_authen}, {auth_ssf}, {auth_author}, {mail_mailer}, {mail_host}, {mail_addr}'')
define(`confMILTER_MACROS_ENVRCPT', ``{rcpt_mailer}, {rcpt_host}, {rcpt_addr}'')


divert(0)dnl
VERSIONID(`$Id: cfhead.m4,v 8.76.4.15 2001/02/14 04:07:20 gshapiro Exp $')
