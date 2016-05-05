#!/bin/bash -ex

repo=$1
branch=$2
dest=$3
venv=/opt/venv/astara

apt-get -y install python-dev libmysqlclient-dev

if ! which pip ; then
	apt-get -y install python-pip
fi

if ! which git; then
	apt-get -y install git
fi

if ! which virtualenv ; then
	pip install virtualenv
fi

if [[ ! -d $dest ]] ; then
	git clone $repo $dest
	(cd $dest && git checkout $branch)
fi

dirs="/var/log/astara /var/lib/astara /etc/astara"
for dir in $dirs; do
	mkdir -p $dir
done

if ! getent group astara > /dev/null 2>&1
then
        addgroup --system astara >/dev/null
fi

if ! getent passwd astara > /dev/null 2>&1
then
	adduser --system --home /var/lib/astara --ingroup astara --no-create-home --shell /bin/false astara
fi

for i in $(ls $dest/etc/); do
	if [[ ! -e /etc/astara/$i ]]; then
		cp -r $dest/etc/$i /etc/astara
	fi
done

chown -R astara:adm /var/log/astara/
chmod 0750 /var/log/astara/
chown astara:astara -R /var/lib/astara/ /etc/astara/
chmod 0750 /etc/astara/

cat >/etc/sudoers.d/astara_sudoers <<END
Defaults:astara !requiretty
astara ALL = (root) NOPASSWD: /usr/bin/astara-rootwrap
END
chmod 0440 /etc/sudoers.d/astara_sudoers

if [[ ! -d $venv ]]; then
	mkdir -p $(dirname $venv)
	virtualenv $venv
fi

cat >/etc/init/astara-orchestrator.conf <<END
description "Astara Network Orchestrator server"
author "Eric Lopez <eric.lopez@akanda.io>"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

chdir /var/run

exec start-stop-daemon --start --chuid astara --exec /usr/bin/astara-orchestrator -- --config-file=/etc/astara/orchestrator.ini
END

if ! which astara-orchestrator; then
	$venv/bin/pip install -r $dest/requirements.txt $dest
	$venv/bin/pip install "PyMySQL>=0.6.2"
	$venv/bin/pip install "MySQL-python;python_version=='2.7'"
	for bin in $(ls $venv/bin/astara*) ; do
    if [[ ! -e /usr/bin/$(basename $bin) ]]; then
      ln -s $bin /usr/bin/$(basename $bin)
    fi
	done
fi
