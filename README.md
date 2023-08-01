

**Steps to deploy!**


* Navigate to the Backup & Restore directory:

* Create the Service Principal, representing Velero, to perform backups & restores:

```bash
az ad sp create-for-rbac --name sp-velero-aks1 --role Reader --scopes /subscriptions/{subscriptionId}
```

* Deploy the Terraform sample code:

```bash
terraform init
terraform plan
terraform apply
```



  - Connect to the Primary AKS Cluster (following the sample code as is): 
  ```bash
     az aks get-credentials --name primary-aks1 --overwrite-existing --resource-group primary-aks1
  ```
  
   - Check that velero is installed and running correctly: 
    ```bash
    kubectl get pods -n velero
    ```
    
    

* Deploy [sample stateful applications](./applications_samples/) in the primary cluster:

   ```bash
    kubectl apply -f ../applications_samples/
  ```

   - Wait for the applications to be running
    ```bash
    kubectl get pods --all-namespaces -w
    ```
   - Create some data files (to test backups and restores):
  ```bash
  kubectl exec -it nginx-csi-disk-zrs -n csi-disk-zrs -- touch /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-csi-disk-lrs -n csi-disk-lrs -- touch /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-csi-file-zrs -n csi-file-zrs -- touch /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-file-lrs -n file-lrs -- touch /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginxstatefulset-0 -n diskstatefulset -- touch /mnt/azuredisk/some-data-file.txt
  ```



    
  

     - Check that data is created :
  ```bash
  kubectl exec -it nginx-csi-disk-zrs -n csi-disk-zrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-csi-disk-lrs -n csi-disk-lrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-csi-file-zrs -n csi-file-zrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-file-lrs -n file-lrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginxstatefulset-0 -n diskstatefulset -- ls /mnt/azuredisk/some-data-file.txt
  ```

* Create a backup for primary AKS cluster: (You can [filter resources to backup](https://velero.io/docs/v1.8/resource-filtering/))

   ```bash
  velero backup create manual-backup1  -w
    ```
  ![Create backup](./media/create_backup.png)

* Describe created backup:

   ```bash
  velero backup describe manual-backup1 --details
    ```
     ![Describe backup](./media/describe_backup.png)

* Restore to secondary AKS cluster:
  - Connect to the Secondary / Backup AKS Cluster (following the sample code as is): 
    ```bash
    az aks get-credentials --name aks-dr --overwrite-existing --resource-group aks-dr
    ```

  - Check running pods :
    ```bash
    kubectl get pods --all-namespaces
    ```

  - As Velero is configured, in the secondary backup cluster, to reference the same backup location (storage account container), You should see the same backups available :
    ```bash
    velero backup get
    ```
     ![Velero check install screenshot](./media/list_backups.png)
  
  - Restore from backup : (you may get a partially failed status when trying to restore existing objects, such as kube-system resources). 
    ```bash
    velero restore create restore1 --from-backup manual-backup1 -w
    ```
     ![Create Restore](./media/create_restore.png)

* Check that Restore is successful:
  - Check restored applications / pods
    ```bash
    kubectl get pods --all-namespaces
    ```
  - check restore details 
    ```bash
    velero restore get restore1
    ```
     ```bash
    velero restore describe restore1 --details
    ```
  
   - check restore logs 
        ```bash
        velero restore logs restore1
        ```
  
   - Check that data is restored (verify existence of data files):
  ```bash
  kubectl exec -it nginx-csi-disk-zrs -n csi-disk-zrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-csi-disk-lrs -n csi-disk-lrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-csi-file-zrs -n csi-file-zrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginx-file-lrs -n file-lrs -- ls /mnt/azuredisk/some-data-file.txt
  ```
  ```bash
  kubectl exec -it nginxstatefulset-0 -n diskstatefulset -- ls /mnt/azuredisk/some-data-file.txt
  ```
 