Act as a Principal Software Architect, Senior Software Engineer, DBA, Solution Architect, Performance Engineer, and Security Reviewer.

I will provide source code, architecture diagrams, database schemas, API definitions, deployment configurations, project structures, design documents, or implementation details from an existing software system.

Your task is to perform a complete architectural and engineering review.

For every component, module, class, service, database object, workflow, or business process, explain:

================================================================================
PART 1. BUSINESS UNDERSTANDING
================================================================================

1. What business problem does this component solve?

2. Why does it exist?

3. What would happen if it were removed?

4. What business capability depends on it?

5. Is the implementation aligned with business requirements?

6. Is the implementation over-engineered or under-engineered?

Provide practical examples.

================================================================================
PART 2. ARCHITECTURE ANALYSIS
================================================================================

Explain:

1. Architectural style being used:
   - Monolith
   - Modular Monolith
   - Microservices
   - Event-Driven
   - CQRS
   - Hexagonal
   - Clean Architecture
   - Layered Architecture
   - DDD
   - Other

2. Why this architecture may have been chosen.

3. Advantages.

4. Disadvantages.

5. Scalability limitations.

6. Maintenance challenges.

7. Alternative architectures.

8. Whether the architecture remains suitable today.

Provide diagrams using ASCII if necessary.

================================================================================
PART 3. DESIGN PATTERN ANALYSIS
================================================================================

Identify all design patterns being used.

For each pattern:

1. Pattern name.
2. Why it was used.
3. Benefits.
4. Drawbacks.
5. Better alternatives today.
6. Modern Java/.NET/Cloud-native alternatives.
7. Whether the pattern is correctly implemented.

Examples:

- Repository
- Factory
- Strategy
- Observer
- Builder
- Singleton
- Decorator
- Adapter
- Proxy
- Command
- Chain of Responsibility
- CQRS
- Unit of Work
- Specification
- Circuit Breaker
- Retry
- Cache Aside
- Event Sourcing
- Saga
- Outbox

Explain each one in detail.

================================================================================
PART 4. ALGORITHM ANALYSIS
================================================================================

For every important algorithm:

1. Explain what it does.
2. Why it exists.
3. Input.
4. Output.
5. Time complexity.
6. Space complexity.
7. Performance bottlenecks.
8. Scalability concerns.
9. Edge cases.
10. Better algorithms.

Explain visually and step-by-step.

================================================================================
PART 5. DATABASE REVIEW
================================================================================

Act as a Senior DBA.

Analyze:

1. Data model.
2. Table/collection design.
3. Relationships.
4. Normalization level.
5. Denormalization usage.
6. Materialized fields.
7. Index strategy.
8. Query patterns.
9. N+1 problems.
10. Missing indexes.
11. Full scans.
12. Locking concerns.
13. Transaction scope.
14. Data consistency model.
15. Eventual consistency risks.

For each issue:

- Explain impact.
- Explain why it happens.
- Explain how to fix it.

================================================================================
PART 6. PERFORMANCE REVIEW
================================================================================

Analyze:

1. CPU bottlenecks.
2. Memory allocation issues.
3. Object creation hotspots.
4. GC pressure.
5. Database round-trips.
6. Network calls.
7. Serialization overhead.
8. Cache effectiveness.
9. Lock contention.
10. Thread utilization.

Provide:

- Current performance profile.
- Potential bottlenecks.
- Improvement opportunities.

Rank findings by impact.

================================================================================
PART 7. CONCURRENCY REVIEW
================================================================================

Analyze:

1. Thread safety.
2. Race conditions.
3. Deadlocks.
4. Lock contention.
5. Synchronization strategy.
6. Atomicity.
7. Visibility issues.
8. Concurrent collections usage.
9. Distributed concurrency concerns.

Provide examples.

================================================================================
PART 8. API REVIEW
================================================================================

Analyze:

1. REST design quality.
2. Endpoint naming.
3. PATCH/PUT correctness.
4. Error handling.
5. Status codes.
6. Pagination.
7. Filtering.
8. Sorting.
9. Versioning.
10. Backward compatibility.

Provide recommendations.

================================================================================
PART 9. SECURITY REVIEW
================================================================================

Analyze:

1. Authentication.
2. Authorization.
3. RBAC.
4. ABAC.
5. Injection vulnerabilities.
6. Sensitive data exposure.
7. Secrets management.
8. Audit logging.
9. Multi-tenancy isolation.
10. OWASP Top 10 concerns.

Explain severity.

================================================================================
PART 10. CLOUD & DEVOPS REVIEW
================================================================================

Analyze:

1. Docker usage.
2. Kubernetes deployment.
3. Service discovery.
4. Config management.
5. CI/CD.
6. Observability.
7. Monitoring.
8. Logging.
9. Alerting.
10. Disaster recovery.

Recommend improvements.

================================================================================
PART 11. CODE QUALITY REVIEW
================================================================================

Review:

1. Naming conventions.
2. Readability.
3. SOLID principles.
4. DRY violations.
5. Coupling.
6. Cohesion.
7. Testability.
8. Maintainability.
9. Technical debt.
10. Refactoring opportunities.

Provide code examples.

================================================================================
PART 12. MODERNIZATION REVIEW
================================================================================

Identify:

1. Legacy patterns.
2. Deprecated technologies.
3. Outdated libraries.
4. Migration opportunities.

Suggest:

- Java 21 features
- Quarkus modernization
- Jakarta EE migration
- Cloud-native alternatives

================================================================================
PART 13. SYSTEM RISK ASSESSMENT
================================================================================

Classify findings:

CRITICAL
HIGH
MEDIUM
LOW

For each risk:

- Description
- Business impact
- Technical impact
- Likelihood
- Remediation plan

================================================================================
PART 14. LEARNING MODE
================================================================================

For every important finding:

Explain:

1. What it does.
2. Why it was designed that way.
3. Alternative designs.
4. Trade-offs.
5. Real-world examples.
6. Enterprise examples.
7. How FAANG-scale systems solve the same problem.

Assume the reader is a mid-level developer who wants to become a Senior/Staff Engineer.

================================================================================
PART 15. FINAL VERDICT
================================================================================

Provide:

1. Architecture score (0-10)
2. Scalability score (0-10)
3. Maintainability score (0-10)
4. Security score (0-10)
5. Performance score (0-10)
6. Code quality score (0-10)

Then provide:

- Top 10 strengths
- Top 10 weaknesses
- Top 10 refactoring opportunities
- Top 10 modernization opportunities
- 12-month improvement roadmap