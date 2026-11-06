# Workflow diagrams — {{TICKET}}

> Presentation: [presentation.html](presentation.html)

<!-- Each diagram must answer one specific question. A diagram that answers no question
     only makes the document longer. Drop any section you do not need. -->

---

## 1. Architecture & scope of change
<!-- Question: who calls whom, and where do we change things? Colour the changed parts, and use another colour
     for parts in another team's repo (that is the critical path). -->

```mermaid
flowchart TB
```

---

## 2. State machine
<!-- Question: which states does an object go through, and which state does this ticket add? -->

```mermaid
stateDiagram-v2
```

---

## 3. Sequence — main scenario
<!-- Question: the real call order, with real data (timestamp, error code, amount). -->

```mermaid
sequenceDiagram
    autonumber
```

---

## 4. Decision tree
<!-- Question: the full branching logic, including the error branches. The fail-open/fail-closed branch
     must appear: it is often forgotten during implementation. -->

```mermaid
flowchart TD
```

---

## 5. Release flow
<!-- Question: in which order is the feature switched on, and at which step is the rollback? -->

```mermaid
flowchart LR
```

---

## 6. PR dependency map

```mermaid
flowchart LR
```

---

## 7. Epic context
<!-- Question: where does this ticket sit in the epic, what does it depend on, what does it affect? -->

```mermaid
flowchart TB
```
