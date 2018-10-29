#
#                          __  __            _
#                       ___\ \/ /_ __   __ _| |_
#                      / _ \\  /| '_ \ / _` | __|
#                     |  __//  \| |_) | (_| | |_
#                      \___/_/\_\ .__/ \__,_|\__|
#                               |_| XML parser
#
# Copyright (c) 2017 Expat development team
# Modified by Marco Maggi <github.com/marcomaggi>
# Licensed under the MIT license:
#
# Permission is  hereby granted,  free of charge,  to any  person obtaining
# a  copy  of  this  software   and  associated  documentation  files  (the
# "Software"),  to  deal in  the  Software  without restriction,  including
# without  limitation the  rights  to use,  copy,  modify, merge,  publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons  to whom  the Software  is  furnished to  do so,  subject to  the
# following conditions:
#
# The above copyright  notice and this permission notice  shall be included
# in all copies or substantial portions of the Software.
#
# THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT  WARRANTY  OF  ANY  KIND,
# EXPRESS  OR IMPLIED,  INCLUDING  BUT  NOT LIMITED  TO  THE WARRANTIES  OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR  OTHER LIABILITY, WHETHER  IN AN  ACTION OF CONTRACT,  TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.


#### global variables

AUTOMAKE_OPTIONS = \
    dist-bzip2 \
    foreign \
    no-dist-gzip \
    subdir-objects

ACLOCAL_AMFLAGS = -I meta/autotools
LIBTOOLFLAGS = --verbose

AM_CPPFLAGS = -I$(srcdir)/lib

pkgconfig_DATA = expat.pc
pkgconfigdir = $(libdir)/pkgconfig


_EXTRA_DIST_CMAKE = \
    CMakeLists.txt \
    CMake.README \
    ConfigureChecks.cmake \
    expat_config.h.cmake

_EXTRA_DIST_WINDOWS = \
    examples/elements.vcxproj \
    examples/elements.vcxproj.filters \
    examples/outline.vcxproj \
    examples/outline.vcxproj.filters \
    \
    lib/expat_static.vcxproj \
    lib/expat_static.vcxproj.filters \
    lib/expat.vcxproj \
    lib/expat.vcxproj.filters \
    lib/expatw_static.vcxproj \
    lib/expatw_static.vcxproj.filters \
    lib/expatw.vcxproj \
    lib/expatw.vcxproj.filters \
    \
    tests/benchmark/benchmark.sln \
    tests/benchmark/benchmark.vcxproj \
    \
    tests/runtests.sln \
    tests/runtests.vcxproj \
    tests/runtests.vcxproj.filters \
    \
    win32/expat.iss \
    win32/MANIFEST.txt \
    win32/README.txt \
    \
    xmlwf/xmlwf.vcxproj \
    xmlwf/xmlwf.vcxproj.filters \
    \
    expat.sln

EXTRA_DIST = \
    $(_EXTRA_DIST_CMAKE) \
    $(_EXTRA_DIST_WINDOWS) \
    \
    meta/autotools/expat.m4 \
    meta/autotools/PrintPath \
    meta/scripts/get-version.sh \
    \
    Changes \
    README.md \
    tests/test-driver-wrapper.sh

.PHONY: qa
qa:
	./qa.sh address
	./qa.sh memory
	./qa.sh undefined
	./qa.sh coverage


#### documentation

if WITH_DOCBOOK
dist_man_MANS	= doc/xmlwf.1

.INTERMEDIATE: XMLWF.1

XMLWF.1: doc/xmlwf.xml
	$(DOCBOOK_TO_MAN) $<

doc/xmlwf.1: XMLWF.1 doc/$(am__dirstamp)
	mv $< $@
endif

# Clean the manual page file.
#
# https://www.gnu.org/software/automake/manual/automake.html#What-Gets-Cleaned
 .PHONY: clean-local
clean-local: clean-local-check

.PHONY: clean-local-check
clean-local-check:
	$(RM) doc/xmlwf.1

EXTRA_DIST += \
    doc/expat.png \
    doc/reference.html \
    doc/style.css \
    doc/valid-xhtml10.png \
    doc/xmlwf.xml

doc_DATA = \
    AUTHORS \
    Changes

install-data-hook:
	cd "$(DESTDIR)$(docdir)" && $(am__mv) Changes changelog

uninstall-local:
	$(RM) "$(DESTDIR)$(docdir)/changelog"

## --------------------------------------------------------------------

AM_MAKEINFOFLAGS	= --no-split

info_TEXINFOS		= doc/expat.texi
doc_expat_TEXINFOS	= doc/macros.texi


#### library

include_HEADERS = \
    expat_config.h \
    lib/expat.h \
    lib/expat_external.h

EXPAT_LIB_LDFLAGS = \
    -no-undefined \
    -version-info @LIBCURRENT@:@LIBREVISION@:@LIBAGE@

EXPAT_LIB_SOURCES = \
    lib/loadlibrary.c \
    lib/xmlparse.c \
    lib/xmltok.c \
    lib/xmlrole.c

if UNICODE
lib_LTLIBRARIES = lib/libexpatw.la
lib_libexpatw_la_LDFLAGS = $(EXPAT_LIB_LDFLAGS)
lib_libexpatw_la_SOURCES = $(EXPAT_LIB_SOURCES)
else
lib_LTLIBRARIES = lib/libexpat.la
lib_libexpat_la_LDFLAGS = $(EXPAT_LIB_LDFLAGS)
lib_libexpat_la_SOURCES = $(EXPAT_LIB_SOURCES)
endif

EXTRA_DIST += \
    lib/ascii.h \
    lib/asciitab.h \
    lib/expat_external.h \
    lib/expat.h \
    lib/iasciitab.h \
    lib/internal.h \
    lib/latin1tab.h \
    lib/libexpat.def \
    lib/libexpatw.def \
    lib/nametab.h \
    lib/siphash.h \
    lib/utf8tab.h \
    lib/winconfig.h \
    lib/xmlrole.h \
    lib/xmltok.h \
    lib/xmltok_impl.c \
    lib/xmltok_impl.h \
    lib/xmltok_ns.c


#### building xmlwf

if WITH_XMLWF
bin_PROGRAMS = xmlwf/xmlwf

if UNICODE
xmlwf_xmlwf_LDADD = lib/libexpatw.la
else
xmlwf_xmlwf_LDADD = lib/libexpat.la
endif
xmlwf_xmlwf_SOURCES = \
    xmlwf/xmlwf.c \
    xmlwf/xmlfile.c \
    xmlwf/codepage.c \
    xmlwf/@FILEMAP@.c

# We must  define this variable and  duplicate all the flags  added to
# AM_CPPFLAGS above.   This is because below  we add a flag  to it and
# defining a  per-executable _CPPFLAGS variable causes  AM_CPPFLAGS to
# be ignored by GNU Automake.
#
xmlwf_xmlwf_CPPFLAGS = -I$(srcdir)/lib

if MINGW
if UNICODE
xmlwf_xmlwf_CPPFLAGS += -mwindows
xmlwf_xmlwf_LDFLAGS = -municode
endif
endif

EXTRA_DIST += \
    xmlwf/codepage.h \
    xmlwf/ct.c \
    xmlwf/filemap.h \
    xmlwf/readfilemap.c \
    xmlwf/unixfilemap.c \
    xmlwf/win32filemap.c \
    xmlwf/xmlfile.h \
    xmlwf/xmlmime.c \
    xmlwf/xmlmime.h \
    xmlwf/xmltchar.h \
    xmlwf/xmlurl.h \
    xmlwf/xmlwin32url.cxx

# End of "if WITH_XMLWF".
endif


#### examples

noinst_PROGRAMS = examples/elements examples/outline

examples_elements_SOURCES = examples/elements.c
if UNICODE
examples_elements_LDADD = lib/libexpatw.la
else
examples_elements_LDADD = lib/libexpat.la
endif

examples_outline_SOURCES = examples/outline.c
if UNICODE
examples_outline_LDADD = lib/libexpatw.la
else
examples_outline_LDADD = lib/libexpat.la
endif


#### tests

AM_TESTS_ENVIRONMENT = export EXPAT_ABS_SRCDIR=$(abs_top_srcdir); export EXPAT_ABS_BUILDDIR=$(abs_top_builddir);
noinst_LIBRARIES = tests/libruntests.a

check_PROGRAMS = \
	tests/runtests				\
	tests/runtestspp			\
	\
	tests/doc-sample--print-outline

TESTS = $(check_PROGRAMS)

# To support MinGW and Non-MinGW at the same time:
LOG_DRIVER = $(srcdir)/tests/test-driver-wrapper.sh

tests_libruntests_a_SOURCES = \
    tests/chardata.c \
    tests/structdata.c \
    tests/memcheck.c \
    tests/minicheck.c

tests_runtests_SOURCES			= tests/runtests.c
tests_runtestspp_SOURCES		= tests/runtestspp.cpp
tests_doc_sample__print_outline_SOURCES	= tests/doc-sample--print-outline.c

if UNICODE
expat_tests_ldadd	= tests/libruntests.a lib/libexpatw.la
expat_doc_sample_ldadd	= lib/libexpatw.la
else
expat_tests_ldadd	= tests/libruntests.a lib/libexpat.la
expat_doc_sample_ldadd	= lib/libexpat.la
endif

tests_runtests_LDADD			= $(expat_tests_ldadd)
tests_runtestspp_LDADD			= $(expat_tests_ldadd)
tests_doc_sample__print_outline_LDADD	= $(expat_doc_sample_ldadd)

## --------------------------------------------------------------------

EXTRA_DIST += \
    tests/chardata.h \
    tests/structdata.h \
    tests/minicheck.h \
    tests/memcheck.h \
    tests/README.txt \
    tests/udiffer.py \
    tests/xmltest.log.expected \
    tests/xmltest.sh

tests/xmlts.zip:
	if test "$(XMLTS_ZIP)" = ""; then \
		wget --output-document=$(builddir)/tests/xmlts.zip \
			https://www.w3.org/XML/Test/xmlts20080827.zip; \
	else \
		cp $(XMLTS_ZIP) $(builddir)/tests/xmlts.zip; \
	fi

tests/xmlconf: tests/xmlts.zip
	cd $(builddir)/tests && unzip -q xmlts.zip

.PHONY: run-xmltest
if WITH_XMLWF
# Here  we redirect  stderr  to stdout  so  that a  "No  such file  or
# directory" error message from "xmlwf" is appended to the log file.
run-xmltest: xmlwf/xmlwf tests/xmlconf
	$(srcdir)/tests/xmltest.sh			\
		-S "$(abs_top_srcdir)"			\
		-B "$(abs_top_builddir)"		\
		-R "$(abs_top_builddir)/tests/run.sh"	\
		-X "$(abs_top_builddir)/xmlwf/xmlwf@EXEEXT@" 2>&1 | \
		tee $(builddir)/tests/xmltest.log
	dos2unix $(builddir)/tests/xmltest.log
	diff -u $(srcdir)/tests/xmltest.log.expected $(builddir)/tests/xmltest.log
else
run-xmltest: tests/xmlconf
	@echo 'ERROR: xmlwf is needed for "make run-xmltest".' >&2
	@echo 'ERROR: Please re-configure without --without-xmlwf.' >&2
	@false
endif


#### benchmarking

noinst_PROGRAMS += tests/benchmark/benchmark

tests_benchmark_benchmark_SOURCES = tests/benchmark/benchmark.c

if UNICODE
tests_benchmark_benchmark_LDADD = lib/libexpatw.la
else
tests_benchmark_benchmark_LDADD = lib/libexpat.la
endif

EXTRA_DIST += \
    tests/benchmark/README.txt

.PHONY: run-benchmark
run-benchmark:
	$(builddir)/tests/run.sh tests/benchmark/benchmark@EXEEXT@ -n $(top_srcdir)/../testdata/largefiles/recset.xml 65535 3

### end of file
