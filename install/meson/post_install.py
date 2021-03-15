#!/usr/bin/env python3

import os
import subprocess
import re

def bundle(src, dst):
    file = open(src, 'r').read()
    file = re.sub("<link.*\/>", lambda x: '<style>\n' + open(os.path.dirname(src) + '/' + re.search('(?<=href=").*?(?="( |/))', x.group(0)).group(0), 'r').read() + '</style>', file)
    file = re.sub("<script.*?src.*</script>", lambda x: '<script>\n' + open(os.path.dirname(src) + '/' + re.search('(?<=src=").*?(?="( |>))', x.group(0)).group(0)).read() + '</script>', file)
    output = open(dst, 'w').write(file)

# Convert editor in src/widgets/Editor into a standalone html file
bundle(src = os.environ['MESON_SOURCE_ROOT'] + '/src/widgets/Editor/example.html', dst = os.environ['MESON_SOURCE_ROOT'] + '/install/data/editor.html')

# Compile schemas
schemadir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'share', 'glib-2.0', 'schemas')

if not os.environ.get('DESTDIR'):
    print('Compiling gsettings schemas...')
    subprocess.call(['glib-compile-schemas', schemadir])
