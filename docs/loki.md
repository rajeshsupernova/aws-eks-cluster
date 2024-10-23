# Install loki-stack
* Add the helm repo
    ```
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    ```
* Create the volumes for persistent storage
  * Run the command and add the arn to loki-volume.yaml 
    ``` 
    aws ec2 create-volume --availability-zone eu-west-1b  --encrypted --size 30 --volume-type gp3 --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=loki}]'
    ```
  * Run the command and add the arn to grafana-volume.yaml
    ```
    aws ec2 create-volume --availability-zone eu-west-1b  --encrypted --size 10 --volume-type gp3 --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=grafana}]'
    ```
  * Run the command and add the arn to prometheus-volume.yaml
    ```
    aws ec2 create-volume --availability-zone eu-west-1b  --encrypted --size 50 --volume-type gp3 --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=prometheus}]'
    ```
  * Create name space
    ```
    kubectl create ns loki
    ```
  * Create volumes and ingress
    ```
    kubectl apply -f ./loki/deploy
    ```
  * Install the helm chart with custom values file
    ```
    helm upgrade --namespace=loki --create-namespace --install loki grafana/loki-stack  -f .\loki\lokiValues.yaml
    ```

# View admin password
```
$password = kubectl get secret --namespace loki loki-grafana -o jsonpath="{.data.admin-password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
```
# Uninstall loki stack
```
helm uninstall --namespace=loki loki
kubectl delete -f ./loki/deploy
kubectl delete ns loki
```


# Other stuff that not tested/applied
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics
https://grafana.com/grafana/dashboards/13824/reviews
```