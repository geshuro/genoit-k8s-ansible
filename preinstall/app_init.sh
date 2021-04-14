############################################
#K8S
############################################
Outputs:

kubernetes_private_dns = [
  "test-kubernetes-0-nrux.genoit.int",
  "test-kubernetes-1-nrux.genoit.int",
  "test-kubernetes-2-nrux.genoit.int",
  "test-kubernetes-3-nrux.genoit.int",
  "test-kubernetes-4-nrux.genoit.int",
  "test-kubernetes-5-nrux.genoit.int",
  "test-kubernetes-6-nrux.genoit.int",
  "test-kubernetes-7-nrux.genoit.int",
  "test-kubernetes-8-nrux.genoit.int",
]
kubernetes_private_ip = [
  "172.28.12.202",
  "172.28.12.109",
  "172.28.12.151",
  "172.28.12.230",
  "172.28.12.164",
  "172.28.12.95",
  "172.28.12.215",
  "172.28.12.152",
  "172.28.12.104",
]
server_security_group_id = [
  "sg-0e6f4db479a95a713",
]

############################################
#NFS
############################################
Outputs:

kubernetes_private_dns = [
  "test-kubernetes-nfs-0.genoit.int-pxob",
]
kubernetes_private_ip = [
  "172.28.12.35",
]
server_security_group_id = [
  "sg-066f1224887edb2f8",
]


sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.202	#master1
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.109	#master2
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.151	#master3
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.230 	#loadbalancer1
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.164	#loadbalancer2
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.95		#loadbalancer3
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.215	#micro1
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.152	#microfrontend1
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.104	#tools1


#File System NFS
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-nfs-vprueba.pem" root@172.28.12.35



######################################################################################
#init k8s-nfs-server.bash remoto
#!/bin/bash
#montar carpetas
mkdir /shared
mkdir /shared/disk1
mkdir /shared/tools

mkfs -t xfs /dev/xvdb
mkfs -t xfs /dev/xvdc

mount /dev/xvdb /shared/disk1
mount /dev/xvdc /shared/tools

sudo cp /etc/fstab /etc/fstab.orig

sed -i '$a /dev/xvdb  /shared/disk1  xfs  defaults,nofail  0 0'  /etc/fstab
sed -i '$a /dev/xvdc  /shared/tools  xfs  defaults,nofail  0 0'  /etc/fstab

umount /shared/disk1
umount /shared/tools
mount -a

#NFS - server
yum -y install nfs-utils libnfsdimap
systemctl enable rpcbind
systemctl enable nfs-server
systemctl start enable 
systemctl start nfs-server
systemctl start rpc-statd
systemctl start nfs-idmapd

chmod  777 /shared/
chmod  777 /shared/disk1
chmod  777 /shared/tools

cat <<EOT >> /etc/exports
/shared/tools 172.28.12.0/24(rw,sync,no_root_squash)
/shared/disk1 172.28.12.0/24(rw,sync,no_root_squash)
EOT

exportfs -r
showmount -e localhost
######################################################################################
######################################################################################
#init k8s remoto
#!/bin/bash
sudo subscription-manager register --username genoit --password genoitpass --auto-attach
sudo subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
#crear usuario admcuc
adduser admcuc; echo admcuc | passwd admcuc --stdin; usermod -aG wheel admcuc
systemctl stop firewalld; systemctl disable firewalld; systemctl mask --now firewalld; systemctl status firewalld
######################################################################################
#ejecutar init k8s remoto
#master "bash -s" -- < init_k8s.sh 
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.202 "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.109 "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.151 "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.230 "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.164 "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.95  "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.215 "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.152 "bash -s" -- < /tmp/k8s/init_k8s.sh 	
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.104 "bash -s" -- < /tmp/k8s/init_k8s.sh
#NFS
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-nfs-vprueba.pem" root@172.28.12.35 "bash -s" -- < /tmp/k8s/init_k8s.sh 

######################################################################################
#ejecutar init k8s-nfs-server.bash remoto
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-nfs-vprueba.pem" root@172.28.12.35 "bash -s" -- < /tmp/k8s/init_k8s-nfs-server.bash 
######################################################################################

#Git
git add .
git commit -m "Agregar permisos para crear usuario de nuevo grupo develop"
git push origin feature/test2-k8s

#Clone
git clone -b feature/devops-k8s codecommit::us-east-1://genoit@genoit-infrastructure-terraform
git clone -b feature/k8s-nfs codecommit::us-east-1://genoit@genoit-infrastructure-terraform


git clone -b feature/test2-k8s codecommit::us-east-1://genoit@genoit-infrastructure-ansible


git checkout -b feature/test2-k8s
git checkout -b feature/test2-k8s-nfs

/mnt/d/git/genoit-infrastructure-terraform



#Proxy genoit
vi /etc/rhsm/rhsm.conf
proxy_hostname =10.20.20.6
proxy_port =3128

vi /etc/yum.conf
...
proxy=http://10.20.20.66:3128

kubectl create -f 01-namespace.yaml


sysctl -w vm.max_map_count=262144

#label en nodo por validacion de elastic anidado
kubectl label nodes tools1 tools=sonarqube
kubectl label nodes tools1 zeebe=true



journalctl --unit=docker -n 100 --no-pager

######################################################################################
#configure nfs cliente -- /tmp/k8s/k8s_client_nfs_tools.sh 
#!/bin/bash
yum install -y nfs-utils libnfsdimap
systemctl enable rpcbind
systemctl start rpcbind
mkdir /shared
mkdir /shared/tools
mount 172.28.12.35:/shared/tools /shared/tools
sed -i '$a 172.28.12.35:/shared/tools  /shared/tools  nfs  rw,sync,hard,intr  0 0'  /etc/fstab
umount /shared/tools
mount -a
mount -av

######################################################################################
#configure nfs cliente -- /tmp/k8s/k8s_client_nfs_micro.sh 
#!/bin/bash
yum install -y nfs-utils libnfsdimap
systemctl enable rpcbind
systemctl start rpcbind
mkdir /shared
mkdir /shared/disk1
mount 172.28.12.35:/shared/disk1 /shared/disk1
sed -i '$a 172.28.12.35:/shared/disk1  /shared/disk1  nfs  rw,sync,hard,intr  0 0'  /etc/fstab
umount /shared/disk1
mount -a
mount -av

######################################################################################
#init 
#montar carpetas docker storage
#!/bin/bash
mkdir /var/lib/
mkdir /var/lib/docker
chown root:root /var/lib/docker
chmod -R 711 /var/lib/docker

mkfs -t xfs /dev/xvdb
mount /dev/xvdb /var/lib/docker
sudo cp /etc/fstab /etc/fstab.orig
sed -i '$a /dev/xvdb  /var/lib/docker  xfs  defaults,nofail  0 0'  /etc/fstab
umount /var/lib/docker
mount -a
df -h

######################################################################################
#ejecutar init docker storage k8s remoto
#master "bash -s" -- < init_k8s_docker_storage.sh 
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.202 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh  
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.109 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh  
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.151 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh  
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.230 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh  
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.164 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh  
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.95 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh 
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.215 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh  
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.152 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh 
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.104 "bash -s" -- < /tmp/k8s/init_k8s_docker_storage.sh 

######################################################################################
#configure nfs cliente -- /tmp/k8s/k8s_client_nfs_tools.sh 
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.104 "bash -s" -- < /tmp/k8s/k8s_client_nfs_tools.sh

######################################################################################
#configure nfs cliente -- /tmp/k8s/k8s_client_nfs_micro.sh
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-tec-devops-test2-vprueba.pem" root@172.28.12.215 "bash -s" -- < /tmp/k8s/k8s_client_nfs_micro.sh




######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
#Crear cluster
ansible-playbook -b -v -i inventory/test-prueba/hosts.yaml cluster.yml -Kk
#subscription-manager remove --all
######################################################################################
#Agregar nodo
ansible-playbook -b -v -i inventory/test-prueba/hosts.yaml scale.yml -Kk --limit tools3
######################################################################################
#Creacion usuario
ansible-playbook -b -v -i inventory/test-prueba/hosts.yaml cluster_usuario.yml -Kk

######################################################################################
#Crear local_volume_provisioner
ansible-playbook -b -v -i inventory/test-prueba/hosts.yaml cluster_provisionador.yml -Kk

######################################################################################
#Reiniciar cluster
ansible-playbook -b -v -i inventory/test-prueba/hosts.yaml reiniciar.yml -Kk

######################################################################################
#bastion test
# VPN 35.174.151.151
sshpass -p genoit2020 ssh -i "/tmp/kp/kp-test2-bastion.pem" root@10.36.8.217


#Comprimir ansible bastion para copiar a local git
zip -r /tmp/genoit-k8s-ansiblerole-test2-20210312.zip /home/admcuc/genoit-k8s-ansiblerole-test2


#Error certificado Docker

######################################################################################
#init 
#configurar docker para jfrog registry
#!/bin/bash
cat <<EOT >> /etc/docker/daemon.json
{
"registry-mirrors": [],
"insecure-registries": [
"jfcr.devops-internal.genoit.int",
"jfcr.genoit.int"],
"debug": false,
"experimental": false,
"features": {
"buildkit": true
}
}
EOT

service docker restart

#verificar  jfcr.new-devops-internal.genoit.int
