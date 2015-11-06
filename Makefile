.PHONY: default
default:

.PHONY: clean
clean:
	true;

docs:
	$(MAKE) -C repo/doc html
