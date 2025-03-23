1. ERROR: error during connect: Head "http://127.0.0.1:2375/_ping": dial tcp 127.0.0.1:2375: connectex: No connection could be made because the target machine actively refused it.

SLN :

This error typically occurs when Docker is unable to connect to the Docker daemon. Here are some steps you can try to resolve it:

1. **Enable Docker Daemon on TCP**:
   - Open Docker Desktop.
   - Go to Settings > General.
   - Enable the option: *"Expose daemon on tcp://localhost:2375 without TLS."*
   - Restart Docker Desktop.

2. **Set the Environment Variable**:
   - Right-click on *This PC* > Properties > Advanced System Settings > Environment Variables.
   - Add a new variable:
     - Name: `DOCKER_HOST`
     - Value: `tcp://127.0.0.1:2375`
   - Restart your system.

3. **Check Docker Service**:
   - Ensure the Docker service is running. Open *Services* (search for it in the Start menu), find Docker, and start it if it's stopped.

4. **Firewall or Antivirus**:
   - Check if your firewall or antivirus is blocking the connection. Temporarily disable them to test.

5. **Restart Docker**:
   - Sometimes, simply restarting Docker Desktop or your system can resolve the issue.


2. ERROR: invalid tag "shrij34/ChatApp": repository name must be lowercase
 sln : keep image and tag name in lowercase


 3. Property apiVersion is not allowed.yaml-schema: RKE Cluster Configuration YAML(513)
   add , then 
 "yaml.schemas": {
        "https://raw.githubusercontent.com/kubernetes-sigs/kind/main/site/content/docs/user/kind-cluster-config-file.schema.json": ["cluster.yaml"]

   cluster.yaml is your file name

{
    "git.autofetch": true,
    "files.exclude": {
        "": true,
        "**/.git": false
    },
    "redhat.telemetry.enabled": false,
    "files.autoSave": "afterDelay",
    "yaml.schemas": {
        "https://raw.githubusercontent.com/kubernetes-sigs/kind/main/site/content/docs/user/kind-cluster-config-file.schema.json": ["cluster.yaml"]
    }


}