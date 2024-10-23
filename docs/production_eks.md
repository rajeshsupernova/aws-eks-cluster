# Set common variables
```
Set-Variable -Name "eks_cluster_name" -Value nonprod
Set-Variable -Name "eks_cluster_region" -Value eu-west-1
```
# Create VPC
```
aws --region $eks_cluster_region cloudformation deploy --template-file .\eks\vpc.yaml  --stack-name $eks_cluster_name
```
# Create cluster
## Before running below command update KMS key used for envelope encryption of Kubernetes secrets in eks\nonprod_cluster_template.yaml file. You can also customize nodes values based on requirements.
```
Set-Content -Path eks\$eks_cluster_name.clusterConfig.yaml -Value $(Get-Content -Path "eks\nonprod_cluster_template.yaml").Replace('#eks_cluster_name#',$eks_cluster_name).Replace('#eks_cluster_region#',$eks_cluster_region).Replace('#VPCID#',$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name $eks_cluster_name --query "Stacks[0].Outputs[?OutputKey=='VPC'].OutputValue"  --output text)).Replace('#privateSubnet1#',$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name $eks_cluster_name --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet1'].OutputValue"  --output text)).Replace('#privateSubnet2#',$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name $eks_cluster_name --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet2'].OutputValue"  --output text)).Replace('#privateSubnet3#',$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name $eks_cluster_name --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnet3'].OutputValue"  --output text)).Replace('#publicSubnet1#',$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name $eks_cluster_name --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1'].OutputValue"  --output text)).Replace('#publicSubnet2#',$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name $eks_cluster_name --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2'].OutputValue"  --output text)).Replace('#publicSubnet3#',$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name $eks_cluster_name --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet3'].OutputValue"  --output text))
```
```
eksctl create cluster --config-file eks\$eks_cluster_name.clusterConfig.yaml --without-nodegroup
```
# Delete the Amazon VPC CNI:
```
kubectl delete ds aws-node -n kube-system
```
# Install Weave Net CNI
```
kubectl.exe apply -f "https://cloud.weave.works/k8s/net?k8s-version=$([Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($(kubectl.exe version))))"
## or
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```
# add the nodes to cluster
```
eksctl create nodegroup -f eks\$eks_cluster_name.clusterConfig.yaml
```
# Add efs driver
## notes: https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/examples/kubernetes/access_points/README.md
```

aws iam create-policy --policy-name EKS_EFS_CSI_Driver_Policy  --policy-document file://eks/iam-policy-example.json
```
```
eksctl create iamserviceaccount --cluster $eks_cluster_name --namespace kube-system --name efs-csi-controller-sa  --attach-policy-arn arn:aws:iam::518955882229:policy/EKS_EFS_CSI_Driver_Policy --approve --region $eks_cluster_region
```
```
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
```
```
helm repo update
```
```
kubectl apply -f .\eks\efs-storage-class.yaml
```
```
helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver
```
# Add EBS_CSI_Driver add on
## Refrence: https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html , https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html , https://github.com/kubernetes-sigs/aws-ebs-csi-driver
```
eksctl utils associate-iam-oidc-provider --region=$eks_cluster_region --cluster=ibb-qa --approve
```

```
eksctl create iamserviceaccount --region $eks_cluster_region --name ebs-csi-controller-sa --namespace kube-system --cluster $eks_cluster_name --role-name AmazonEKS_EBS_CSI_DriverRole --role-only --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve
```
```
eksctl create addon --name aws-ebs-csi-driver --region $eks_cluster_region --cluster $eks_cluster_name --service-account-role-arn arn:aws:iam::518955882229:role/AmazonEKS_EBS_CSI_DriverRole --force
```
```

###If you use a custom KMS key for encryption on your Amazon EBS volumes, customize the IAM role as needed. For example, do the following. Copy and paste the following code into a new kms-key-for-encryption-on-ebs.json file. Replace custom-key-arn with the custom KMS key ARN 

```
```
Set-Content -Path eks\kms-key-for-encryption-on-ebs.json -Value $(Get-Content -Path "eks\kms-key-for-encryption-on-ebs.json").Replace('your_kms_arn','arn:aws:kms:$eks_cluster_region:518955882229:key/25183f63-4c6c-434c-9191-9f4373a83e7e')
```
```
aws iam create-policy --policy-name KMS_Key_For_Encryption_On_EBS_Policy --policy-document file://kms-key-for-encryption-on-ebs.json
```
```
aws iam attach-role-policy --policy-arn arn:aws:iam::518955882229:policy/KMS_Key_For_Encryption_On_EBS_Policy --role-name AmazonEKS_EBS_CSI_DriverRole
```

# Install ALB load balancer
## https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/

```
eksctl utils associate-iam-oidc-provider --region $eks_cluster_region --cluster $eks_cluster_name --approve
```
```
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.9.0/docs/install/iam_policy.json
```
```
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json
```
```
eksctl create iamserviceaccount --cluster=$eks_cluster_name --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::518955882229:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --region $eks_cluster_region --approve
```
```
helm repo add eks https://aws.github.io/eks-charts
```
```
helm repo update
```
```
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
```
```
helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$eks_cluster_name --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller  --set hostNetwork=true --install
```
# Install Metrics server
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server --set hostNetwork.enabled=true --set containerPort=1030
```

# cluster auto scaling
```
aws iam create-policy --policy-name AmazonEKSClusterAutoscalerPolicy --policy-document file://eks/cluster-autoscaler-policy.json
```
```
eksctl utils associate-iam-oidc-provider --region=$eks_cluster_region --cluster=$eks_cluster_name --approve
```
```
eksctl create iamserviceaccount --region=$eks_cluster_region --cluster=$eks_cluster_name --namespace=kube-system --name=cluster-autoscaler --override-existing-serviceaccounts --approve --attach-policy-arn=arn:aws:iam::518955882229:policy/AmazonEKSClusterAutoscalerPolicy
```
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```
```
kubectl annotate serviceaccount cluster-autoscaler --overwrite -n kube-system eks.amazonaws.com/role-arn=$(aws --region $eks_cluster_region cloudformation describe-stacks --stack-name eksctl-$eks_cluster_name-addon-iamserviceaccount-kube-system-cluster-autoscaler --query "Stacks[0].Outputs[?OutputKey=='Role1'].OutputValue"  --output text)
```
```
Set-Content -Path eks\$eks_cluster_name.cluster-autoscaler.patch.yaml -Value $(Get-Content -Path "eks\cluster-autoscaler.patch.yaml").Replace('#YOUR CLUSTER NAME#',$eks_cluster_name)
```
```
kubectl patch deployment cluster-autoscaler -n kube-system --patch-file .\eks\$eks_cluster_name.cluster-autoscaler.patch.yaml
```

# aws-node-termination-handler
```
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-node-termination-handler --namespace kube-system eks/aws-node-termination-handler
```

# Delete cluster
```
kubectl delete -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
aws --region $eks_cluster_region cloudformation delete-stack --stack-name eksctl-$eks_cluster_name-addon-iamserviceaccount-kube-system-cluster-autoscaler
aws --region $eks_cluster_region cloudformation delete-stack --stack-name eksctl-$eks_cluster_name-addon-iamserviceaccount-kube-system-aws-load-balancer-controller
eksctl delete cluster $eks_cluster_name
aws --region $eks_cluster_region cloudformation delete-stack --stack-name $eks_cluster_name
```
