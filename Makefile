TUIST ?= tuist
SCHEME ?= RoutineApp Local
DESTINATION ?= generic/platform=iOS Simulator

.PHONY: init gen build test secrets secrets-history

init: gen

gen:
	$(TUIST) generate --no-open

build: gen
	@set -o pipefail; xcodebuild build -workspace Routine.xcworkspace -scheme "$(SCHEME)" -destination "$(DESTINATION)" CODE_SIGNING_ALLOWED=NO 2>&1 | xcbeautify

test:
	@test -n "$(SIMULATOR_UDID)" || (echo "Set SIMULATOR_UDID to your owned booted simulator"; exit 1)
	@set -o pipefail; xcodebuild test -workspace Routine.xcworkspace -scheme "$(SCHEME)" -destination "platform=iOS Simulator,id=$(SIMULATOR_UDID)" CODE_SIGNING_ALLOWED=NO 2>&1 | xcbeautify

secrets:
	python3 .github/scripts/scan-secrets.py

secrets-history:
	python3 .github/scripts/scan-secrets.py --history

SHELL := /bin/bash
