# Manage your nvme device #

We explore how to manage your nvme device here.

### NVMe Overview ###

NVM Express is a scalable host controller interface designed to address the needs of Enterprise, Data Center and Client systems that utilize PCI Express® (PCIe®) based solid state drives.
NVM Express specifications are owned and maintained by [NVM Express, Inc.](https://nvmexpress.org)

NVMe device is managed by a user space tooling, [nvme-cli](https://github.com/linux-nvme/nvme-cli) for Linux.
Continue reading to find out how to manage and start using your NVMe device, using `nvme-cli`.

### What is nvme namespace ###

Let us not get bored by giving information that can be found elsewhere easily.
NVMe device is addressed as `nvmeX` in linux, found at `/dev`.
The `nvmeX` is a character device and can have one or many block devices (referred to as namespaces).

```
# ls -l /dev/nvme*
crw-------. 1 root root 243,  0 Oct  3 14:43 /dev/nvme0
brw-rw----. 1 root disk 259,  0 Oct  3 14:43 /dev/nvme0n1
brw-rw----. 1 root disk 259,  0 Oct  3 14:43 /dev/nvme0n2
```

The block devices can be viewed using the command `nvme list`, as below:

```
# nvme list
Node             SN     Model                       Namespace Usage                      Format         FW Rev  
---------------- ------ --------------------------- --------- -------------------------- -------------- ----------
/dev/nvme0n1     SN     1.6TB NVMe Gen4 U.2 SSD     1         25.00  GB /  25.00  GB     4 KiB +  0 B   FW Version
/dev/nvme0n2     SN     1.6TB NVMe Gen4 U.2 SSD     2         25.00  GB /  25.00  GB     4 KiB +  0 B   FW Version
```

### Basic commands of nvme-cli to control the namespaces of nvme device ###

To find capacity of an NVMe device:
```
# nvme id-ctrl /dev/nvme0 | grep -i tnvmcap
tnvmcap   : 1600321314816
```
This means it is a 1.6 TB Device


To find number of namespaces an NVMe device supports:
```
# nvme id-ctrl /dev/nvme0 | grep ^nn
nn        : 64
```
which means it supports 64 namespaces


Block size of NVMe device:
```
# nvme id-ns /dev/nvme0n1 | grep "in use"
lbaf  0 : ms:0   lbads:12 rp:0 (in use)
```
This means the block size of nvme device is `2^12`, which is 4096

So, max number of blocks the device supports is:
```
# expr 1600321314816 / 4096
390703446
```


### Managing namespaces of nvme device ###

We need to know the controller ID of the nvme device
```
# nvme list-ctrl /dev/nvme0
[   0]:0x41
[   1]:0x42
```
We use the one indexed as 0, which is 0x41.

We need to decide what is the size of the namespace we are going to create. Let us divide 390703446 by 64.
We get `6104741`, which will be size of one namespace (assuming we create identical 64 namespaces).

We need to create namespace, and then attach it to the controller via the controller ID.
```
# nvme create-ns /dev/nvme0 --nsze=6104741 --ncap=6104741 --flbas=0 -dps=0
create-ns: Success, created nsid:1

# nvme attach-ns /dev/nvme0 --namespace-id=1 -controllers=0x41
attach-ns: Success, nsid:1

# nvme list
Node             SN     Model                       Namespace Usage                      Format         FW Rev  
---------------- ------ --------------------------- --------- -------------------------- -------------- ----------
/dev/nvme0n1     SN     1.6TB NVMe Gen4 U.2 SSD     1         25.00  GB /  25.00  GB     4 KiB +  0 B   FW Version

```

We can do this multiple times, by running `create-ns` multiple times and varying the namespace id in the `attach-ns command`

Check out a bash script to do this [here](/resources/nvme_max_namespaces.sh)

Now, this namespace can be used like any block device.
```
# lsblk /dev/nvme0n1
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
nvme0n1 259:5    0  14G  0 disk
```

To delete this namespace:
```
# nvme delete-ns /dev/nvme0 -n 1
delete-ns: Success, deleted nsid:1
```

Now we are ready to play with our nvme devices.
