#!/bin/zsh
for file in "~/rolante/master/seeds/"*
    do
        energyplus -x -c $file
    done
