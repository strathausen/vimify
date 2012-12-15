.PHONY: test
test:
	node_modules/.bin/mocha -R spec -t 7s \
	  --compilers coffee:coffee-script \
	  tests/*.coffee

compile:
	coffee -j index.js -cb src/*
