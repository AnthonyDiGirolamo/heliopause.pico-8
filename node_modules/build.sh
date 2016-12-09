#!/bin/bash
cd minified
../node_modules/luamin/bin/luamin -f ../heliopause.lua > heliopause.lua
cat pico8-header heliopause.lua pico8-footer > heliopause.p8
