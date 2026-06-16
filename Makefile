.PHONY: test test-kms test-s3 test-integration test-cloudtrail test-config test-vpc test-organizations up down clean-demo
up:
	docker compose up -d

down:
	docker compose down

clean-demo:
	-cd environments/demo && terraform destroy -auto-approve

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

test-integration: clean-demo
	cd tests && terraform init -backend=false && terraform test

test: test-kms test-s3 test-cloudtrail test-config test-vpc test-organizations test-integration
	@echo "✅ All test suites passed."