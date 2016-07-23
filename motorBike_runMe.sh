#!/usr/bin/env bash
decomposePar
mpirun -np 16 -ppn 8 --host $1 -wdir $2/share/OpenFOAM/foamModelFiles simpleFoam -parallel

reconstructPar -latestTime
foamToVTK -latestTime
mv VTK/* ../TOKEEP/
# ----------------------------------------------------------------- end-of-file
echo $WM_PROJECT_DIR

. $WM_PROJECT_DIR/bin/tools/RunFunctions

# copy motorbike surface from resources directory
cp $FOAM_TUTORIALS/resources/geometry/motorBike.obj.gz constant/triSurface/
surfaceFeatureExtract

blockMesh
decomposePar
mpirun -np 16 -ppn 8 --host $1 -wdir $2/share/OpenFOAM/foamModelFiles snappyHexMesh -parallel -overwrite

#- For non-parallel running
#cp -r 0.org 0 > /dev/null 2>&1

#- For parallel running
ls -d processor* | xargs -I {} rm -rf ./{}/0
ls -d processor* | xargs -I {} cp -r 0.org ./{}/0

runParallel patchSummary 6
runParallel potentialFoam 6
runParallel $(getApplication) 6

runApplication reconstructParMesh -constant
runApplication reconstructPar -latestTime

# ----------------------------------------------------------------- end-of-file

