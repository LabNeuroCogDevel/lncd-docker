all:
	docker build -t robex     -f Dockerfile.robex .
	docker build -t afni-core -f Dockerfile.afni-core .
	docker build -t fsl       -f Dockerfile.fsl .
	docker build -t "preproc:devel" --build-arg GHTOKEN="`cat github.token`:@" .
