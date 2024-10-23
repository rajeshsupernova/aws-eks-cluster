# create cluster with no nodes
##todo: create vpc first before cluster https://docs.aws.amazon.com/vpc/latest/userguide/vpc-subnets-commands-example.html
eksctl create cluster --config-file non-prod-cluster-no-nodes.yaml

# create the new node group
eksctl create nodegroup --config-file non-prod-cluster.yaml


#create volume for redis
aws ec2 create-volume --availability-zone eu-west-1b --size 2 --encrypted --volume-type gp3 --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=mi4-demo-redis}]'

# Guides
https://jwenz723.medium.com/amazon-vpc-cni-vs-calico-cni-vs-weave-net-cni-on-eks-b0ad8102e849











# aws secrets manager
helm repo add secrets-store-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/charts
helm -n kube-system install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set grpcSupportedProviders="aws"
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml


# nginx ingress
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.service.externalTrafficPolicy="Local"  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-proxy-protocol"="*"  --set controller.config.use-proxy-protocol="true" --set controller.config.enable-real-ip="true" --set controller.config.forwarded-for-header="proxy_protocol" -f eks/ingress-values.yaml 

# guide
https://weaveworks-gitops.awsworkshop.io/25_workshop_2_ha-dr/50_add_yamls/10_alb_ingress.html

# guide
https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html

# system user
use this guide and add users
https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
kubectl edit -n kube-system configmap/aws-auth

# get kube config
aws eks --region eu-west-1 update-kubeconfig --name MyCluster-nonprod

# deployment user
https://www.eksworkshop.com/intermediate/220_codepipeline/


# cloud watch
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html



ClusterName=MyCluster-nonprod
RegionName=eu-west-1
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -


uninstall 
remove curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${LogRegion}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl delete -f -