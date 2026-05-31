.PHONY: test test-kms test-s3 test-integration up down

up:
	docker compose up -d

down:
	docker compose down

test-kms:
	cd modules/kms && terraform test

test-s3:
	cd modules/s3-baseline && terraform test

test-integration:
	cd tests && terraform test

test: test-kms test-s3 test-integration
	@echo "✅ All test suites passed."