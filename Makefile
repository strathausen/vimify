test:
	node_modules/.bin/mocha -R spec \
	  --compilers coffee:coffee-script \
	  tests/*

compile:
	coffee -j index.js -cb src/*
