#!/bin/sh

HOST=$1

if [ -z "${HOST}" ]; then
	echo "Must provide hostname"
	exit 0
fi

ssh ${HOST} 'mkdir -p /usr/local/etc/pkg/repos /usr/local/etc/ssl'
scp FreeBSD.conf pkg.jdmulloy.net.conf ${HOST}:/usr/local/etc/pkg/repos
scp cert.pem ${HOST}:/usr/local/etc/ssl/
ssh ${HOST} 'sh -c "export ASSUME_ALWAYS_YES=YES; pkg bootstrap" && pkg install -y python27'
