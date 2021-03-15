project('com.github.amzamora.notebooks', ['vala','c'])

gnome = import('gnome')

asresources = gnome.compile_resources(
	'as-resources', 'install/data/css.gresource.xml',
	source_dir: 'install/data',
	c_name: 'as'
)

exe = executable (meson.project_name(),
	'src/Application.vala',
	'src/MainWindow.vala',
	'src/widgets/Editor.vala',
	'src/services/Settings.vala',
	asresources,
	dependencies : [
		dependency('gtk+-3.0'),
		dependency('granite'),
	],
	install : true
)

meson.add_install_script('install/meson/post_install.py')

subdir ('install/data')
