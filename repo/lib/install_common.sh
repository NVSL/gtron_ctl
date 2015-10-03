function init_github() {
    request "Making github work easily (say 'yes')"
    git clone git@github.com:NVSL/gadgetron-vm-util.git
    rm -rf gadgetron-vm-util
    git clone git@github.com:NVSL/gadgetron-vm-util.git
    rm -rf gadgetron-vm-util
}

function setup_user_ssh() {
    if ! [ -e ~/.ssh/config ] || ! grep bb- ~/.ssh/config; then 
	banner Configuring ssh
	cat >> ~/.ssh/config  <<EOF
Host bb-*
Port 425
Host bbfs-*
Port 425
EOF
	chmod og-rwx -R ~/.ssh
    else
	banner Your ssh seems to be configured correctly for the NVSL cluster
    fi
    
}

function install_welcome_banner() {
    cat >> ~/.bashrc <<EOF
echo
echo "To start gadgetron installation, run './checkout_gadgetron'"
echo
EOF
}

function install_global_python() {
    banner "Installing gloabla python packages..."
    $SUDO pip install -r ../config/global_python.txt
}

function install_global_javascript() {
    banner "Installing global javascript resources..."
    $SUDO npm install -g $(cat ../config/global_node.txt)
}

function ensure_ssh_key() {
    if ! [ -e ~/.ssh/id_rsa.pub ]; then 
	request "Generating public key.  Please accept all the defaults"
	ssh-keygen
	return 1
    fi
    return 0
}

function push_ssh_key_to_bb_cluster() {
    if ! ssh -p425 -o PasswordAuthentication=no $user@bbfs-01.calit2.net; then
	request "Can't log into the cluster without password.  Provide NVSL password to transfer pub key to svn repo"
	cat .ssh/id_rsa.pub | ssh -p425 $user@bbfs-01.calit2.net "cat >> .ssh/authorized_keys"
    fi
}

function push_ssh_key_to_github() {
    request  "Visit \n\nhttps://github.com/settings/ssh \n\nand add this key by copying and pasting it into the space provided.  Give it a meaningful name, like 'Gadgetron Development Key'"
    cat .ssh/id_rsa.pub
    
    request "PRESS RETURN WHEN YOU HAVE DONE SO. (waiting...)"
    read junk
}

function checkout_gadgetron_root() {
    banner "Initial Gadgetron checkout:"
    
    if ! [ -d "Gadgetron" ]; then
	mkdir Gadgetron
	(cd Gadgetron
	 svn checkout -N svn+ssh://$user@bbfs-01.calit2.net/grw/Gordon/svn/trunk/branches/swanson/git-migration .
	 ./initial_setup gadgets)
    fi
}

