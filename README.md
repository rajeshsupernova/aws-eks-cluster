[[_TOC_]]

# How to install
## Test/Production
### Create and configure EKS cluster for MyCluster
Please click [here](docs/production_eks.md) for instructions to create an EKS cluster for QA/Demo/Production

## System Admin

### Adding Admin Users
```
eksctl create iamidentitymapping --region ap-south-1 --cluster cluster-name --arn arn:aws:iam::aws-account-id:user/your-iam-user --username your-iam-user --group system:masters
```

### Loki Stack
Please click [here](docs/loki.md) to install Loki Stack (Loki/Grafana/Prometheus)
