#! /usr/bin/env bash
#
# EXPAT TEST SCRIPT FOR W3C XML TEST SUITE
#
# This script can be used to exercise Expat against the w3c.org xml test
# suite, available from:
#
#   <http://www.w3.org/XML/Test/xmlts20020606.zip>
#
# The script lists  all test cases where Expat shows  a discrepancy from
# the  expected result.   Test  cases where  only  the canonical  output
# differs  are prefixed  with  "Output  differs:", and  a  diff file  is
# generated in the appropriate subdirectory under $OUTDIR.
#
# If there  are output files provided,  the script will use  output from
# xmlwf and compare the desired output  against it.  However, one has to
# take into account that the canonical output produced by xmlwf conforms
# to an older definition of canonical XML and does not generate notation
# declarations.

#page
#### global settings

shopt -s nullglob

#page
#### global variables

# The environment  variable EXPAT_ABS_SRCDIR is  set in the  Makefile to
# the source directory.  The  environment variable EXPAT_ABS_BUILDDIR is
# set in the Makefile to the build directory.
declare -r EXPAT_ABS_SRCDIR_TESTS=${EXPAT_ABS_SRCDIR}/tests
declare -r EXPAT_ABS_BUILDDIR_TESTS=${EXPAT_ABS_BUILDDIR}/tests

declare -r _XML_BASE_SRCDIR="$EXPAT_ABS_BUILDDIR_TESTS"/xmlconf

declare -r XMLWF="${EXPAT_ABS_BUILDDIR}/xmlwf/xmlwf"
# declare -r XMLWF=/usr/local/bin/xmlwf

declare -r OUTDIR="${EXPAT_ABS_BUILDDIR}/out"
# declare  OUTDIR=/home/tmp/xml-testsuite-out

# Unicode-aware diff utility
declare -r DIFF=diff
#declare -r DIFF="${EXPAT_ABS_SRCDIR}/tests/udiffer.py"

declare  OUTFILE="${OUTDIR}/outfile"

declare -i SUCCESS=0
declare -i ERROR=0

#page
#### utility functions

function MakeDirectory () {
    local PATHNAME="${1:?missing directory pathname in call to ${FUNCNAME}}"
    /bin/mkdir -p "$PATHNAME"
}

function MoveFile () {
    local SRC_PATHNAME="${1:?missing source file pathname in call to ${FUNCNAME}}"
    local DST_PATHNAME="${2:?missing destination file pathname in call to ${FUNCNAME}}"
    if test -f "$SRC_PATHNAME"
    then /bin/mv "$SRC_PATHNAME" "$DST_PATHNAME"
    fi
}

function RemoveFile () {
    local PATHNAME="${1:?missing file pathname in call to ${FUNCNAME}}"
    if test -f "$PATHNAME"
    then /bin/rm "$PATHNAME"
    fi
}

function UpdateStatus () {
    if test "$1" -eq 0
    then
	let ++SUCCESS
    else
	let ++ERROR
    fi
}

#page
#### not-well formed document processing

function RunXmlwfNotWF () {
    local -r XML_BASE_SRCDIR="${1:?missing XML base source directory pathname in call to ${FUNCNAME}}"
    local -r XML_RELATIVE_SRCDIR="${2:?missing XML relative source directory pathname in call to ${FUNCNAME}}"
    local -r XML_FILE_NAME="${3:?missing XML file name in call to ${FUNCNAME}}"
    local -r OUTFILE="${4:?missing output file pathname in call to ${FUNCNAME}}"

    local XML_FILE_ABS_PATHNAME="${XML_BASE_SRCDIR}/${XML_RELATIVE_SRCDIR}/${XML_FILE_NAME}"
    local OUTDATA

    if ! test -f "$XML_FILE_ABS_PATHNAME"
    then
	echo "Missing source XML file: ${XML_FILE_ABS_PATHNAME}"
	return 1
    fi

    "$XMLWF" -p "$XML_FILE_ABS_PATHNAME" > "$OUTFILE" || return $?
    read OUTDATA < "$OUTFILE"
    if test -z "$OUTDATA"
    then
	echo "Expected not well-formed: ${XML_RELATIVE_SRCDIR}/${XML_FILE_NAME}"
	return 1
    else
	return 0
    fi
}

#page
#### well formed document processing

function RunXmlwfWF () {
    local -r XML_BASE_SRCDIR="${1:?missing XML base source directory pathname in call to ${FUNCNAME}}"
    local -r XML_RELATIVE_SRCDIR="${2:?missing XML relative source directory pathname in call to ${FUNCNAME}}"
    local -r XML_FILE_NAME="${3:?missing XML file name in call to ${FUNCNAME}}"
    local -r OUTFILE="${4:?missing output file pathname in call to ${FUNCNAME}}"

    local -r XML_FILE_ABS_PATHNAME="${XML_BASE_SRCDIR}/${XML_RELATIVE_SRCDIR}/${XML_FILE_NAME}"
    local -r XMLWF_TRANSFORMED_OUTPUT_DIR="${OUTDIR}/${XML_RELATIVE_SRCDIR}"
    local -r XMLWF_TRANSFORMED_OUTPUT_FILE="${XMLWF_TRANSFORMED_OUTPUT_DIR}/${XML_FILE_NAME}"
    local OUTDATA

    if ! test -f "$XML_FILE_ABS_PATHNAME"
    then
	echo "Missing source XML file: ${XML_FILE_ABS_PATHNAME}"
	return 1
    fi

    # In case the  document is well formed this  command: prints nothing
    # to  stdout;  outputs a  transformed  version  of the  document  to
    # $XMLWF_TRANSFORMED_OUTPUT_DIR.
    #
    # In case  the document is not  well formed: this command  prints to
    # stdout a description of the "not well formed" error.
    #
    "$XMLWF" -p -N -d "$XMLWF_TRANSFORMED_OUTPUT_DIR" "$XML_FILE_ABS_PATHNAME" > "$OUTFILE" || return $?

    read OUTDATA < "$OUTFILE"
    if test -z "$OUTDATA"
    then
	if test -f "$XMLWF_TRANSFORMED_OUTPUT_FILE"
	then
            "$DIFF" "$XML_FILE_ABS_PATHNAME" "$XMLWF_TRANSFORMED_OUTPUT_FILE" > "$OUTFILE"
	    # If $OUTFILE exists and it is not empty: store it for later
	    # perusal.
            if test -s "$OUTFILE"
	    then
		MakeDirectory "${OUTDIR}/${XML_RELATIVE_SRCDIR}"
		MoveFile "$OUTFILE" "${OUTDIR}/${XML_RELATIVE_SRCDIR}/${XML_FILE_NAME}.diff"
		echo "Output differs: ${XML_RELATIVE_SRCDIR}/${XML_FILE_NAME}"
		return 1
            fi
	fi
	return 0
    else
	echo "In ${XML_RELATIVE_SRCDIR}: $OUTDATA"
	return 1
    fi
}

#page
#### well-formed test cases

cd "$_XML_BASE_SRCDIR"
for XML_RELATIVE_SRCDIR in \
    ibm/valid/P* \
	ibm/invalid/P* \
	xmltest/valid/ext-sa \
	xmltest/valid/not-sa \
	xmltest/invalid \
	xmltest/invalid/not-sa \
	xmltest/valid/sa \
	sun/valid \
	sun/invalid
do
    MakeDirectory "${OUTDIR}/${XML_RELATIVE_SRCDIR}"
    cd "${_XML_BASE_SRCDIR}/${XML_RELATIVE_SRCDIR}"
    for XML_FILE_NAME in $(ls -1 *.xml | sort -d)
    do
	[[ -f "$XML_FILE_NAME" ]] || continue
	RunXmlwfWF "$_XML_BASE_SRCDIR" "$XML_RELATIVE_SRCDIR" "$XML_FILE_NAME" "$OUTFILE"
	UpdateStatus $?
    done
    RemoveFile "$OUTFILE"
done

MakeDirectory "${OUTDIR}/oasis"

cd "$_XML_BASE_SRCDIR"
XML_RELATIVE_SRCDIR=oasis
cd "$XML_RELATIVE_SRCDIR"
for XML_FILE_NAME in *pass*.xml ; do
    RunXmlwfWF "$_XML_BASE_SRCDIR" "$XML_RELATIVE_SRCDIR" "$XML_FILE_NAME" "$OUTFILE"
    UpdateStatus $?
done
RemoveFile "$OUTFILE"

#page
#### not well-formed test cases

cd "$_XML_BASE_SRCDIR"
for XML_RELATIVE_SRCDIR in \
    ibm/not-wf/P* \
	ibm/not-wf/p28a \
	ibm/not-wf/misc \
	xmltest/not-wf/ext-sa \
	xmltest/not-wf/not-sa \
	xmltest/not-wf/sa \
	sun/not-wf
do
    cd "${_XML_BASE_SRCDIR}/${XML_RELATIVE_SRCDIR}"
    for XML_FILE_NAME in *.xml
    do
	RunXmlwfNotWF "$_XML_BASE_SRCDIR" "$XML_RELATIVE_SRCDIR" "$XML_FILE_NAME" "$OUTFILE"
	UpdateStatus $?
    done
    RemoveFile "$OUTFILE"
done

cd "$_XML_BASE_SRCDIR"
XML_RELATIVE_SRCDIR=oasis
cd "$XML_RELATIVE_SRCDIR"
for XML_FILE_NAME in *fail*.xml
do
    RunXmlwfNotWF "$_XML_BASE_SRCDIR" "$XML_RELATIVE_SRCDIR" "$XML_FILE_NAME" "$OUTFILE"
    UpdateStatus $?
done
RemoveFile "$OUTFILE"

#page
#### done

echo "Passed: $SUCCESS"
echo "Failed: $ERROR"

### end of file
# Local Variables:
# page-delimiter: "^#page"
# End:
