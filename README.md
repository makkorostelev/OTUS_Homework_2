# OTUS_Homework_2
 
Project creates high availability gfs2 with clvm storage.\
It creates 3 cluster initiator node and 1 target node.\
To work with the project you need to write your data into variables.tf.\
![Variables](https://github.com/makkorostelev/OTUS_Homework_2/blob/main/Screenshots/variables.png)\
Then enter the commands:
`terraform init`\
`terraform apply`

After ~5 minutes pacemaker cluster will be initialized and run:\
Below there is an example of successful set up:

```
Outputs:

cluster_ips = [
  "51.250.43.59",
  "51.250.36.18",
  "51.250.41.135",
]
storage_ip = "51.250.43.99"
```

Than you can login at any cluster node with the command:\
`ssh centos@ip_addr`\
Where `ip_addr` - is any cluster IP.

To check if cluster is running:

```
[centos@node-1 ~]$ sudo pcs status
Cluster name: mycluster
Stack: corosync
Current DC: node-1 (version 1.1.23-1.el7_9.1-9acf116022) - partition with quorum
Last updated: Mon Nov 20 09:24:07 2023
Last change: Mon Nov 20 09:16:17 2023 by root via cibadmin on node-0

3 nodes configured
9 resource instances configured

Online: [ node-0 node-1 node-2 ]

Full list of resources:

 Clone Set: dlm-clone [dlm]
     Started: [ node-0 node-1 node-2 ]
 Clone Set: clvmd-clone [clvmd]
     Started: [ node-0 node-1 node-2 ]
 Clone Set: clusterfs-clone [clusterfs]
     Started: [ node-0 node-1 node-2 ]

Daemon Status:
  corosync: active/enabled
  pacemaker: active/enabled
  pcsd: active/enabled
```

You can also verify that the file system was successfully mounted:

```
[centos@node-1 ~]$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
devtmpfs                           891M     0  891M   0% /dev
tmpfs                              919M   75M  845M   9% /dev/shm
tmpfs                              919M  664K  919M   1% /run
tmpfs                              919M     0  919M   0% /sys/fs/cgroup
/dev/vda2                           10G  1,8G  8,2G  19% /
/dev/mapper/cluster_vg-cluster_lv  900M   37M  864M   5% /mnt/gfs2
tmpfs                              184M     0  184M   0% /run/user/1000
```
