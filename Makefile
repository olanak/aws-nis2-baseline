.PHONY: test test-kms test-s3 test-integration test-cloudtrail test-config test-vpc test-organizations test-scp test-identity-center test-guardduty test-security-hub test-alerting up down clean-dev
up:
	docker compose up -d

down:
	docker compose down

clean-dev:
	-cd environments/dev && terraform destroy -auto-approve

test-kms:
	cd modules/kms && terraform test

test-s3:
	cd modules/s3-baseline && terraform test

test-cloudtrail:
	cd modules/cloudtrail && terraform test

test-config:
	cd modules/aws-config && terraform test

test-vpc:
	cd modules/vpc && terraform test

test-organizations:
	cd modules/organizations && terraform test
test-scp:
	cd modules/scp && terraform test
test-identity-center:
	cd modules/identity-center && terraform test
test-guardduty:
	cd modules/guardduty && terraform test
test-security-hub:
	cd modules/security-hub && terraform test
test-alerting:
	cd modules/alerting && terraform test
test-integration: clean-dev
	cd tests && terraform init -backend=false && terraform test


test: test-kms test-s3 test-cloudtrail test-config test-vpc test-organizations test-scp test-identity-center test-guardduty test-security-hub test-alerting test-integration
	@echo "✅ All test suites passed."