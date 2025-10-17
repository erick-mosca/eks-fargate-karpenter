# 🚀 EKS + Karpenter + Fargate

[![Terraform](https://img.shields.io/badge/Terraform-IaC-blueviolet?logo=terraform)](https://www.terraform.io/)
[![AWS EKS](https://img.shields.io/badge/AWS-EKS-orange?logo=amazon-aws)](https://aws.amazon.com/eks/)

Infraestrutura completa para criação de um **cluster EKS** com suporte a **Karpenter** e **AWS Fargate**, utilizando **Terraform**.  
Ideal para cenários que exigem escalabilidade automática e workloads híbridos (EC2 + Fargate).

---

## 🧭 Visão Geral

Este projeto implementa:
- **Amazon EKS** como orquestrador Kubernetes gerenciado.
- **Karpenter** para provisionamento dinâmico de nós sob demanda.
- **AWS Fargate** para execução serverless de pods.
- **Terraform** para gerenciar todos os recursos como código.

---

## 📁 Estrutura

| Arquivo / Módulo | Descrição |
|------------------|-----------|
| `main.tf` | Entrada principal — chama módulos e recursos. |
| `provider.tf` | Configura o provedor AWS. |
| `versions.tf` | Define versões mínimas de Terraform e providers. |
| `variables.tf` | Declara variáveis de entrada. |
| `terraform.tfvars` | Valores padrão das variáveis. |
| `vpc.tf` | Cria a VPC, sub-redes e gateways. |
| `eks.tf` | Configura o cluster EKS. |
| `karpenter.tf` | Instala e configura o Karpenter via Helm. |
| `backend.tf` | Define o backend remoto (state). |
| `outputs.tf` | Outputs após criação. |
| `example.yaml` | Exemplo de workload Kubernetes para teste. |

---

## ⚙️ Pré-requisitos

- AWS CLI configurada e autenticada.
- Terraform >= 1.6.
- Permissões AWS para criar EKS, VPC, IAM e EC2.

---

## 🚀 Implantação

```bash
# Inicializar
terraform init

# Visualizar plano
terraform plan -out=tfplan

# Aplicar
terraform apply
