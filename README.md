# DevOps Fundamentals

Laboratório prático de DevOps construído com Java, Spring Boot, PostgreSQL, Docker, GitHub Actions e Terraform.

O objetivo deste projeto é estudar e praticar conceitos de **desenvolvimento backend, containers, CI, infraestrutura como código e networking**, mantendo toda a infraestrutura executando localmente.

> Este projeto foi desenvolvido como um laboratório de estudos, mas segue uma estrutura próxima de um projeto real.

---

## Stack

### Backend

* Java 25
* Spring Boot 4
* Spring Data JPA
* Hibernate
* PostgreSQL 17
* Maven

### DevOps

* Docker
* Docker Compose
* Terraform
* GitHub Actions
* Testcontainers

### Infraestrutura

Toda a infraestrutura deste laboratório roda localmente utilizando Docker.

Não é necessário utilizar AWS, Azure ou qualquer outro serviço cloud para executar o projeto.

---

## Arquitetura

```text
                         GitHub
                            │
                            ▼
                    GitHub Actions
                            │
                 ┌──────────┴──────────┐
                 │                     │
               Tests                  Build
                 │                     │
          Testcontainers               ▼
                 │               Docker Image
                 │                     │
                 └──────────┬──────────┘
                            │
                            ▼
                        Terraform
                            │
                     Docker Engine
                            │
             devops-fundamentals-network
                    ┌───────┴───────┐
                    │               │
                    ▼               ▼
              Spring Boot      PostgreSQL
                   API               DB
```

A documentação detalhada da arquitetura está em:

`docs/ARCHITECTURE.md`

---

# Objetivo do projeto

Este projeto funciona como um laboratório para estudar o fluxo:

```text
Código
  ↓
Testes
  ↓
Build
  ↓
Docker
  ↓
CI
  ↓
Terraform
  ↓
Infraestrutura local
```

A ideia é aprender DevOps **fazendo**, e não apenas estudando comandos isolados.

---

# Como estudar Terraform usando este projeto

Se você está começando em Terraform, não tente entender todos os arquivos de uma vez.

Siga a evolução abaixo.

---

## 1. Entenda o que o Terraform está fazendo

Entre na pasta:

```bash
cd terraform
```

Veja os arquivos:

```text
terraform/
├── environments/
│   ├── dev/
│   │   └── main.tf
│   └── prod/
│       └── main.tf
├── main.tf
├── variables.tf
├── outputs.tf
└── .terraform.lock.hcl
```

O Terraform trata todos os arquivos `.tf` de um mesmo diretório como uma única configuração.

---

## 2. Entenda o provider

No `main.tf` existe:

```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "docker" {}
```

O provider permite que o Terraform converse com o Docker.

A ideia é:

```text
Terraform
    │
    ▼
Docker Provider
    │
    ▼
Docker Engine
```

Estude primeiro:

* `terraform`
* `required_providers`
* `provider`

---

## 3. Entenda resources

O projeto utiliza resources como:

```hcl
resource "docker_network" "app_network" {
    ...
}
```

e:

```hcl
resource "docker_container" "postgres" {
    ...
}
```

A estrutura básica é:

```hcl
resource "TIPO" "NOME" {
    configuração
}
```

Por exemplo:

```hcl
resource "docker_network" "app_network" {
  name = "devops-fundamentals-network"
}
```

Leia esses resources e tente identificar:

* qual recurso está sendo criado;
* qual provider está sendo utilizado;
* quais propriedades são configuradas;
* quais recursos dependem de outros.

---

# 4. Entenda variáveis

O projeto utiliza:

```text
variables.tf
```

Exemplo:

```hcl
variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "devops_fundamentals"
}
```

Aprenda:

```text
variable
description
type
default
sensitive
```

Depois veja como a variável é utilizada:

```hcl
${var.postgres_db}
```

---

# 5. Entenda secrets

A senha do PostgreSQL não fica diretamente no código.

Ela é fornecida através de:

```bash
export TF_VAR_postgres_password='devops_local_secret_2026'
```

O Terraform reconhece automaticamente:

```text
TF_VAR_<nome_da_variável>
```

como valor da variável Terraform correspondente.

Por exemplo:

```text
TF_VAR_postgres_password
        │
        ▼
var.postgres_password
```

Isso permite estudar gerenciamento de variáveis sem colocar a senha diretamente no `.tf`.

---

# 6. Entenda outputs

O arquivo:

```text
outputs.tf
```

define informações que o Terraform pode apresentar depois da execução.

Exemplo:

```hcl
output "postgres_container" {
```
