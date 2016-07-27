# getData

Records useful system state information, and compare to previous state if run with PHASE containing "post" or "rollback".

```
Usage: getData [options]

Options:
  -h, --help            show this help message and exit
  -v, --verbose         print debug info
  -V, --version         print version
  -s, --silent          no output to stdout
  -t TAG, --tag=TAG     tag identifer (e.g. a ticket number)
  -d BASEDIR, --basedir=BASEDIR
                        base directory to store output
  -p PHASE, --phase=PHASE
                        phase this is being used for. Can be any string.
                        Phases containing  post  or  rollback  will perform
                        diffs
```

Example output:
```
# ./getData -t junepatching -p pre
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


Finished! Backups were saved to /root/junepatching/getData/*.pre
```
