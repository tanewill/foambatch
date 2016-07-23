#!/usr/bin/env bash
decomposePar
#simpleFoam
mpirun -np 16 -ppn 8 --host $1 simpleFoam -parallel

reconstructPar -latestTime
foamToVTK -latestTime
mv VTK/*.vtk ../TOKEEP/
# ----------------------------------------------------------------- end-of-file
