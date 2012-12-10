#!/usr/bin/env python
# encoding: utf-8

import sys
import os
import markdown2

HEADER = '''
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8">
<title>Localizer</title>
<meta name="AppleOrder" content="0">
<meta name="AppleTitle" content="Localizer Help">
<meta name="AppleIcon" content="localizer.png">
<meta name="KEYWORDS" content="Localizer">
<meta name="DESCRIPTION" content="Localizer Help">
<link rel="stylesheet" href="style.css" type="text/css">
</head>
<body>
<div class="Destination">
'''

FOOTER = '''
</div>
</body>
</html>
'''

def make_html(filename, output_filename):
	output = ''
	output += HEADER
	with open(filename, 'r') as content_file:
		content = content_file.read()
	output += markdown2.markdown(content).encode('utf-8')
	output += FOOTER
	with open(output_filename, 'w') as f:
		f.write(output)

def main():
	make_html('README.md', os.path.join('Localizer', 'en.lproj', 'Help', 'index.html'))
	make_html('README.zh-Hant.md', os.path.join('Localizer', 'zh-Hant.lproj', 'Help', 'index.html'))

if __name__ == '__main__':
	main()
