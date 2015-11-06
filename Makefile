.PHONY: default
default:
	./setup_gadgetron.sh
	./update_gadgetron.sh

.PHONY: clean
clean:
	true;


docs:
	$(MAKE) -C repo/doc html
