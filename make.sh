#!/bin/bash
set -e
set -o pipefail

REPO_URL="${REPO_URL:-r.j3ss.co}"

run(){
	base=go-benchmark
	suite=$1

	echo "Running ${REPO_URL}/${base}:${suite} benchmark"
	docker run --rm -i ${REPO_URL}/${base}:${suite}  &> "${suite}/benchmark.log" || return 1

	# clean the logs
	cat "${suite}/benchmark.log" | grep "^Benchmark" | sed s/-12//g > "${suite}/clean.log"

	echo "                       ---                                   "
	echo "Successfully ran ${base}:${suite} log lives in ${suite}/benchmark.log"
	echo "                       ---                                   "
}

build(){
	base=go-benchmark
	suite=$1
	build_dir=$2

	echo "Building ${REPO_URL}/${base}:${suite} for context ${build_dir}"
	docker build --rm --force-rm -t ${REPO_URL}/${base}:${suite} ${build_dir} || return 1

	echo "                       ---                                   "
	echo "Successfully built ${base}:${suite} with context ${build_dir}"
	echo "                       ---                                   "
}

main(){
	arg=$1

	# get the dockerfiles
	IFS=$'\n'
	files=( $(find . -iname '*Dockerfile' | sed 's|./||' | sort) )
	unset IFS

	ERRORS=()
	# build all dockerfiles
	for f in "${files[@]}"; do
		image=${f%Dockerfile}
		suite=${image%%\/*}
		build_dir=$(dirname $f)

		if [[ "$arg" == "build" ]]; then
			{
				build "${suite}" "${build_dir}"
			} || {
			# add to errors
			errors+=("${suite}")
			}
		else
			{
				run "${suite}"
			} || {
			# add to errors
			errors+=("${suite}")
			}
		fi
	echo
	echo
done

if [ ${#ERRORS[@]} -eq 0 ]; then
	echo "No errors, hooray!"
else
	echo "[ERROR] Some images did not build correctly, see below." >&2
	echo "These images failed: ${ERRORS[@]}" >&2
	exit 1
fi
}

main $@
