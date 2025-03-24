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

============================================================================================================================
adding ingress 
============================================================================================================================

✅ Step 1: Delete Existing Cluster (if any)
Before creating a new cluster, delete any existing kind cluster.

bash
Copy
Edit
kind delete cluster --name my-kind-cluster
✅ Step 2: Create New Cluster with Port Mapping
Create a configuration file kind-config.yaml with the following content:

yaml
Copy
Edit
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
      - containerPort: 443
        hostPort: 443
Now, create your cluster using this config file:

bash
Copy
Edit
kind create cluster --name my-kind-cluster --config kind-config.yaml
✅ Step 3: Install NGINX Ingress Controller
Deploy the Ingress Controller to your kind cluster:

bash
Copy
Edit
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
✅ Step 4: Wait for NGINX Ingress Controller to be Ready
Check if the ingress-nginx-controller pod is running:

bash
Copy
Edit
kubectl get pods -n ingress-nginx
You should see something like:

sql
Copy
Edit
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-xxxx               1/1     Running   0          2m
✅ Step 5: Label Your Nodes for Ingress (Important)
By default, kind doesn't label nodes as Ingress-ready. You need to label them like this:

bash
Copy
Edit
kubectl label node my-kind-cluster-control-plane ingress-ready=true
If you want all worker nodes to be available for Ingress, you can do:

bash
Copy
Edit
kubectl label node my-kind-cluster-worker ingress-ready=true
kubectl label node my-kind-cluster-worker2 ingress-ready=true
✅ Step 6: Deploy Your Application & Services
Deploy your chatapp and mysql services (I'm assuming you have the manifests ready).

✅ Step 7: Create Your Ingress Configuration File
Create a file named ingress_chatapp.yaml with the following content:

yaml
Copy
Edit
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: chatapp-ingress
  namespace: dev
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: localhost
      http:
        paths:
          - path: /chatapp
            pathType: Prefix
            backend:
              service:
                name: chatapp
                port:
                  number: 8080
✅ Step 8: Apply Ingress Configuration
Apply the Ingress file:

bash
Copy
Edit
kubectl apply -f ingress_chatapp.yaml
✅ Step 9: Check Ingress
Verify if the Ingress is created:

bash
Copy
Edit
kubectl get ingress -n dev
You should see something like:

pgsql
Copy
Edit
NAME            CLASS    HOSTS     ADDRESS     PORTS   AGE
chatapp-ingress   <none>   localhost   localhost   80      2m
✅ Step 10: Access Your Application
You should be able to access your app now via:

arduino
Copy
Edit
http://localhost/chatapp
To set up a StatefulSet with Persistent Volumes (PVs), and then add Horizontal Pod Autoscaler (HPA) for MySQL in Kubernetes, here’s a step-by-step guide.


============================================================================================================================Create a Persistent Volume (PV) and Persistent Volume Claim (PVC)
============================================================================================================================


Step 1: Create a Persistent Volume (PV) and Persistent Volume Claim (PVC)
Persistent Volume: A PV is a piece of storage in the cluster, and it abstracts storage that is used by the pod. In KinD (Kubernetes in Docker) or local environments, you can create a hostPath PV, or use an NFS share.

Persistent Volume Claim (PVC): PVCs are the requests made by a pod for storage. PVCs get bound to PVs.

Define a Persistent Volume
yaml
Copy
Edit
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
  namespace: dev
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data/mysql  # Path on the host machine (adjust as needed)
  persistentVolumeReclaimPolicy: Retain
This defines a PersistentVolume with 1Gi of storage, using hostPath for local storage.

Define Persistent Volume Claim
yaml
Copy
Edit
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: ""
The storageClassName is left empty, assuming we're using a local volume.

PVC requests storage and will bind to the PV defined above.

Step 2: Create the StatefulSet for MySQL
Now, let's define a StatefulSet for MySQL. StatefulSets are used when you need stable network identities and persistent storage for each pod.

StatefulSet Definition for MySQL
yaml
Copy
Edit
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: dev
spec:
  serviceName: "mysql"
  replicas: 1  # You can scale this number later
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:latest
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "Test@123"
            - name: MYSQL_DATABASE
              value: "chatapp"
          ports:
            - containerPort: 3306
          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql  # Mounting the PVC to this path
  volumeClaimTemplates:
    - metadata:
        name: mysql-data
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
Explanation:
StatefulSet ensures each MySQL pod has a persistent identity and storage.

volumeClaimTemplates: The PVC for MySQL storage is created dynamically for each replica. For a single replica, the PVC will be mysql-data-0 and will be bound to the defined PVC in the template.

volumeMounts: Mount the PVC to /var/lib/mysql in the container to store MySQL data persistently.

Step 3: Create a Service for StatefulSet
You need a headless service to manage access to the pods in the StatefulSet.

yaml
Copy
Edit
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: dev
spec:
  ports:
    - port: 3306
  clusterIP: None  # Headless service
  selector:
    app: mysql
Step 4: Apply the Resources
Apply the Persistent Volume, PVC, StatefulSet, and Service using kubectl:

bash
Copy
Edit
kubectl apply -f mysql-pv.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f mysql-service.yaml
Step 5: Verify StatefulSet and PVC
Ensure the StatefulSet and PVC are working correctly.

bash
Copy
Edit
kubectl get statefulset mysql -n dev
kubectl get pvc -n dev
kubectl get pods -n dev
Step 6: Create Horizontal Pod Autoscaler (HPA)
Horizontal Pod Autoscalers (HPA) allow you to scale your pods based on metrics like CPU or memory usage.

Metrics Server: Ensure that the Metrics Server is installed on your Kubernetes cluster. It collects resource usage data like CPU and memory usage.

If it's not already installed, you can install it using:

bash
Copy
Edit
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
Create HPA for MySQL StatefulSet

You can scale MySQL based on CPU or memory usage. Here’s an example of an HPA based on CPU usage.

yaml
Copy
Edit
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mysql-hpa
  namespace: dev
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: StatefulSet
    name: mysql
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
Explanation:
scaleTargetRef: Refers to the StatefulSet that will be scaled.

minReplicas and maxReplicas: The range of replicas.

metrics: The resource metric (e.g., CPU utilization) to trigger autoscaling. Here, we are scaling when CPU utilization goes above 80%.

Step 7: Apply the HPA
bash
Copy
Edit
kubectl apply -f mysql-hpa.yaml
Step 8: Verify HPA
Check the HPA status:

bash
Copy
Edit
kubectl get hpa -n dev
This will show you the scaling status based on the CPU utilization.

Conclusion
Step 1: Created a Persistent Volume and Persistent Volume Claim for MySQL.

Step 2: Created a StatefulSet to ensure MySQL pods are stable with persistent data.

Step 3: Created a service for MySQL to enable communication.

Step 4: Applied the resources to the cluster.

Step 5: Ensured that the StatefulSet and PVC are working.

Step 6: Set up an HPA for autoscaling based on CPU usage.


=================================================================

Steps for Deploying ChatApp with Matching Labels and HPA:
Deployment for ChatApp: This is the YAML for deploying your chatapp with proper labels and environment variables.

yaml
Copy
Edit
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chatapp
  namespace: dev
  labels:
    app: chatapp
spec:
  replicas: 1  # Initial number of replicas, can be scaled by HPA
  selector:
    matchLabels:
      app: chatapp
  template:
    metadata:
      labels:
        app: chatapp
    spec:
      containers:
      - name: chatapp
        image: shrij34/chatapp:v1  # Replace with your image
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_DATASOURCE_USERNAME
          value: "root"
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:mysql://mysql-service.dev.svc.cluster.local:3306/chatapp?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
        - name: SPRING_DATASOURCE_PASSWORD
          value: "Test@123"
        - name: SPRING_DATASOURCE_DRIVER_CLASS_NAME
          value: "com.mysql.cj.jdbc.Driver"
        volumeMounts:
        - name: chatapp-storage
          mountPath: /data  # Change based on app storage needs
      volumes:
      - name: chatapp-storage
        persistentVolumeClaim:
          claimName: chatapp-pvc  # Create a PVC to attach a volume (optional, if persistent data is needed)
Horizontal Pod Autoscaler (HPA) for ChatApp: Next, we define an HPA that will allow your chatapp deployment to scale horizontally based on the CPU utilization.

yaml
Copy
Edit
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: chatapp-hpa
  namespace: dev
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: chatapp
  minReplicas: 1  # Minimum replicas, adjust based on requirements
  maxReplicas: 5  # Maximum replicas for autoscaling
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80  # Adjust threshold for CPU utilization
Persistent Volume Claim (PVC) for ChatApp (if required): If your chatapp needs persistent storage (like logs or files), you can create a PVC. Here’s an example of how you can create a PVC:

yaml
Copy
Edit
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: chatapp-pvc
  namespace: dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi  # Size of the persistent volume
Headless Service for ChatApp (if needed): If you want to make your chatapp accessible by a headless service (e.g., for direct pod-to-pod communication or DNS resolution), you can configure it as follows:

yaml
Copy
Edit
apiVersion: v1
kind: Service
metadata:
  name: chatapp-service
  namespace: dev
spec:
  clusterIP: None  # Headless service, useful for pod-to-pod communication
  selector:
    app: chatapp
  ports:
    - port: 8080
      targetPort: 8080
How It Works:
Deployment:

The deployment ensures that the chatapp application is running with the required environment variables.

The container image is deployed as specified, and it is exposed on port 8080.

Volumes are mounted if necessary.

Horizontal Pod Autoscaler (HPA):

The HPA will automatically scale the chatapp deployment based on CPU utilization.

You can adjust the minReplicas, maxReplicas, and the target CPU utilization to suit your scaling needs.

Persistent Volume Claim (PVC):

If your app needs persistent storage, the PVC will ensure that the data is retained even if the pod is restarted.

This is useful if your application stores data like logs or user-generated content.

Once you apply these YAML files, Kubernetes will handle scaling, deployment, and storage management for you. You can now test and deploy your application in the cluster using Helm or kubectl.







You said:
hoe to apply
ChatGPT said:
To apply the YAML files to your Kubernetes cluster, follow these steps:

Step 1: Create YAML Files
Create a new directory (if needed) to organize your Kubernetes files:

bash
Copy
Edit
mkdir -p ~/k8s/deployment
cd ~/k8s/deployment
Create the YAML files for your deployment and HPA. For example:

bash
Copy
Edit
nano chatapp-deployment.yaml
Paste the deployment YAML (the first step in the previous response) into the file and save it.

Then, create the Horizontal Pod Autoscaler (HPA):

bash
Copy
Edit
nano chatapp-hpa.yaml
Paste the HPA YAML (the second step in the previous response) into the file and save it.

If you're using Persistent Volume Claim (PVC), create another file for that:

bash
Copy
Edit
nano chatapp-pvc.yaml
Paste the PVC YAML into the file and save it.

Step 2: Apply the YAML Files to the Cluster
Make sure you're connected to your Kubernetes cluster (in your case, Kind in WSL2). Then, run the following commands to apply your files:

Apply the Deployment:

bash
Copy
Edit
kubectl apply -f chatapp-deployment.yaml
Apply the Horizontal Pod Autoscaler:

bash
Copy
Edit
kubectl apply -f chatapp-hpa.yaml
Apply the Persistent Volume Claim (if you're using one):

bash
Copy
Edit
kubectl apply -f chatapp-pvc.yaml
Verify the Resources:

After applying the files, you can verify that everything is running as expected.

Check the deployment:

bash
Copy
Edit
kubectl get deployments -n dev
Check the HPA:

bash
Copy
Edit
kubectl get hpa -n dev
Check the PVC (if used):

bash
Copy
Edit
kubectl get pvc -n dev
Check the pods:

bash
Copy
Edit
kubectl get pods -n dev
Check the service:

bash
Copy
Edit
kubectl get svc -n dev
Step 3: Monitor and Scale the Application
Check HPA scaling: You can monitor the scaling behavior based on CPU usage by using the following command:

bash
Copy
Edit
kubectl get hpa chatapp-hpa -n dev
Check Pod Logs: You can check the logs of the pods to verify the application is working:

bash
Copy
Edit
kubectl logs <pod-name> -n dev
Scale manually if needed: If you want to manually scale your application (i.e., to test the autoscaler), you can run:

bash
Copy
Edit
kubectl scale deployment chatapp --replicas=3 -n dev
Step 4: Cleanup (Optional)
If you want to delete all the resources you applied earlier, run:

bash
Copy
Edit
kubectl delete -f chatapp-deployment.yaml
kubectl delete -f chatapp-hpa.yaml
kubectl delete -f chatapp-pvc.yaml
Summary
Create the YAML files for your chatapp deployment, HPA, and PVC.

Apply the YAML files using kubectl apply -f <file-name>.

Verify the resources are correctly applied using kubectl get commands.

Optionally monitor the scaling of the application and pods.

Let me know if you face any issues during the process!







You said:
where pv for chat?
ChatGPT said:
To set up a Persistent Volume (PV) for your chatapp application, you need to create both a Persistent Volume (PV) and a Persistent Volume Claim (PVC), which the chatapp deployment will use to persist data.

Step-by-Step to Create PV and PVC for MySQL (or any other service)
1. Create a Persistent Volume (PV)
A PV is a piece of storage in your cluster. It is an abstraction layer that represents storage resources in the cluster. Here’s an example of how to define a PersistentVolume in YAML.

Create a file called chatapp-pv.yaml:

yaml
Copy
Edit
apiVersion: v1
kind: PersistentVolume
metadata:
  name: chatapp-pv
  namespace: dev
spec:
  capacity:
    storage: 10Gi  # Adjust the size based on your needs
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce  # Allows a single pod to read/write
  persistentVolumeReclaimPolicy: Retain  # Can be Recycle, Retain, or Delete
  storageClassName: standard
  hostPath:
    path: "/mnt/data/chatapp"  # Path to the storage location on your host machine
Here, we're using a hostPath which is suitable for local development, such as in KinD and WSL2. For production clusters, you'd use cloud-backed PVs like AWS EBS or GCP Persistent Disks.

2. Create a Persistent Volume Claim (PVC)
The PersistentVolumeClaim (PVC) is how your application requests storage from a PV. It specifies the size, access mode, and other requirements.

Create a file called chatapp-pvc.yaml:

yaml
Copy
Edit
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: chatapp-pvc
  namespace: dev
spec:
  accessModes:
    - ReadWriteOnce  # Matches PV access mode
  resources:
    requests:
      storage: 10Gi  # Match or smaller than the PV's size
  storageClassName: standard
This PVC will claim the chatapp-pv created above.

3. Update the Deployment to Use PVC
Now, update your chatapp deployment YAML to mount the PVC as a volume. You will add the volume under spec.volumes and then mount it inside your container.

Here's an updated version of your chatapp deployment YAML with the PVC mounted:

yaml
Copy
Edit
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chatapp
  namespace: dev
  labels:
    app: chatapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chatapp
  template:
    metadata:
      labels:
        app: chatapp
    spec:
      containers:
      - name: chatapp
        image: shrij34/chatapp:v1
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_DATASOURCE_USERNAME
          value: "root"
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:mysql://mysql-service:3306/chatapp?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
        - name: SPRING_DATASOURCE_PASSWORD
          value: "Test@123"
        volumeMounts:
        - name: chatapp-storage
          mountPath: /var/lib/mysql  # Assuming MySQL data will be stored here
      volumes:
      - name: chatapp-storage
        persistentVolumeClaim:
          claimName: chatapp-pvc  # PVC reference
This configuration tells Kubernetes to mount the storage requested by the PVC at /var/lib/mysql inside the chatapp container. You can modify the mountPath based on your application’s requirements.

4. Apply the YAML Files
Apply the Persistent Volume:

bash
Copy
Edit
kubectl apply -f chatapp-pv.yaml
Apply the Persistent Volume Claim:

bash
Copy
Edit
kubectl apply -f chatapp-pvc.yaml
Apply the Deployment (if you haven’t already):

bash
Copy
Edit
kubectl apply -f chatapp-deployment.yaml
5. Verify the Resources
Once you've applied all the YAML files, check the status of the PV, PVC, and pods:

Verify the PV:

bash
Copy
Edit
kubectl get pv -n dev
Verify the PVC:

bash
Copy
Edit
kubectl get pvc -n dev
Verify the pods:

bash
Copy
Edit
kubectl get pods -n dev
Check the logs of the pod:

bash
Copy
Edit
kubectl logs <pod-name> -n dev
Summary
Persistent Volume (PV): Defines the physical storage.

Persistent Volume Claim (PVC): Requests storage for your application.

Deployment: Uses the PVC as a volume to store data in your container.

Let me know if you need more details!