#!/bin/bash -eux

debian_common(){
	# Remove unneeded packages.
	apt-get -y --purge remove linux-headers-$(uname -r)
	apt-get -y --purge autoremove
	apt-get -y purge $(dpkg --list | grep '^rc' | awk '{print $2}')
	apt-get -y purge $(dpkg --list | egrep 'linux-image-[0-9]' | awk '{print $3,$2}' | sort -nr | tail -n +2 | grep -v $(uname -r) | awk '{print $2}')
	apt-get -y clean
}

suse_common(){
	rm -rf /home/vagrant/bin
}

el_common(){
	# Clean up yum
	yum clean all
}

common_actions(){
	# Delete unneeded files.
	rm -f /home/vagrant/*.sh
	# Zero out the rest of the free space using dd, then delete the written file.
	dd if=/dev/zero of=/EMPTY bs=1M
	rm -f /EMPTY
	# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
	sync
	# Clear bash history
	cat /dev/null > ~/.bash_history && history -c
}

case "$PACKER_DISTRO_TYPE" in
	opensuse|suse) suse_common;;
	debian|ubuntu) debian_common;;
	centos) el_common;;
	*) echo "[ERROR] Unknown PACKER_DISTRO_TYPE value";
	   exit 1;;
esac

common_actions
