# Documentación: Integración de Herramientas en el Pipeline CI/CD

## 1. Visión General del Pipeline

El pipeline CI/CD del proyecto integra múltiples herramientas de monitoreo, métricas y seguridad para garantizar la calidad, confiabilidad y cumplimiento normativo del software.

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           PIPELINE CI/CD COMPLETO                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │  SOURCE  │───▶│  BUILD   │───▶│  TEST    │───▶│ SECURITY │───▶│ DEPLOY   │ │
│  │  (Git)   │    │ (Docker) │    │ (JUnit)  │    │ (Snyk)   │    │ (EKS)    │ │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│       │               │               │               │               │        │
│       ▼               ▼               ▼               ▼               ▼        │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        OBSERVABILIDAD (CloudWatch)                     │   │
│  │  • Logs (Fluent Bit)  • Métricas (Container Insights)  • Alarmas       │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 2. Herramientas Integradas

### 2.1 Monitoreo y Observabilidad

| Herramienta | Propósito | Integración |
|-------------|-----------|-------------|
| **CloudWatch Logs** | Almacenamiento y consulta de logs | Fluent Bit envía logs automáticamente |
| **Container Insights** | Métricas de CPU, memoria, red, disco | DaemonSet en cada nodo |
| **CloudWatch Alarms** | Alertas automáticas ante anomalías | Configuradas en etapa 7 |
| **CloudWatch Dashboard** | Visualización centralizada de métricas | Dashboard personalizado |

**Cómo se integra:**
1. **Fluent Bit** se despliega como DaemonSet en el namespace `amazon-cloudwatch`
2. Recoge logs de `/var/log/containers/*.log` en cada nodo
3. Envía logs a CloudWatch Logs con metadata de Kubernetes
4. **Container Insights** recolecta métricas cada 60 segundos
5. **Alarmas** monitorean umbrales configurados

### 2.2 Métricas del Pipeline CI/CD

| Métrica | Fuente | Propósito |
|---------|--------|-----------|
| **Tiempo de Despliegue** | Custom/DeployDuration | Medir eficiencia del pipeline |
| **Cobertura de Pruebas** | Custom/TestCoverage | Garantizar calidad de código |
| **Número de Despliegues** | Custom/DeployCount | Seguimiento de actividad |
| **Estado del Despliegue** | Custom/DeploySuccess/Failure | Detectar problemas |

**Cómo se integra:**
1. El script `publicar-metricas.sh` se ejecuta después de cada deploy
2. Publica métricas custom al namespace `Custom` de CloudWatch
3. El dashboard visualiza estas métricas en tiempo real
4. Las alarmas pueden configurarse basadas en estas métricas

### 2.3 Seguridad

| Herramienta | Propósito | Integración |
|-------------|-----------|-------------|
| **Snyk** | Detección de vulnerabilidades en dependencias | Escaneo automático en PR |
| **Trivy** | Escaneo de vulnerabilidades en contenedores | Verificación de imágenes Docker |
| **PMD** | Análisis estático de código | Verificación en build |
| **SonarQube** | Análisis de calidad de código | Quality gate en PR |

**Cómo se integra:**
1. **Snyk** ejecuta `snyk test` en cada PR y push a main
2. **Trivy** escanea imágenes Docker antes del push a ECR
3. **PMD** ejecuta reglas de análisis estático en el build
4. **SonarQube** evalúa la calidad del código y bloquea PRs que no cumplan

### 2.4 Cumplimiento Normativo

| Herramienta | Propósito | Integración |
|-------------|-----------|-------------|
| **Branch Protection** | Proteger rama principal | Configurado en GitHub |
| **Compliance Check** | Validar estándares | Scripts en pipeline |
| **Audit Scripts** | Generar evidencia de auditoría | Ejecución periódica |

**Cómo se integra:**
1. **Branch Protection** requiere PRs y status checks para merge a main
2. **Compliance Check** valida documentación, archivos sensibles, Dockerfile
3. **Audit Scripts** generan reportes de estado del sistema

## 3. Flujo de Datos y Decisiones

### 3.1 Flujo de Monitoreo

```
Microservicios (DB, Backend, Frontend)
        │
        ▼
    Fluent Bit (DaemonSet)
        │
        ▼
    CloudWatch Logs
        │
        ├──▶ Consultas y análisis
        ├──▶ Alertas automáticas
        └──▶ Dashboard en tiempo real
```

### 3.2 Flujo de Métricas

```
Pipeline CI/CD
        │
        ▼
    publicar-metricas.sh
        │
        ▼
    CloudWatch Custom Metrics
        │
        ├──▶ Dashboard de métricas
        ├──▶ Alarmas basadas en umbrales
        └──▶ Análisis de tendencias
```

### 3.3 Flujo de Seguridad

```
Pull Request / Push
        │
        ├──▶ Snyk (dependencias)
        ├──▶ Trivy (contenedores)
        ├──▶ PMD (código)
        └──▶ SonarQube (calidad)
                │
                ▼
        Quality Gate
                │
        ┌───────┴───────┐
        │               │
    PASSED          FAILED
        │               │
        ▼               ▼
    Deploy          Bloqueo
```

## 4. Toma de Decisiones Técnicas

### 4.1 Decisiones Basadas en Métricas

| Métrica | Umbral | Decisión |
|---------|--------|----------|
| CPU > 80% | Crítico | Escalar horizontalmente (HPA) |
| Memoria > 80% | Advertencia | Optimizar uso de recursos |
| Cobertura < 80% | Bloqueante | Agregar más pruebas |
| Tiempo deploy > 5 min | Advertencia | Optimizar pipeline |
| Errores en logs > 10 | Crítico | Investigar y corregir |

### 4.2 Decisiones Basadas en Seguridad

| Hallazgo | Severidad | Acción |
|----------|-----------|--------|
| Vulnerabilidad CRÍTICA | Crítico | Bloquear pipeline, actualizar dependencia |
| Vulnerabilidad ALTA | Advertencia | Planificar actualización |
| Quality gate FAILED | Bloqueante | Corregir issues antes de merge |
| Coverage < 80% | Bloqueante | Agregar pruebas |

### 4.3 Decisiones Basadas en Disponibilidad

| Métrica | Estado | Acción |
|---------|--------|--------|
| Pods Running = 0 | Crítico | Investigar y reiniciar |
| Pods Failed > 0 | Advertencia | Revisar logs y eventos |
| Health check falla | Crítico | Verificar aplicación |

## 5. Mejora Continua

### 5.1 Métricas de Proceso

| Métrica | Objetivo | Seguimiento |
|---------|----------|-------------|
| Tiempo de deploy | < 5 minutos | CloudWatch Dashboard |
| Cobertura de código | > 80% | JaCoCo + SonarQube |
| Vulnerabilidades críticas | 0 | Snyk + Trivy |
| Tasa de éxito de deploys | > 95% | Custom Metrics |

### 5.2 Retroalimentación

1. **Diaria**: Revisar dashboard de CloudWatch
2. **Semanal**: Analizar tendencias de métricas
3. **Mensual**: Evaluar cobertura y calidad
4. **Trimestral**: Revisar políticas de seguridad

### 5.3 Acciones de Mejora

| Área | Acción | Responsable |
|------|--------|-------------|
| Monitoreo | Agregar nuevas métricas | Equipo DevOps |
| Seguridad | Actualizar herramientas | Equipo Seguridad |
| Calidad | Aumentar cobertura | Equipo Desarrollo |
| Cumplimiento | Revisar políticas | Equipo QA |

## 6. Diagrama de Arquitectura Completo

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              AWS CLOUD                                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                           EKS CLUSTER                                    │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────────────────┐  │ │
│  │  │    DB    │  │ Backend  │  │ Frontend │  │   Fluent Bit (Daemon)  │  │ │
│  │  │ (MySQL)  │  │  (API)   │  │  (Web)   │  │                        │  │ │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───────────┬────────────┘  │ │
│  │       │              │              │                    │               │ │
│  │       └──────────────┼──────────────┘                    │               │ │
│  │                      │                                   │               │ │
│  │              ┌───────▼───────┐               ┌──────────▼──────────┐   │ │
│  │              │   Health      │               │   Container         │   │ │
│  │              │   Checks      │               │   Insights          │   │ │
│  │              └───────────────┘               └─────────────────────┘   │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                          │
│                                    ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                        CLOUDWATCH                                        │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │
│  │  │    Logs     │  │  Métricas   │  │   Alarmas   │  │  Dashboard  │    │ │
│  │  │ (Streams)   │  │  (Custom)   │  │  (Alarms)   │  │  (Widgets)  │    │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                        GITHUB ACTIONS                                    │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │ │
│  │  │  Build   │  │  Test    │  │ Security │  │ Quality  │  │  Deploy  │  │ │
│  │  │ (Docker) │  │ (JUnit)  │  │ (Snyk)   │  │(SonarQb) │  │  (EKS)   │  │ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 7. Conclusión

La integración de herramientas de monitoreo, métricas y seguridad en el pipeline CI/CD permite:

1. **Visibilidad completa** del estado del sistema
2. **Detección temprana** de problemas de seguridad y calidad
3. **Automatización** de validaciones críticas
4. **Toma de decisiones informada** basada en datos
5. **Mejora continua** del proceso de desarrollo

Esta integración es fundamental para mantener un sistema confiable, seguro y alineado con estándares de calidad.
