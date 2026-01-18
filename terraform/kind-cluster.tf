resource "kind_cluster" "gitops" {
  name           = "gitops-cluster"
  wait_for_ready = true
  node_image     = "kindest/node:v1.30.0"
}
