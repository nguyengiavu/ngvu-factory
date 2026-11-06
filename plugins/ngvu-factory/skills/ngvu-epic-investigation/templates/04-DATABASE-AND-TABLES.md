# 04 — Database & related tables

<!-- Read from migrations (Flyway `V*.sql`, JPA entities, example_docstore), never query the real DB.
     Every table records the migration file that creates it. If there is none, drop this file and say so in the README. -->

## 1. Central tables / collections

| Column / field | Type | Null? | Index / unique | Who writes | Who reads | Evidence |
|---|---|---|---|---|---|---|

### What does **not** exist (the epic must add it or compensate elsewhere)

## 2. Downstream / related tables

## 3. DB on the other systems' side (producer / consumer)

## 4. Proposed schema changes (per the option in [07](07-OPTIONS-EVALUATION.md))

<!-- Expand/contract, nullable first, index CONCURRENTLY. A change on a hot table → approval item in 10 §5. -->

## 5. Sample queries (read-only) for someone with access to run on DEV

<!-- The AI does not run DB queries; write the command for the user to run. Use a placeholder tenant id. -->
