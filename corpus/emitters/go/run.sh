# go test coverprofiles in each mode, plus the GOCOVERDIR binary format and its text conversion.
source /corpus/emitters/lib.sh
tool go go version

fresh go
step bash -c '../gen-big.sh go > classify/big_gen.go'
for mode in set count atomic; do
  step go test -covermode=$mode -coverprofile=$mode.out ./...
  keep go-coverprofile $mode.out coverprofile/$mode.out
done
step go test -covermode=count -coverpkg=./... -coverprofile=coverpkg.out ./...
keep go-coverprofile coverpkg.out coverprofile/count-coverpkg-all.out
note "go test ./... profiles include packages with no tests (util, util/internal) at zero; the covdata from one test binary lists only packages that binary links, so it omits util/internal"

# Integration-test style coverage: a covered binary writes GOCOVERDIR data, converted by go tool covdata.
mkdir -p covdata
step go test -covermode=count -coverpkg=./... ./classify -args -test.gocoverdir=$PWD/covdata
keep go-covdata covdata covdata
step go tool covdata textfmt -i=covdata -o covdata-textfmt.out
keep go-coverprofile covdata-textfmt.out coverprofile/covdata-textfmt.out
step bash -c 'go tool covdata func -i=covdata > covdata-func.txt'
keep go-covdata-func covdata-func.txt covdata/func.txt
