#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

PICSCOINXD=${PICSCOINXD:-$SRCDIR/picscoinxd}
PICSCOINXCLI=${PICSCOINXCLI:-$SRCDIR/picscoinx-cli}
PICSCOINXTX=${PICSCOINXTX:-$SRCDIR/picscoinx-tx}
PICSCOINXQT=${PICSCOINXQT:-$SRCDIR/qt/picscoinx-qt}

[ ! -x $PICSCOINXD ] && echo "$PICSCOINXD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
PSXVER=($($PICSCOINXCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$PICSCOINXD --version | sed -n '1!p' >> footer.h2m

for cmd in $PICSCOINXD $PICSCOINXCLI $PICSCOINXTX $PICSCOINXQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${PSXVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${PSXVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
