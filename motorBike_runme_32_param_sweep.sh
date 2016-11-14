#!/usr/bin/env bash +x
echo $WM_PROJECT_DIR

. $WM_PROJECT_DIR/bin/tools/RunFunctions

# copy motorbike surface from resources directory
#cp $FOAM_TUTORIALS/resources/geometry/motorBike.obj.gz constant/triSurface/
wget https://raw.githubusercontent.com/tanewill/OpenFOAM_motorBike/master/system/surfaceFeatureExtractDict -O $2/share/OpenFOAM/foamModelFiles/system/surfaceFeatureExtractDict
surfaceFeatureExtract
blockMesh
wget https://raw.githubusercontent.com/tanewill/OpenFOAM_motorBike/master/system/snappyHexMeshDict -O $2/share/OpenFOAM/foamModelFiles/system/snappyHexMeshDict
cp system/decomposeParDict.meshing system/decomposeParDict
decomposePar
mpirun -np 8 -wdir $2/share/OpenFOAM/foamModelFiles snappyHexMesh -parallel -overwrite
reconstructParMesh -noZero -mergeTol 1e-07 -constant
cp system/decomposeParDict.solving system/decomposeParDict
rm -rf processor*
decomposePar

#update speed 0.
sed "s/flowVelocity         (20 0 0);/flowVelocity         ($3 0 0);/g" 0.org/include/initialConditions

#- For parallel running
ls -d processor* | xargs -I {} rm -rf ./{}/0
ls -d processor* | xargs -I {} cp -r 0.org ./{}/0

mpirun -np 32 -ppn 8 --host $1 -wdir $2/share/OpenFOAM/foamModelFiles patchSummary -parallel
mpirun -np 32 -ppn 8 --host $1 -wdir $2/share/OpenFOAM/foamModelFiles potentialFoam -parallel
mpirun -np 32 -ppn 8 --host $1 -wdir $2/share/OpenFOAM/foamModelFiles simpleFoam -parallel

reconstructParMesh -constant
reconstructPar -latestTime
foamToVTK -latestTime
mv VTK/* ../TOKEEP/
# ----------------------------------------------------------------- end-of-file
