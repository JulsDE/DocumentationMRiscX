This a the documentation `MRiscX documentation`. 
To build it, clone the repo and then run
```bash
$ lake update
$ lake exe documentationMriscx
$ python3 -m http.server 8000 -d _out/html-multi

```
or just
```bash
$ bash generate.sh
```

Once this is done, you can read the manual on [http://localhost:8000/](http://localhost:8000/)