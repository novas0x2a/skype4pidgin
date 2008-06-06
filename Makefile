
#Customisable stuff here
LINUX32_COMPILER = i686-pc-linux-gnu-gcc
LINUX64_COMPILER = x86_64-linux-gnu-gcc
WIN32_COMPILER = /usr/bin/i586-mingw32-gcc
LINUX_ARM_COMPILER = arm-pc-linux-gnu-gcc

LIBPURPLE_CFLAGS = -I/usr/include/libpurple -DPURPLE_PLUGINS -DENABLE_NLS
GLIB_CFLAGS = -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include
DBUS_CFLAGS = -DSKYPE_DBUS -I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include
WIN32_DEV_DIR = /root/pidgin/win32-dev
WIN32_PIDGIN_DIR = /root/pidgin/pidgin-2.1.1_win32
WIN32_CFLAGS = -I${WIN32_DEV_DIR}/gtk_2_0/include/glib-2.0 -I${WIN32_PIDGIN_DIR}/libpurple/win32 -I${WIN32_DEV_DIR}/gtk_2_0/include -I${WIN32_DEV_DIR}/gtk_2_0/include/glib-2.0 -I${WIN32_DEV_DIR}/gtk_2_0/lib/glib-2.0/include
WIN32_LIBS = -L${WIN32_DEV_DIR}/gtk_2_0/lib -L${WIN32_PIDGIN_DIR}/libpurple -lglib-2.0 -lgobject-2.0 -lgthread-2.0 -lintl -lpurple

DEB_PACKAGE_DIR = /root/skypeplugin

LOCALES = $(patsubst %.po, %.mo, $(wildcard po/*.po))

#Standard stuff here
.PHONY:	all clean

all:	skype4pidgin.deb skype4pidgin-installer.exe libskype_dbus.so libskype_dbus64.so

clean:
	rm -f libskype.so libskype64.so libskype_dbus.so libskype_dbus64.so libskype.dll skype4pidgin.deb skype4pidgin-installer.exe

libskype.so: libskype.c
	${LINUX32_COMPILER} ${LIBPURPLE_CFLAGS} -Wall -pthread ${GLIB_CFLAGS} -I. -g -march=athlon-xp -O2 -pipe libskype.c -o libskype.so -shared -fPIC -DPIC

libskype64.so:
	${LINUX64_COMPILER} ${LIBPURPLE_CFLAGS} -Wall -pthread ${GLIB_CFLAGS} -I. -g -m32 -m64 -O2 -pipe libskype.c -o libskype64.so -shared -fPIC -DPIC

libskypearm.so:
	${LINUX_ARM_COMPILER} ${LIBPURPLE_CFLAGS} -Wall -pthread ${GLIB_CFLAGS} -I. -g -march=athlon-xp -O2 -pipe libskype.c -o libskype.so -shared -fPIC -DPIC

libskype_dbus.so:
	${LINUX32_COMPILER} ${LIBPURPLE_CFLAGS} -Wall -pthread ${GLIB_CFLAGS} -I. -g -march=athlon-xp -O2 -pipe libskype.c -o libskype_dbus.so -shared -fPIC -DPIC ${DBUS_CFLAGS}

libskype_dbus64.so:
	${LINUX64_COMPILER} ${LIBPURPLE_CFLAGS} -Wall -pthread ${GLIB_CFLAGS} -I. -g -m32 -m64 -O2 -pipe libskype.c -o libskype_dbus64.so -shared -fPIC -DPIC ${DBUS_CFLAGS}

libskype_dbusarm.so:
	${LINUX_ARM_COMPILER} ${LIBPURPLE_CFLAGS} -Wall -pthread ${GLIB_CFLAGS} -I. -g -march=athlon-xp -O2 -pipe libskype.c -o libskype_dbus.so -shared -fPIC -DPIC ${DBUS_CFLAGS}

libskype.dll:
	${WIN32_COMPILER} ${LIBPURPLE_CFLAGS} -Wall -I. -g -O2 -pipe libskype.c -o libskype.dll -shared -mno-cygwin ${WIN32_CFLAGS} ${WIN32_LIBS}
	upx libskype.dll

po/%.mo: po/%.po
	msgfmt -cf -o $@ $<

locales:	${LOCALES}

skype4pidgin-installer.exe: libskype.dll
	date=`date +%d-%b-%Y` && sed "s/PRODUCT_VERSION \"[-a-z0-9A-Z]*\"/PRODUCT_VERSION \"$$date\"/" -i skype4pidgin.nsi
	echo "Making .exe package"
	makensis skype4pidgin.nsi > /dev/null

skype4pidgin.deb: libskype.so libskype64.so libskype_dbus.so libskype_dbus64.so
	rm ${DEB_PACKAGE_DIR}/usr/lib/purple-2/libskype*.so
	cp libskype.so libskype64.so libskype_dbus.so libskype_dbus64.so ${DEB_PACKAGE_DIR}/usr/lib/purple-2/
	date=`date +%F` && sed "s/Version: [-a-z0-9A-Z]*/Version: $$date/" -i ${DEB_PACKAGE_DIR}/DEBIAN/control
	echo "Making .deb package"
	dpkg-deb --build ${DEB_PACKAGE_DIR} skype4pidgin.deb > /dev/null
	
