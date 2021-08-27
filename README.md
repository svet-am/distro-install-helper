# distro-install-helper
Helper tool for new Linux distribution installation

# BACKGROUND
I have managed a Bash shell script for years that I use to automate initial installation setup tasks.  There are other tools (like Ansible) that can do this as well but I started this script long before those tools exists so I maintain it for legacy reasons.  Also, since it's Bash, it is highly portable and doesn't depend on anything other than the shell being available.

This version of the script aims to be more general use and flexible with some things now programmatically driven rather than being hard-coded like they were in the original version.