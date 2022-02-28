lua_modules: .lua_tree clean-modules
	./scripts/luarocket modules

.lua_tree:
	./scripts/luarocket tree

clean-modules:
	rm -fr lua_modules

.PHONY: clean-modules
