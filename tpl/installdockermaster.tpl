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
- rm /efs/swarmtoken.txt
- docker swarm join-token -q worker >>/efs/swarmtoken.txt
- adduser ${user_id}
- usermod -a -G docker ${user_id}
- mkdir -m 700 /home/${user_id}/.ssh
- chown ${user_id}:${user_id} /home/${user_id}/.ssh
- echo "${public_key}">>/home/${user_id}/.ssh/authorized_keys
- chmod 600 /home/${user_id}/.ssh/authorized_keys
- chown ${user_id}:${user_id} /home/${user_id}/.ssh/authorized_keys