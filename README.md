# Desplegar genoit-k8s-ansiblerole


## Resumen

Descargar el codigo ansible role del repositorio, configurar y ejecutar, dura aproximadamente 15 minutos el despliegue.

### Pasos


- Las maquinas remotas deben tener configuracion ssh ya establecida, y estar subscritas a licencia Red Hat.

```raw
sudo subscription-manager register --username XXXXX --password YYYYYY --auto-attach
```

- El Bastion Ansible instalar estas librerias Python "requisitos.txt"

```raw
sudo pip3 install -r requisitos.txt --proxy=http://{IP_PROXY}:{PUERTO_PROXY}
```
- Configurar cluster

```raw
- inventory/prod/group_vars/all/all.yml: variables "http_proxy", "https_proxy" y "dir_cert"
- inventory/prod/group_vars/k8s-cluster/addons.yml: variable "metallb_ip_range" rango de IP de la misma Red de los Nodos.
- inventory/prod/group_vars/k8s-cluster/k8s-cluster.yml: variable "kube_version" version de Kubernetes a instalar, y la variable "cluster_name".
```
- Actualizar el inventario ansible 

```raw
- inventory/prod/hosts.yaml: Indicar el usuario remoto que ejecutara el playbook, mediante la variable "ansible_user" (permisos sudo)
- inventory/prod/hosts.yaml: Colocar cantidad de nodos, las IPs de cada servidor y asginar un rol en el Cluster, por ejm: kube-master, kube-node y etcd. Asi mismo indicar con el label "role:'loadbalancer'" el nodo donde se desplegara el MetalLB.
```
- Desplegar el proyecto genoit-k8s-ansiblerole con Ansible Playbook

```raw
Ejecutar el Playbook con un usuario con permsisos sudo en el Bastion Ansible.
ansible-playbook -b -v -i inventory/prod/hosts.yaml cluster.yml -Kk
```
- Desplegar el ansible-role aprovisionador de storage con Ansible Playbook

```raw
Ejecutar el Playbook con un usuario con permsisos sudo en el Bastion Ansible.
ansible-playbook -b -v -i inventory/prod/hosts.yaml cluster_provisionador.yml -Kk
```

### Nota

- Los servidores donde ejecutaran los playbook de forma remota deben tener establecido configuraciones de red, caso contrario deshabilitar el firewall.

```raw
systemctl stop firewalld
systemctl status firewalld 
```
- Garantizar que los servidores tengan habilitado el repo rhel-7-server-ansible-2.9-rpms u otro que permita instalar el paquete "sshpass".

```raw
sudo subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
```

```raw
#Crear cluster
ansible-playbook -b -v -i inventory/prod/hosts.yaml cluster.yml -Kk

#Agregar nodo
ansible-playbook -b -v -i inventory/prod/hosts.yaml escalar.yml -Kk --limit micro2,tools2,tools3

#Creacion usuario
ansible-playbook -b -v -i inventory/prod/hosts.yaml cluster_usuario.yml -Kk

#Crear local_volume_provisioner
ansible-playbook -b -v -i inventory/prod/hosts.yaml cluster_provisionador.yml -Kk

#Reiniciar cluster
ansible-playbook -b -v -i inventory/prod/hosts.yaml reiniciar.yml -Kk
```