Act as a Staff Engineer responsible for system onboarding.

Generate file:
21-system-map.md

Build a complete system knowledge map.

For every component:

1. Component name
2. Responsibility
3. Upstream dependencies
4. Downstream dependencies
5. Database interactions
6. APIs consumed
7. APIs exposed
8. Events published
9. Events consumed

Create:

# System Map

## Layer Map

Presentation Layer
Business Layer
Persistence Layer
Infrastructure Layer

## Service Dependency Graph

Show:

Service A
  -> Service B
  -> Service C

## Data Flow Graph

Show:

User Request
   ↓
API
   ↓
Service
   ↓
Repository
   ↓
Database

## Event Flow Graph

Show all event producers and consumers.

## Integration Map

Show:

- Internal integrations
- External integrations
- Third-party services

Identify:

- Single points of failure
- High-coupling areas
- Critical path components

Generate a learning path:

Start Here
→ Then Learn
→ Then Learn
→ Expert Level