" Vim syntax file
" Language: Postfix LDAP lookup map description
" Maintainer: Stanislaw Klekot <vim@jarowit.net>
" Last Change: 2012-02-02
" Version: 0.1

" My syntax detection propsal:
"   au BufRead,BufNewFile /etc/postfix/*.ldap set filetype=pfldap

"-----------------------------------------------------------------------------
" setup {{{

if version >= 600
  if exists("b:current_syntax")
    finish
  endif
else
  syntax clear
endif

syn case match
"setlocal iskeyword=a-z,A-Z,48-57,_

" }}}
"-----------------------------------------------------------------------------
" general options recognition {{{

syn match pflComment "^\s*#.*"
syn match pflOption  "^\s*\k\+\s*=" contains=pflOptionName nextgroup=pflOptionValue skipwhite

" keywords taken from `man ldap_table' from Postfix 2.7.1 {{{
" XXX: query_filter, search_base, result_format and domain keywords are moved
" to the end of this block, as they have special value highlighting

" general options
syn keyword pflOptionName contained server_host server_port timeout
syn keyword pflOptionName contained result_attribute
syn keyword pflOptionName contained special_result_attribute
syn keyword pflOptionName contained terminal_result_attribute
syn keyword pflOptionName contained leaf_result_attribute scope bind bind_dn
syn keyword pflOptionName contained bind_pw recursion_limit expansion_limit
syn keyword pflOptionName contained size_limit dereference chase_referrals
syn keyword pflOptionName contained version debuglevel
" SSL/TLS options
syn keyword pflOptionName contained start_tls tls_ca_cert_dir tls_ca_cert_file
syn keyword pflOptionName contained tls_cert tls_key tls_require_cert
syn keyword pflOptionName contained tls_random_file tls_cipher_suite

" unsupported options (to highlight them specially)
syn keyword pflOptionUnsupported contained cache cache_expiry cache_size

" options that have special highlighting
syn keyword pflOptionName query_filter   nextgroup=pflQueryOptStart     skipwhite
syn keyword pflOptionName search_base    nextgroup=pflExpansionOptStart skipwhite
syn keyword pflOptionName result_format  nextgroup=pflExpansionOptStart skipwhite
syn keyword pflOptionName domain         nextgroup=pflListOptStart      skipwhite
syn keyword pflOptionName scope          nextgroup=pflScopeOptStart     skipwhite
syn keyword pflOptionName bind           nextgroup=pflBoolOptStart      skipwhite

syn match pflQueryOptStart      "=" contained nextgroup=pflQuery          skipwhite
syn match pflExpansionOptStart  "=" contained nextgroup=pflExpansionValue skipwhite
syn match pflListOptStart       "=" contained nextgroup=pflListValue      skipwhite
syn match pflScopeOptStart      "=" contained nextgroup=pflScopeValue,pflErrorValue skipwhite
syn match pflBoolOptStart       "=" contained nextgroup=pflBoolValue,pflErrorValue  skipwhite

" }}}

" }}}
"-----------------------------------------------------------------------------
" special highlighting for certain options {{{

" %-expansion (order of the following three rules matters)
syn match pflExpansionChar          contained "%.\|\\." contains=pflExpansionSupportedChar,pflExpansionQuoted
syn match pflExpansionSupportedChar contained "%[%sudSUD1-9]"
syn match pflExpansionQuoted        contained "\\[[:xdigit:]][[:xdigit:]]"

" LDAP query language (option query_filter)
syn region pflQuery      contained start="(" end=")"      contains=pflQueryOp,pflQuery,pflQueryAttr
syn match  pflQueryOp    contained "[&|!]"                nextgroup=pflQuery
" NOTE: in attribute names I DO NOT SUPPORT numeric OIDs. Use a name, it's
" much more descriptive.
" simple equality/substring match
syn match  pflQueryAttr  contained "[a-zA-Z0-9-]\+\(;[a-zA-Z0-9-]\+\)*="he=e-1 nextgroup=pflQueryValue
" similarity/less-or-equal/grater-or-equal match
syn match  pflQueryAttr  contained "[a-zA-Z0-9-]\+\(;[a-zA-Z0-9-]\+\)*[~<>]="he=e-2 nextgroup=pflQueryValue
" extensible match (RFC 4515), part with attr name specified (I don't care
" here much about validating matchingrule part of query, regexp is already
" complex enough)
syn match  pflQueryAttr  contained "[a-zA-Z0-9-]\+\(;[a-zA-Z0-9-]\+\)*\ze\(:dn\)\?\(:[a-zA-Z0-9.-]\+\)\?:=" nextgroup=pflQueryExtMatchRule
" extensible match (RFC 4515), part without attr name
syn match  pflQueryAttr  contained "\ze\(:dn\)\?:[a-zA-Z0-9.-]\+:=" nextgroup=pflQueryExtMatchRule
syn match  pflQueryExtMatchRule contained "\(:dn\)\?\(:[a-zA-Z0-9.-]\+\)\?:=" nextgroup=pflQueryValue
syn match  pflQueryValue contained "[^)]\+"               contains=pflQueryGlob,pflExpansionChar
syn match  pflQueryGlob  contained "[*?]"

" list of values (option domain)
syn match pflListElementOrd  contained "[^,[:space:]]\+"
syn match pflListElementPath contained "/[^,[:space:]]\+"
syn match pflListElementMap  contained "[a-z]\+:"he=e-1 nextgroup=pflListElementPath
syn match pflListValue       contained ".\+" contains=pflListElement.*

" other values supporting % expansion (search_base, result_format)
syn match pflExpansionValue contained ".\+" contains=pflExpansionChar

" enum values (and error)
syn keyword pflScopeValue contained sub base one
syn keyword pflBoolValue  contained yes no
syn match   pflErrorValue contained "\S\+"

" }}}
"-----------------------------------------------------------------------------
" colour binding {{{

" general colours
hi def link pflComment            Comment
hi def link pflOptionName         Statement
hi def link pflOptionUnsupported  Error

" % expansion
" character is considered an error unless it is a supported character
" special treatment for %%2f (translates to %2f in query, which translates to
" "/" character)
hi def link pflExpansionChar          Error
hi def link pflExpansionSupportedChar SpecialChar
hi def link pflExpansionQuoted        SpecialChar

" query colours
hi def link pflQuery       String
hi def link pflQueryOp     SpecialChar
hi def link pflQueryExtMatchRule pflQuery
hi def link pflQueryAttr   Type
hi def link pflQueryValue  Normal
hi def link pflQueryGlob   SpecialChar

" value that supports %-expansion
hi def link pflExpansionValue Normal

" list elements (list itself is no special at all)
hi def link pflListElementOrd  String
hi def link pflListElementPath Normal
hi def link pflListElementMap  Type

hi def link pflScopeValue Constant
hi def link pflBoolValue  Constant
hi def link pflErrorValue Error

" }}}
"-----------------------------------------------------------------------------

let b:current_syntax = "pfldap"

"-----------------------------------------------------------------------------
" vim:foldmethod=marker:nowrap
