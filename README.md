# configsnap

Records useful system state information, and compare to previous state if run
with PHASE containing "post" or "rollback".

Tested and packaged for RHEL and it's derivatives through the EPEL repository.
Packages are also supplied for recent Debian based systems, however they are
less tested.

```
Usage: configsnap [options]

Record useful system state information, and compare to previous state if run
with PHASE containing "post" or "rollback". A default config file,
/etc/configsnap/additional.conf, can be customised to include extra files, directories
or commands to register during configsnap execution.

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
  -c CONFIG, --config=CONFIG
                        additional config file to use. Setting this will
                        override default.
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

Custom collection of additional command output (Type: command) and files (Type:
file) can be configured in the file /etc/configsnap/additional.conf, for
example:

```
[psspecial]
Type: command
Command: /bin/ps -aux
Compare: True
     # Recording the output of a command into a "psspecial.<phase>" file containing the output.

[debconf.conf]
Type: file
File: /etc/debconf.conf
Failok: True
     # Recording an additional file, stored as "debconf.<phase>"

[ssh]
Type: directory
Directory: /etc/ssh/
     # Recursively Recording all files from /etc/ssh/ directory, with sub-files appended with ".<phase>".

[fail2ban]
Type: directory
Directory: /etc/fail2ban
File_Pattern: .*\.local$
     #  Recording  all  files  from  /etc/fail2ban/  directory  matching  '.*\.local$', with sub-files
     appended with ".<phase>"
```

## Example Scenarios

### Zero Footprint Install

Isolating Configsnap's code, configuration and snapshot data in a /tmp directory allows:
- avoiding Configsnap files from getting into the snapshots or comparisons
- does not soil systems that have strictly managed configurations
- is easy to clean up
- reflects a least privileged approach
- enables a portable reference baseline to copy to other machines
- the portable reference baseline, importantly, contains the exact version of Configsnap and exact configuration file that was used on the reference system.

For more information on configuring Configsnap this way, read the post [Solution for Reverse Engineering Linux Config Deltas Via System-wide Diffing](https://missionimpossiblecode.io/post/solution-for-reverse-engineering-linux-config-deltas-via-system-wide-diffing/) and/or consult the run from web code from the post at [ConfigsnapCreateKnownGood.sh](https://gitlab.com/missionimpossiblecode/MissionImpossibleCode/-/blob/master/ConfigsnapCreateKnownGood.sh)

#### Install Configsnap

Works on any distro or arch and does not require Git or package managers.

```
mkdir -p /tmp/configsnap
curl https://raw.githubusercontent.com/rackerlabs/configsnap/master/configsnap -o /tmp/configsnap/configsnap
chmod +x /tmp/configsnap/configsnap
```

#### Create configuration

Create /tmp/configsnap/additional.conf additions to compare all files in /etc and ".something" files in /home/

```
[allmachineconfig]
Type: directory
Directory: /etc/

[userconfig]
Type: directory
Directory: /home/
File_Pattern: \..*

[systemduserservices]
Type: directory
Directory: /lib/systemd/user
File_Pattern: .*\.service$

[systemdsystemservices]
Type: directory
Directory: /lib/systemd/system
File_Pattern: .*\.servic
```

**NOTE: If your compare generates a message like "No extra post files found in..." for your extra directories, file compares were still done, but it is likely you compared two snaps with no differences. Use --verbose to see that all
file compares were simply identical.

### Before and After On The Same Machine For Drift Detection or Reverse Engineering of Software Installation

#### Create the reference baseline snapshot
```
echo "Creating Pre Configuration Snapshot"
sudo /tmp/configsnap/configsnap --basedir=/tmp/configsnap/snaps --verbose --tag=beforeandafter --phase=pre
```

#### After changes (or drift) occurs

```
sudo /tmp/configsnap/configsnap --basedir=/tmp/configsnap/snaps --verbose --tag=beforeandafter --phase=post
#Because the after phase name is "post", an automatic compare of "pre" and "post" is performed
```

### Compare a Known Working Reference Baseline Machine to a Non-Working Or Clean Baseline Machine

#### On the known good reference machine

```
# Follow "Prepare Zero Footprint Install" above
#edit additional.conf in directory next to configsnap to add full compare
sudo ./configsnap --basedir=/tmp/configsnap/snaps --verbose --tag=crossmachinecompare --phase=knowngoodconfig

# The /tmp/configsnap/ directory tree can be stored in a central location if it is a reference configuration
```

#### On the machine that is the comparison target (drifted, broken or clean baseline)

```
# Pull the code, config and known good snapshot data from the reference system (or a central area if copied to one)
scp -r user_on_reference_system@referencesystemdnsorip:/tmp/configsnap /tmp/configsnap

# Run an scp command to push files to machine that has drifted
sudo /tmp/configsnap/configsnap --basedir=/tmp/configsnap/snaps --verbose --tag=crossmachinecompare --pre=knowngoodconfig --phase=post
#Because the after phase name is "post", an automatic compare of "knowngoodconfig" and "post" is performed
```
