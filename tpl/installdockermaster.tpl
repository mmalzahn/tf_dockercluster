#cloud-config
repo_update: true
repo_upgrade: all

runcmd:
- mkdir /tmpmount
- mount -t efs ${file_system_id}:/ /tmpmount
- mkdir /tmpmount/${project_id}
- umount /tmpmount
- rmdir /tmpmount
- mkdir -p ${efs_directory}
- echo "${file_system_id}:/${project_id}/ ${efs_directory} efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults
- docker swarm init
- docker swarm join-token -q worker >>/efs/swarmtoken.txt
