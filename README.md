# StrongDM Gateways Deployed with Kubernetes 

Example Usage
~~~
module "aws_eks_sdm_gateway" {
  source = "./modules/terraform_aws_eks_strongdm_gateways"
  
  sdm_port = 5000
  sdm_app_name = "sdm-gateway"
  sdm_gateway_name = "aws-eks-gateway"
} 
~~~