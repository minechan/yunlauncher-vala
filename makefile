all:
	valac --pkg gtk+-3.0 --pkg gdk-3.0 --pkg gio-2.0 --pkg pango src/main.vala src/widgets.vala -o yunlauncher

install:
	cp ./yunlauncher /usr/bin/
