# Arquitectura del Sistema

## 1. Visión General

El sistema está compuesto por tres microservicios desplegados en Amazon EKS, con observabilidad completa mediante CloudWatch y calidad garantizada por quality gates en el pipeline CI/CD.

## 2. Componentes

### 2.1 Microservicios

| Servicio | Tecnología | Puerto | Propósito |
|----------|------------|--------|-----------|
| **DB** | MySQL 8.0 | 3306 | Base de datos relacional |
| **Backend** | Spring Boot (Java 17) | 8080 API REST | Lógica de negocio |
| **Frontend** | React/Node.js | 3000 | Interfaz de usuario |

### 2.2 Infraestructura

| Componente | Servicio AWS | Propósito |
|------------|--------------|-----------|
| **EKS** | Amazon EKS | Orquestación de contenedores |
| **VPC** | Amazon VPC | Red aislada multi-AZ |
| **ECR** | Amazon ECR | Registro de imágenes Docker |
| **CloudWatch** | Amazon CloudWatch | Monitoreo y logs |
| **IAM** | AWS IAM | Control de acceso |

### 2.3 Herramientas CI/CD

| Herramienta | Propósito |
|-------------|-----------|
| **GitHub Actions** | Automatización de pipeline |
| **Docker** | Empaquetamiento de aplicaciones |
| **kubectl** | Gestión de Kubernetes |
| **Helm** | Gestión de paquetes (opcional) |

## 3. Diagrama de Red

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│                        VPC                              │
│  ┌───────────────────────────────────────────────────┐ │
│  │              Subnet Pública                       │ │
│  │  ┌─────────────────────────────────────────────┐  │ │
│  │  │            ALB (Load Balancer)              │  │ │
│  │  └─────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────┘ │
│                          │                              │
│  ┌───────────────────────────────────────────────────┐ │
│  │              Subnet Privada                       │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │ │
│  │  │   DB     │  │ Backend  │  │ Frontend │       │ │
│  │  │ (MySQL)  │  │  (API)   │  │  (Web)   │       │ │
│  │  └──────────┘  └──────────┘  └──────────┘       │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 4. Seguridad

### 4.1 Red
- Subnets privadas para microservicios
- Security Groups restrictivos
- VPC Endpoints para servicios AWS

### 4.2 Acceso
- IAM Roles para pods (IRSA)
- Secrets en GitHub Actions
- Credenciales temporales (STS)

### 4.3 Aplicación
- Health checks en cada pod
- Resource limits configurados
- Network policies (opcional)

## 5. Monitoreo

### 5.1 Logs
- Fluent Bit DaemonSet
- CloudWatch Logs
- Retención: 7 días

### 5.2 Métricas
- Container Insights
- Métricas custom del pipeline
- Dashboard personalizado

### 5.3 Alarmas
- Errores en logs
- Disponibilidad de pods
- Uso de CPU/memoria

## 6. Pipeline CI/CD

```
┌─────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Checkout                                           │
│  2. Build (Docker)                                     │
│  3. Test (JUnit + JaCoCo)                              │
│  4. Security Scan (Snyk + Trivy)                       │
│  5. Quality Check (SonarQube + PMD)                    │
│  6. Compliance Check                                   │
│  7. Push to ECR                                        │
│  8. Deploy to EKS                                      │
│  9. Publish Metrics                                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```
