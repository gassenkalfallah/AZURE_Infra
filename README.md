
# ☁️ AKS Multi-Cluster Backup & Restore with Velero – DevOps Project

This project demonstrates the full setup of a **multi-cluster Azure Kubernetes environment** with **Velero-based backup and disaster recovery**. It includes automated provisioning of two AKS clusters using **Terraform**, and deploying stateful applications with persistent volumes, backups, and restore validation.

---

## 📖 Project Scope

- 🔨 Provision **two AKS clusters** (`primary-aks1` and `aks-dr`) using Terraform modules
- 🔁 Implement backup and disaster recovery with Velero and Azure Blob Storage
- 📦 Deploy sample stateful applications (e.g., NGINX with PVCs)
- 🔁 Validate end-to-end data recovery across clusters

---

## 🛠️ Tech Stack

| Component        | Technology                     |
|------------------|--------------------------------|
| Cloud Provider   | Microsoft Azure                |
| Kubernetes       | AKS (Azure Kubernetes Service) |
| IaC              | Terraform                      |
| Backup/Restore   | Velero + Azure Blob Storage    |
| Scripting        | Bash, kubectl, Azure CLI       |

---

## 🔧 Infrastructure Setup (Terraform)

### 🟩 Step 1: Provision Primary Cluster

```bash
cd terraform/primary-cluster/
terraform init
terraform plan
terraform apply
```

Creates:
- AKS cluster `primary-aks1`
- Node pool
- Azure Storage Account for Velero backups
- IAM roles & service principal for Velero access

### 🟨 Step 2: Provision Disaster Recovery Cluster

```bash
cd terraform/dr-cluster/
terraform init
terraform plan
terraform apply
```

Creates:
- AKS cluster `aks-dr`
- Identical storage backend (Velero backup container shared)
- RBAC configuration for restore permissions

### 🛡️ Azure Service Principal for Velero

```bash
az ad sp create-for-rbac --name sp-velero-aks1 --role Reader --scopes /subscriptions/{subscriptionId}
```

---

## 🚀 Application Deployment & Backup Workflow

### 🔁 Connect to Primary Cluster

```bash
az aks get-credentials --name primary-aks1 --resource-group primary-aks1
kubectl get pods -n velero
```

### 📦 Deploy Stateful Applications

```bash
kubectl apply -f ../applications_samples/
```

### 📁 Create Sample Data

```bash
kubectl exec -it <pod-name> -- touch /mnt/azuredisk/some-data-file.txt
```

### 💾 Create a Backup

```bash
velero backup create manual-backup1 -w
```

### 🔄 Restore to DR Cluster

```bash
az aks get-credentials --name aks-dr --resource-group aks-dr
velero restore create restore1 --from-backup manual-backup1 -w
```

---

## ✅ Results

- Full infrastructure provisioning automated via Terraform
- Cluster-to-cluster disaster recovery validated
- PVC-based applications restored with preserved data

---

## 🙋 Author

**Ghassen Khalfallah**  
DevOps & Cloud Automation Engineer  
[Portfolio](https://gassenkalfallah.github.io/portfolio) | [GitHub](https://github.com/GassenKalfallah) | [LinkedIn](https://www.linkedin.com/in/ghassenkhalfallah)

---

## 📝 Note

This project is sanitized for educational purposes. Secrets and credentials are not included.
