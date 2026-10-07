# Architecture

## Overview

O `devops-fundamentals` é um laboratório local de DevOps baseado em uma aplicação Spring Boot e uma infraestrutura Docker provisionada através do Terraform.

A arquitetura foi desenhada para permitir que a aplicação e o banco de dados se comuniquem através de uma rede Docker interna, sem publicar as portas da aplicação ou do banco no host.

---

# High-Level Architecture

```text
                         GitHub
                            │
                            │ Push / Pull Request
                            ▼
                    ┌─────────────────┐
                    │ GitHub Actions  │
                    └────────┬────────┘
                             │
                 ┌───────────┼───────────┐
                 │           │           │
                 ▼           ▼           ▼
              Tests        Build    Docker Build
                 │           │           │
                 └───────────┴───────────┘
                             │
                             ▼
                        Docker Image
                             │
                             ▼
                         Terraform
                             │
                             ▼
                       Docker Engine
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
        Spring Boot API             PostgreSQL
        devops-fundamentals-api     devops-fundamentals-db
                │                         │
                └──────────┬──────────────┘
                           │
                           ▼
             devops-fundamentals-network
```

---

# Application Architecture

A aplicação segue uma estrutura tradicional em camadas:

```text
src/main/java/com/marconi/devops/

├── controller/
│   └── TaskController
│
├── service/
│   └── TaskService
│
├── repository/
│   └── TaskRepository
│
├── entity/
│   └── Task
│
├── dto/
│   ├── TaskRequest
│   └── TaskResponse
│
└── exception/
    ├── TaskNotFoundException
    └── GlobalExceptionHandler
```

Fluxo de uma requisição:

```text
HTTP Request
     │
     ▼
Controller
     │
     ▼
Service
     │
     ▼
Repository
     │
     ▼
PostgreSQL
```

---

# Infrastructure Architecture

O Terraform é responsável pela infraestrutura Docker.

```text
Terraform
    │
    ├── Docker Network
    │
    ├── PostgreSQL Image
    │
    ├── PostgreSQL Container
    │
    ├── API Image
    │
    └── API Container
```

Resources principais:

```text
docker_network.app_network

docker_image.postgres
docker_container.postgres

docker_image.api
docker_container.api
```

---

# Docker Network

A infraestrutura cria:

```text
devops-fundamentals-network
```

Os dois containers são conectados a essa rede:

```text
devops-fundamentals-network
        │
        ├── devops-fundamentals-api
        │
        └── devops-fundamentals-db
```

Isso permite que a API encontre o PostgreSQL através do hostname:

```text
devops-fundamentals-db
```

---

# Database Connectivity

A API utiliza:

```text
jdbc:postgresql://devops-fundamentals-db:5432/devops_fundamentals
```

O fluxo é:

```text
Spring Boot
     │
     │ JDBC
     ▼
Docker DNS
     │
     │ devops-fundamentals-db
     ▼
PostgreSQL Container
     │
     ▼
Database
```

O uso do hostname do container é importante.

Dentro de um container:

```text
localhost
```

representa o próprio container.

Por isso a API não pode utilizar:

```text
localhost:5432
```

para encontrar o PostgreSQL.

Ela utiliza:

```text
devops-fundamentals-db:5432
```

---

# Network Security

A arquitetura não publica as portas da API ou do PostgreSQL no host.

Os containers possuem suas portas internas:

```text
API        → 8080/tcp
PostgreSQL → 5432/tcp
```

Porém não existe:

```text
0.0.0.0:8080->8080
0.0.0.0:5432->5432
```

Portanto:

```text
Host Fedora
     │
     │
     X──── API
     │
     X──── PostgreSQL
     │
     ▼
Docker Network
```

A comunicação acontece internamente:

```text
API ───────────────► PostgreSQL
     Docker Network
```

---

# PostgreSQL Persistence

O PostgreSQL utiliza um volume Docker:

```text
devops-fundamentals-postgres-data
```

Montado em:

```text
/var/lib/postgresql/data
```

Arquitetura:

```text
PostgreSQL Container
        │
        ▼
/var/lib/postgresql/data
        │
        ▼
Docker Volume
        │
        ▼
devops-fundamentals-postgres-data
```

Isso permite que os dados sobrevivam à recriação do container.

---

# Terraform State

O Terraform mantém o estado da infraestrutura localmente.

O state representa recursos como:

```text
docker_network.app_network
docker_image.postgres
docker_container.postgres
docker_image.api
docker_container.api
```

O state não é versionado no Git.

Arquivos ignorados:

```text
terraform/.terraform/
terraform/*.tfstate
terraform/*.tfstate.*
```

O lock file é versionado:

```text
terraform/.terraform.lock.hcl
```

---

# CI Pipeline

O GitHub Actions executa o pipeline:

```text
Push / Pull Request
        │
        ▼
   Checkout
        │
        ▼
   Setup Java 25
        │
        ▼
   Maven Tests
        │
        ▼
   Build JAR
        │
        ▼
 Upload Artifact
        │
        ▼
 Docker Build
```

O job de build depende do sucesso dos testes.

```text
Test
 │
 └── sucesso
       │
       ▼
     Build
       │
       └── sucesso
             │
             ▼
        Docker Build
```

---

# Test Architecture

Os testes utilizam Testcontainers.

```text
Spring Boot Test
       │
       ▼
Testcontainers
       │
       ▼
PostgreSQL Container
       │
       ▼
Integration Test
```

Isso permite executar os testes usando uma instância real do PostgreSQL.

---

# Deployment Model

Atualmente o projeto utiliza um modelo **local**.

Não existe dependência obrigatória de:

* AWS
* Azure
* GCP
* Kubernetes
* Container Registry externo

A infraestrutura é executada através de:

```text
Fedora
  │
  ▼
Docker Engine
  │
  ▼
Terraform
  │
  ├── API
  └── PostgreSQL
```

---

# Infrastructure Lifecycle

O ciclo de vida da infraestrutura é:

```text
Terraform Configuration
        │
        ▼
terraform init
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
terraform apply
        │
        ▼
Docker Infrastructure
```

Para destruir a infraestrutura gerenciada:

```bash
terraform destroy
```

Isso deve ser utilizado apenas quando a infraestrutura puder ser removida.

---

# Design Decisions

## Terraform local

Terraform foi utilizado mesmo sem cloud para praticar Infrastructure as Code.

O objetivo é aprender os conceitos antes de migrar a infraestrutura para AWS ou Azure.

---

## Docker Provider

O provider Docker permite que o Terraform gerencie:

* networks;
* images;
* containers;
* volumes.

Isso transforma a infraestrutura Docker em código declarativo.

---

## Internal communication

A comunicação API → PostgreSQL utiliza a rede Docker em vez de portas publicadas no host.

Isso reduz a superfície de exposição da infraestrutura local.

---

## Local state

O projeto utiliza local state por ser um laboratório individual.

Em ambientes reais, seria necessário avaliar:

* remote state;
* state locking;
* controle de acesso;
* secrets management;
* CI/CD para Terraform.

---

# Future Architecture

A evolução planejada pode seguir:

```text
Current

GitHub
   ↓
GitHub Actions
   ↓
Docker
   ↓
Terraform
   ↓
API + PostgreSQL
```

Para uma arquitetura mais próxima de produção:

```text
GitHub
   ↓
CI
   ↓
Tests
   ↓
Build
   ↓
Security Scan
   ↓
Container Registry
   ↓
Terraform
   ↓
Cloud Infrastructure
   ↓
Application Deployment
   ↓
Monitoring
```

Possíveis tecnologias futuras:

* AWS
* Azure
* Terraform Cloud
* Container Registry
* Kubernetes
* Prometheus
* Grafana
* OpenTelemetry
* Secret Management

Essas tecnologias não são necessárias para executar o laboratório atual.
