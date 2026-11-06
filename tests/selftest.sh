#!/usr/bin/env bash
# Runs every tests/test-*.sh plus the core-governance guard tests; non-zero exit if any fails.
# Agent evals (plugins/ngvu-factory/evals) need a model and run separately: tools/run-evals.sh.
cd "$(dirname "$0")" || exit 1
rc=0
for t in test-*.sh; do bash "$t" || rc=1; done
bash ../plugins/core-governance/tests/run-guard-tests.sh || rc=1
if ls ./*.mjs >/dev/null 2>&1; then node --test ./*.mjs || rc=1; fi
if [ -f test_serve.py ]; then python test_serve.py || rc=1; fi
if [ $rc -eq 0 ]; then echo "selftest: ALL PASSED"; else echo "selftest: FAILURES"; fi
exit $rc
