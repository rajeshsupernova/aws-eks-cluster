<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]





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
