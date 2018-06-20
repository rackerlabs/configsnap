# configsnap

Records useful system state information, and compare to previous state if run with PHASE containing "post" or "rollback".

Tested on RHEL, CentOS, Fedora and Ubuntu, but should also work on other derivatives. For other distros, config will be collected where the commands or file locations match RHEL or Ubuntu.

```
Usage: configsnap [options]

Record useful system state information, and compare to previous state if run
with PHASE containing "post" or "rollback".

Options:
  -h, --help            show this help message and exit
  -w, --overwrite       if phase files already exist in tag dir, remove
                        previously collected data with that tag
  -a, --archive         pack output files into a tar archive
  -v, --verbose         print debug info
  -V, --version         print version
  -s, --silent          no output to stdout
  --force-compare       Force a comparison after collecting data
  -t TAG, --tag=TAG     tag identifer (e.g. a ticket number)
  -d BASEDIR, --basedir=BASEDIR
                        base directory to store output
  -p PHASE, --phase=PHASE
                        phase this is being used for. Can be any string.
                        Phases containing  post  or  rollback  will perform
                        diffs
  -C, --compare-only    Compare existing files with tags specified with --pre
                        and --phase
  --pre=PRE_SUFFIX      suffix for files captured at previous state, for
                        comparison
```

Example output:
```
# ./configsnap -t junepatching -p pre
Getting storage details (LVM, partitions, PowerPath)...
Getting process list...
Getting package list and enabled services...
Getting network details and listening services...
Getting cluster status...
Getting misc (dmesg, lspci, sysctl)...
Getting Dell hardware information...
Copying files...
 /boot/grub/grub.conf 
 /etc/fstab 
 /etc/hosts 
 /etc/sysconfig/network 
 /etc/yum.conf 
 /proc/cmdline 
 /proc/meminfo 
 /proc/mounts 
 /proc/scsi/scsi 
 /etc/sysconfig/network-scripts/ifcfg-eth3 
 /etc/sysconfig/network-scripts/ifcfg-lo 
 /etc/sysconfig/network-scripts/ifcfg-eth1 
 /etc/sysconfig/network-scripts/ifcfg-eth0 
 /etc/sysconfig/network-scripts/ifcfg-eth2 
 /etc/sysconfig/network-scripts/route-eth2 


Finished! Backups were saved to /root/junepatching/configsnap/*.pre
```

Custom collection of additional command output (Type: command) and files (Type: file) can be configured in the file /etc/configsnap/additional.conf, for example:

```
[psspecial]
Type: command
Command: /bin/ps -aux

[debconf.conf]
Type: file
File: /etc/debconf.conf
```

This will result in files psspecial.phase and debconf.conf.phase.
