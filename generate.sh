#!/bin/bash
lake exe documentationMriscx
cp -r _out/html-multi/* docs
rm -r _out/
python3 -m http.server 8000 -d docs
