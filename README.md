# go-benchmarks

```console
# build the images
$ ./make.sh build

# run them
$ ./make.sh

# compare two
$ go get golang.org/x/tools/cmd/benchcmp
$ benchcmp 1.3/clean.log 1.9/clean.log

# create a visualization
$ go get github.com/ajstarks/svgo/benchviz
$ benchcmp 1.3/clean.log 1.9/clean.log | benchviz > go-benchmark-1.3-1.9.svg
```
