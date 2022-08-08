### create cache file

lua -lamalg main.lua

### create single file using cache

lua amalg.lua -o out.lua -s main.lua -c
