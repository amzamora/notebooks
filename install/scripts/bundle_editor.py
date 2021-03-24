#!/usr/bin/env python3
import os
import re

current_dir = os.path.dirname(os.path.abspath(__file__))

def bundle(src):
    file = open(src, 'r').read()
    file = re.sub("<link.*\/>", lambda x: '<style>\n' + open(os.path.dirname(src) + '/' + re.search('(?<=href=").*?(?="( |/))', x.group(0)).group(0), 'r').read() + '</style>', file)
    file = re.sub("<script.*?src.*</script>", lambda x: '<script>\n' + open(os.path.dirname(src) + '/' + re.search('(?<=src=").*?(?="( |>))', x.group(0)).group(0)).read() + '</script>', file)
    return file

html = bundle(current_dir + '/../data/editor/index.html')
html = re.sub("\\\\n", "\\\\\\\\n", html); # Escape new lines
editor_file = open(current_dir + '/../../src/widgets/Editor.vala').read()
editor_file = re.sub('(?<=const string html = """).*(?=""")', html, editor_file, flags=re.DOTALL|re.MULTILINE)
open(current_dir + '/../../src/widgets/Editor.vala', 'w').write(editor_file)
