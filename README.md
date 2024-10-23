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

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
-->




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

### Steps to Authenticate and access cluster.

Get Your STS Token from MFA and configure by executing [this](awsAuthMFA2.ps1) Powershell Script. Please edit this powrshell script in notepad and replace 'arn:aws:iam::518955882229:mfa/GA-Iphone14ProMax' with your MFA ARN before execution.

Prequisite : Install and configure [AWS CLI V2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).


Add-Ons Tools:
1. [Chocolatey](https://chocolatey.org/install#generic)
2. [eksctl](https://community.chocolatey.org/packages/eksctl)
3. [kubectl](https://community.chocolatey.org/packages/kubernetes-cli)
4. [k9s](https://community.chocolatey.org/packages/k9s)




<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links 
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt

-->