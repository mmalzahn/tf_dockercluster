#cloud-config
repo_update: false

runcmd:
- mkdir -p ${efs_directory}
- echo "${file_system_id}:/${project_id}/ ${efs_directory} efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults
- token=$(cat /efs/swarm_worker.token)
- docker swarm join --token $token ${master_ip}:2377