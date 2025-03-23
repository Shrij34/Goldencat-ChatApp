# Goldencat Chatroom

PRE-REQUISITES FOR THIS PROJECT:
AWS Account
AWS Ubuntu EC2 instance (t2.medium)
Install Docker
Install docker compose

STEPS TO IMPLEMENT THE PROJECT
Deployment using Docker

Clone the repository
git clone -b DevOps https://github.com/Shrij34/Goldencat-ChatApp.git
Install docker, docker compose and provide neccessary permission
sudo apt update -y

sudo apt install docker.io docker-compose-v2 -y

sudo usermod -aG docker $USER && newgrp docker
Move to the cloned repository
cd Springboot-BankApp
Build the Dockerfile
 docker build -t shrij34/chatapp .
Important

Make sure to change docker build command with your DockerHub username.

Create a docker network
docker network create chatapp
Run MYSQL container
docker run -itd --name mysql -e MYSQL_ROOT_PASSWORD=Test@123 -e MYSQL_DATABASE=chatapp --network=chatapp mysql
Run Application container
docker run -itd --name Chatapp -e SPRING_DATASOURCE_USERNAME="root" -e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/chatapp?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" -e SPRING_DATASOURCE_PASSWORD="Test@123" --network=chatapp -p 8080:8080 shrij34/chatapp

docker network inspect chatapp

Verify deployment
docker ps
Open port 8080 of your AWS instance and access your application
http://<public-ip>:8080
Congratulations, you have deployed the application using Docker


Stop any running containers
docker stop $(docker ps -q)

Remove stopped containers:
docker rm $(docker ps -a -q)




Deployment using Docker compose

Install docker compose
sudo apt update
sudo apt install docker-compose-v2 -y
Run docker-compose file present in the root directory of a project
docker compose up -d
Access it on port 8080
  http://<public-ip>:8080
Important

If you face issues with exiting docker container while running docker compose, run  docker compose down and then docker compose up -d.

**************************************************
Now lets do kuberneates in kinD
**************************************************

**Evrything in Kubernettes is Manifest file(YML file)**

create ec2 with ubuntu and connect to instance

update the ubuntu :sudo apt-get update


curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


Yes, absolutely! Since your WSL2 is running on a 64-bit architecture (`x86_64`), the commands you provided are compatible. Running these commands will download, make executable, and move the `kubectl` binary to your system's PATH within WSL2.

Here’s a quick recap of what each command does:
1. **Download kubectl**:
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   ```
   This fetches the latest stable version of `kubectl` for Linux.

2. **Make the binary executable**:
   ```bash
   chmod +x kubectl
   ```
   This grants execution permissions to the `kubectl` binary.

3. **Move it to your PATH**:
   ```bash
   sudo mv kubectl /usr/local/bin/kubectl
   ```
   This moves the binary to `/usr/local/bin`, making it globally accessible in your WSL2 environment.

Once done, you can verify the installation by running:
```bash
kubectl version --client
```

This will display the installed version of `kubectl`. Let me know if you encounter any issues or need assistance with the next steps!



Once kind is installed, you can create a new Kubernetes cluster:
kind create cluster chatapp

Setting Up the KIND Cluster
Create a kind-cluster-config.yaml file:

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
  image: kindest/node:v1.31.2
- role: worker
  image: kindest/node:v1.31.2
- role: worker
  image: kindest/node:v1.31.2
Create the cluster using the configuration file:

kind create cluster --config kind-cluster-config.yaml --name my-kind-cluster
Verify the cluster:

kubectl get nodes
kubectl cluster-info
3.

if need to set ontext for getting nodes if not available
telling kubectl to use which cluster to use as current cluster if there are 2 or more clusters

kubectl config set-context [NAME | --current] [--cluster=cluster_nickname] [--user=user_nickname] [--namespace=namespace]
kubectl config set-context --current --cluster=kind


now lets create namespac for logical group for nodes to be in one namespace(room)


Check the current context for kubectl:

bash
Copy
Edit
kubectl config current-context
If it’s not set to your Kind cluster, switch to the correct context:

bash
Copy
Edit
kubectl config use-context kind-kind
You can list all contexts available:

bash
Copy
Edit
kubectl config get-contexts
2. Check the Nodes
Once the context is set correctly, check if you can get information about the nodes:

bash
Copy
Edit
kubectl get nodes
If this works, it means kubectl can connect to your Kind cluster.

create name space
kubectl apply -f namespace.yaml 

shrij@Shrij:/mnt/d/Az400/My_projects/Goldencat-ChatApp/k8s_kind$ kubectl apply -f namespace.yaml 
namespace/dev created
shrij@Shrij:/mnt/d/Az400/My_projects/Goldencat-ChatApp/k8s_kind$ kubectl apply -f 01_mysql-deployment.yaml 
deployment.apps/mysql created
shrij@Shrij:/mnt/d/Az400/My_projects/Goldencat-ChatApp/k8s_kind$ kubectl apply -f 02_mysql_service.yaml 
service/mysql-service created
shrij@Shrij:/mnt/d/Az400/My_projects/Goldencat-ChatApp/k8s_kind$ kubectl apply -f 03_chatapp_Deployment.yaml 
deployment.apps/nginx-deployment created
shrij@Shrij:/mnt/d/Az400/My_projects/Goldencat-ChatApp/k8s_kind$ kubectl apply -f 04_chatapp_service.yaml 
service/chatapp created
shrij@Shrij:/mnt/d/Az400/My_projects/Goldencat-ChatApp/k8s_kind$ kubectl get deployments
No resources found in default namespace.
shrij@Shrij:/mnt/d/Az400/My_projects/Goldencat-ChatApp/k8s_kind$ kubectl get deployments -n dev

Steps to Access Your Service:
Find the Service Name: You need the exact name of your service in the dev namespace. If you don't know it, you can list the services:

bash
Copy
Edit
kubectl get svc -n dev
This should show you the service you created. For example, let's assume the service is named chatapp.

Port Forward the Service: Once you have the service name, you can port-forward it to your local machine. This will allow you to access it via localhost on the specified port.

For example, if your service is chatapp and it exposes port 8080, you can use:

bash
Copy
Edit
kubectl port-forward svc/chatapp 8080:8080 -n dev
This will forward port 8080 from the chatapp service to your local port 8080.

Access the Application: Now, you can open your browser and access the application using:

arduino
Copy
Edit
http://localhost:8080
Summary:
Use kubectl get svc -n dev to check your service's name.

Use kubectl port-forward svc/<service-name> <local-port>:<service-port> -n dev to forward the port.

Access the app at http://localhost:<local-port>.