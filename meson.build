project('com.github.amzamora.notebooks', ['vala','c'])

gnome = import('gnome')

asresources = gnome.compile_resources(
	'as-resources', 'install/data/css.gresource.xml',
	source_dir: 'install/data',
	c_name: 'as'
)

# Update html for editor in src/widgets/Editor.vala
python = import('python').find_installation('python3')
bundle_editor = custom_target('bundle editor',
	output : 'fake',
	command : [python, join_paths(meson.source_root(), 'install/scripts/bundle_editor.py')],
	build_by_default : true
)

exe = executable (meson.project_name(),
	'src/Application.vala',
	'src/MainWindow.vala',
	'src/widgets/Editor.vala',
	'src/widgets/Image.vala',
	'src/services/Settings.vala',
	asresources,
	dependencies : [
		dependency('gtk+-3.0'),
		dependency('granite'),
		dependency('webkit2gtk-4.0')
	],
	install : true
)

meson.add_install_script('install/scripts/post_install.py')

subdir ('install/data')
