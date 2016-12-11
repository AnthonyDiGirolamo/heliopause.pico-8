#!/bin/bash
awk '/__lua__/{flag=1;next}/__gfx__/{flag=0}flag' heliopause.p8 > heliopause.lua
sed -i "s/\([a-z_\.][a-z_\.]*\) \([-+\/*]\)=/\1 = \1 \2/g" heliopause.lua
cd minified
../node_modules/luamin/bin/luamin -f ../heliopause.lua > heliopause.lua
sed -i "s/\([a-z_\.][a-z_\.]*\)=\1\([-+\/*]\)\([^ ;][^ ;]*\)/\n\1\2=\3\n/g" heliopause.lua
sed -i 's/;\s*/\n/g' heliopause.lua
sed -i 's/\(\S\)else/\1 else/g' heliopause.lua
sed -i '/^$/d' heliopause.lua
cat pico8-header heliopause.lua pico8-footer > heliopause.p8
