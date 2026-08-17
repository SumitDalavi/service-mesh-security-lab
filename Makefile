.PHONY: install demo

install:
	cd src/api-gateway && npm install
	cd src/auth-service && npm install
	cd src/payment-service && npm install

demo:
	./scripts/demo.sh
