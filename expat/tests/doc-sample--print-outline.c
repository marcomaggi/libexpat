/*
 * doc-sample--print-outline.c
 *
 * Copyright 1999, Clark Cooper
 * All rights reserved.
 *
 * Modified by Marco Maggi <github.com/marcomaggi>.
 *
 * This program is free software;  you can redistribute it and/or modify
 * it under the terms of the  license contained in the COPYING file that
 * comes with the expat distribution.
 *
 * THE  SOFTWARE IS  PROVIDED "AS  IS",  WITHOUT WARRANTY  OF ANY  KIND,
 * EXPRESS OR  IMPLIED, INCLUDING BUT  NOT LIMITED TO THE  WARRANTIES OF
 * MERCHANTABILITY,    FITNESS   FOR    A    PARTICULAR   PURPOSE    AND
 * NONINFRINGEMENT.  IN NO EVENT SHALL  THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE  FOR ANY CLAIM, DAMAGES  OR OTHER LIABILITY, WHETHER  IN AN
 * ACTION OF  CONTRACT, TORT OR  OTHERWISE, ARISING  FROM, OUT OF  OR IN
 * CONNECTION WITH  THE SOFTWARE  OR THE  USE OR  OTHER DEALINGS  IN THE
 * SOFTWARE.
 *
 * Read an XML document from standard input and print an element outline
 * on  standard output.   Must be  used  with Expat  compiled for  UTF-8
 * output.
 */


/** --------------------------------------------------------------------
 ** Headers.
 ** ----------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <expat.h>

#ifdef XML_LARGE_SIZE
#  if defined(XML_USE_MSC_EXTENSIONS) && _MSC_VER < 1400
#    define XML_FMT_INT_MOD "I64"
#  else
#    define XML_FMT_INT_MOD "ll"
#  endif
#else
#  define XML_FMT_INT_MOD "l"
#endif


/** --------------------------------------------------------------------
 ** Globals.
 ** ----------------------------------------------------------------- */

static char const * document = "\
<!-- this is a test document -->\
<stuff>\
  <thing>\
    <alpha>one</alpha>\
    <beta>two</beta>\
  </thing>\
  <thing>\
    <alpha>123</alpha>\
    <beta>456</beta>\
  </thing>\
</stuff>";

int depth;


static void XMLCALL
start (void * data, char const * element, char const ** attribute)
{
  for (int i = 0; i < depth; i++)
    printf("  ");

  printf("%s", element);

  for (int i = 0; attribute[i]; i += 2)
    printf(" %s='%s'", attribute[i], attribute[i + 1]);

  printf("\n");
  depth++;
}

static void XMLCALL
end (void * data, char const * el)
{
  depth--;
}


int
main (void)
{
  XML_Parser	parser;

  parser = XML_ParserCreate(NULL);
  if (! parser) {
    fprintf(stderr, "Couldn't allocate memory for parser\n");
    exit(EXIT_FAILURE);
  }
  {
    char const *	docptr = document;
    int			doclen = strlen(docptr);

    XML_SetElementHandler(parser, start, end);

    if (XML_Parse(parser, docptr, doclen, 1) == XML_STATUS_ERROR) {
      fprintf(stderr,
	      "Parse error at line %" XML_FMT_INT_MOD "u:\n%s\n",
	      XML_GetCurrentLineNumber(parser),
	      XML_ErrorString(XML_GetErrorCode(parser)));
      exit(EXIT_FAILURE);
    }
  }
  XML_ParserFree(parser);
  exit(EXIT_SUCCESS);
}

/* end of file */
