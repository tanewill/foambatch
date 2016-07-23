#!/usr/bin/env bash
decomposePar
mpirun -np 16 -ppn 8 --host $1 -wdir $2/share/OpenFOAM/foamModelFiles simpleFoam -parallel

reconstructPar -latestTime
foamToVTK -latestTime
mv VTK/* ../TOKEEP/
# ----------------------------------------------------------------- end-of-file
