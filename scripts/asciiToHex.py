#!/usr/bin/env python2

import sys

# Converts a single input string to hexadecimal number of specified length
conversionStr = '{0:0' + sys.argv[2] + 'x}'
print conversionStr.format(int(sys.argv[1].encode("hex"),16))
