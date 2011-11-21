CFLAGS=-O2 -pipe -march=native -ggdb
LDFLAGS=-Wl,-O1 -Wl,--as-needed

GLIB_CFLAGS=`pkg-config --cflags glib-2.0`
LIBPURPLE_CFLAGS=`pkg-config --cflags purple` -DPURPLE_PLUGINS
COMMON_CFLAGS=-Wall -Wextra -Wno-unused-parameter -Wno-unused-function -Wfatal-errors -Werror -shared -fPIC -fdiagnostics-show-option
DBUS_CFLAGS=`pkg-config --cflags dbus-glib-1`
X_CFLAGS=`pkg-config --cflags x11 xproto`

default: libskype.so

all: libskype.so libskypenet.so libskype_dbus.so

clean:
	rm -f *.so

libskypenet.so: libskype.c
	gcc ${COMMON_CFLAGS} -DSKYPENET ${CFLAGS} ${LDFLAGS} ${GLIB_CFLAGS} \
		 ${LIBPURPLE_CFLAGS} -I. $^ -o $@

libskype_dbus.so: libskype.c
	gcc ${COMMON_CFLAGS} -DSKYPE_DBUS ${CFLAGS} ${LDFLAGS} ${DBUS_CFLAGS} \
		${LIBPURPLE_CFLAGS} -I. $^ -o $@

libskype.so: libskype.c
	gcc ${COMMON_CFLAGS} ${CFLAGS} ${LDFLAGS} ${GLIB_CFLAGS} ${X_CFLAGS} \
		${LIBPURPLE_CFLAGS} -I. $^ -o $@
