#!/bin/sh
set -e
#
# Taken from the docker script
#
# This script is meant for quick & easy install via:
#   'curl -sSL https://get.datacraticdb.com/ | sh'
# or:
#   'wget -qO- https://get.datacraticdb.com/ | sh'
#

url='https://get.docker.com/'

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

case "$(uname -m)" in
	*64)
		;;
	*)
		echo >&2 'Error: you are not using a 64 bit platform.'
		echo >&2 'Datactatic DB requires Docker, which currently only supports 64bit platforms.'
		exit 1
		;;
esac

if command_exists docker.io; then
    DOCKER=docker.io
elif command_exists docker; then
    DOCKER=docker
else
	echo >&2 'Docker is not installed.  Please install it before proceeding.'
        exit 1
fi

user="$(id -un 2>/dev/null || true)"

sh_c='sh -c'
if [ "$user" != 'root' ]; then
	if command_exists sudo; then
		sh_c='sudo -E sh -c'
	elif command_exists su; then
		sh_c='su -c'
	else
		echo >&2 'Error: this installer needs the ability to run commands as root.'
		echo >&2 'We are unable to find either "sudo" or "su" available to make this happen.'
		exit 1
	fi
fi

curl=''
if command_exists curl; then
	curl='curl -sSL'
elif command_exists wget; then
	curl='wget -qO-'
elif command_exists busybox && busybox --list-modules | grep -q wget; then
	curl='busybox wget -qO-'
fi

# perform some very rudimentary platform detection
lsb_dist=''
if command_exists lsb_release; then
	lsb_dist="$(lsb_release -si)"
fi
if [ -z "$lsb_dist" ] && [ -r /etc/lsb-release ]; then
	lsb_dist="$(. /etc/lsb-release && echo "$DISTRIB_ID")"
fi
if [ -z "$lsb_dist" ] && [ -r /etc/debian_version ]; then
	lsb_dist='Debian'
fi
if [ -z "$lsb_dist" ] && [ -r /etc/fedora-release ]; then
	lsb_dist='Fedora'
fi

case "$lsb_dist" in
	Fedora)
		;;

	Ubuntu|Debian|LinuxMint)
		export DEBIAN_FRONTEND=noninteractive

		did_apt_get_update=
		apt_get_update() {
			if [ -z "$did_apt_get_update" ]; then
				( set -x; $sh_c 'sleep 3; apt-get update' )
				did_apt_get_update=1
			fi
		}

                # Get curl
		if [ ! -e /usr/lib/apt/methods/https ]; then
			apt_get_update
			( set -x; $sh_c 'sleep 3; apt-get install -y -q apt-transport-https' )
		fi
		if [ -z "$curl" ]; then
			apt_get_update
			( set -x; $sh_c 'sleep 3; apt-get install -y -q curl' )
			curl='curl -sSL'
		fi

                # See if we need to install docker
                #...

		if command_exists $docker && [ -e /var/run/docker.sock ]; then
			(
				set -x
				$sh_c 'docker run --rm hello-world'
			) || true
		fi
		your_user=your-user
		[ "$user" != 'root' ] && your_user="$user"

		echo
		echo 'If you would like to use Docker as a non-root user, you should now consider'
		echo 'adding your user to the "docker" group with something like:'
		echo
		echo '  sudo usermod -aG docker' $your_user
		echo
		echo 'Remember that you will have to log out and back in for this to take effect!'
		echo
		exit 0
		;;

esac

# Check that we have a compatible docker version
docker_version=`docker --version`

echo >&2 "Docker version is $docker_version"

# ... check compatibility...

# Starting etcd in docker for service discovery
$docker run -t -d -p 4001 -p 7001 --name="datacraticdb_etcd" coreos/etcd

# Start the launcher
$docker run datacratic/datacraticdb:plugins


cat >&2 <<'EOF'

  Either your platform is not easily detectable, is not supported by this
  installer script (yet - PRs welcome! [hack/install.sh]), or does not yet have
  a package for Docker.  Please visit the following URL for more detailed
  installation instructions:

    http://docs.docker.io/en/latest/installation/

EOF
exit 1
