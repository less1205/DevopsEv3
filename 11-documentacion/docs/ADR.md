# Decisiones Arquitectónicas (ADR)

## ADR-001: Uso de Amazon EKS

**Estado**: Aceptada

**Contexto**: Se necesita una plataforma de orquestación de contenedores que soporte escalado automático, alta disponibilidad y integración con servicios AWS.

**Decisión**: Usar Amazon EKS como plataforma de orquestación.

**Consecuencias**:
- ✅ Integración nativa con servicios AWS
- ✅ Soporte para HPA y auto-healing
- ✅ Gestión administrada del plano de control
- ❌ Costo adicional vs. EC2 self-managed

## ADR-002: CloudWatch como herramienta de observabilidad

**Estado**: Aceptada

**Contexto**: Se necesita una solución de monitoreo que cubra logs, métricas y alarmas, integrada con el ecosistema AWS.

**Decisión**: Usar Amazon CloudWatch con Container Insights y Fluent Bit.

**Consecuencias**:
- ✅ Integración nativa con EKS
- ✅ Solución managed (sin infraestructura adicional)
- ✅ Costo predecible
- ❌ Vendor lock-in con AWS

## ADR-003: Quality Gates en pipeline CI/CD

**Estado**: Aceptada

**Contexto**: Se necesita garantizar que solo código seguro y de calidad llegue a producción.

**Decisión**: Implementar quality gates con Snyk, SonarQube, JaCoCo y scripts de cumplimiento.

**Consecuencias**:
- ✅ Detección temprana de problemas
- ✅ Bloqueo automático de cambios problemáticos
- ✅ Cumplimiento normativo automatizado
- ❌ Tiempo de build aumentado

## ADR-004: Métricas custom del pipeline

**Estado**: Aceptada

**Contexto**: Se necesita medir el rendimiento del proceso CI/CD para identificar áreas de mejora.

**Decisión**: Publicar métricas custom a CloudWatch (DeployDuration, TestCoverage, DeployCount).

**Consecuencias**:
- ✅ Visibilidad del rendimiento del pipeline
- ✅ Posibilidad de configurar alarmas basadas en métricas
- ✅ Mejora continua basada en datos
- ❌ Configuración adicional requerida
