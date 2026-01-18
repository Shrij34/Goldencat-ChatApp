terraform {
  required_version = ">= 1.5"
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.0"
    }
  }
}

# -------------------------
# KIND provider
# -------------------------
provider "kind" {}

# -------------------------
# KUBERNETES provider
# Dynamically reads kubeconfig from the Kind cluster output
# -------------------------
provider "kubernetes" {
  host                   = kind_cluster.gitops.endpoint
  client_certificate     = kind_cluster.gitops.client_certificate
  client_key             = kind_cluster.gitops.client_key
  cluster_ca_certificate = kind_cluster.gitops.cluster_ca_certificate
}

# -------------------------
# HELM provider
# Uses the same Kubernetes provider output
# -------------------------
provider "helm" {
  kubernetes {
    host                   = kind_cluster.gitops.endpoint
    client_certificate     = kind_cluster.gitops.client_certificate
    client_key             = kind_cluster.gitops.client_key
    cluster_ca_certificate = kind_cluster.gitops.cluster_ca_certificate
  }
}
