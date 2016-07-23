#!/usr/bin/env bash

decomposePar
#simpleFoam
mpirun -np 16 -ppn 8 --host $1 simpleFoam -parallel
foamToVTK -latestTime
mv VTK/*.vtk ../TOKEEP/
