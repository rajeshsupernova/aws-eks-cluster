# Set common variables
```
Set-Variable -Name "eks_cluster_name" -Value nonprod
Set-Variable -Name "eks_cluster_region" -Value eu-west-1
Set-Variable -Name "eks_user_name" -Value <user>
```
# Add system users
eksctl create iamidentitymapping --region $eks_cluster_region  --cluster $eks_cluster_name --arn arn:aws:iam::518955882229:user/$eks_user_name@qs.com --username $eks_user_name --group system:masters
# Add dev users

## One time Tasks (not needed)
aws iam create-role --role-name k8sDev --description "Kubernetes developer role (for AWS IAM Authenticator for Kubernetes)." --assume-role-policy-document file://eks/eks-developer-assume-role-policy.json --output text --query 'Role.Arn'
aws iam create-group --group-name k8sDev
aws iam put-group-policy --group-name k8sDev --policy-name k8sDev-policy --policy-document file://eks/assume-role-policy-document.json
## Admin
```
aws iam create-user --user-name $eks_user_name@qs.com
aws iam add-user-to-group --group-name k8sDev --user-name $eks_user_name@qs.com
aws iam add-user-to-group --group-name EKS-USERS --user-name $eks_user_name@qs.com
aws iam add-user-to-group --group-name eks-developer-group  --user-name $eks_user_name@qs.com
eksctl create iamidentitymapping --region $eks_cluster_region  --cluster $eks_cluster_name --arn arn:aws:iam::518955882229:user/$eks_user_name@qs.com --username $eks_user_name
aws iam create-access-key --user-name $eks_user_name@qs.com
```
## User
```
aws eks --region $eks_cluster_region update-kubeconfig --name $eks_cluster_name
```