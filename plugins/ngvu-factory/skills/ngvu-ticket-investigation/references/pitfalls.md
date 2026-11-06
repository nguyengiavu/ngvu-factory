# Recurring pitfalls when investigating a ticket

Each item is a wrong conclusion that is easy to draw, with a way to catch it early. Go through the list
before you finalise an analysis, and add the traps your own codebase teaches you.

## P1. The ticket's code is on a branch not yet merged to the main branch

**Wrong conclusion:** "Nobody has built this feature yet" (or "it is fixed").
**Catch it:** search all remote branches and open pull requests for the ticket key; check what is deployed, not what a task folder says.

## P2. A function is shared by two flows

**Wrong conclusion:** "Changing this function only affects the flow in the ticket."
**Catch it:** grep every caller of the function before you edit it; fix once where all callers route through.

## P3. The gate exists only in the UI

**Wrong conclusion:** "The action is restricted."
**Catch it:** call the API directly; check that the server enforces the same rule as the screen.

## P4. The flow only runs on a schedule

**Wrong conclusion:** "The code path is never hit in tests, so it is dead."
**Catch it:** look for scheduled jobs, timers and batch triggers that reach the code, and say when they last ran.
