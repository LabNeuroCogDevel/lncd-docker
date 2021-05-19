all:
	docker build -t lncd/afni -f Dockerfile.afni-core .
	docker build -t robex     -f Dockerfile.robex .
	docker build -t fsl       -f Dockerfile.fsl .
	docker build -t convert3d -f Dockerfile.convert3d .
	docker build -t lncd/nimin -f Dockerfile.nimin .
	docker build -t lncd/preproc:min .
	# using afni/afni 20200623
	#docker build -t afni-core -f Dockerfile.afni-core .

quick:
	docker build -t preproc:fmriprep -f Dockerfile.fmriprep

test:
	docker run -v /opt/ni_tools/standard_templates/:/opt/ni_tools/standard_templates/ -it lncd/preproc:min bash -c "cd /opt/ni_tools/fmri_processing_scripts/test/; bats ./;"
