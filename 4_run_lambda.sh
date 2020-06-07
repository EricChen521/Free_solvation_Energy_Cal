#!bin/bash

cd dual_decouple

for i in [0,1]*
do
	cd $i
	pmemd.cuda -AllowSmallBox -i ht.in -c ti.rst7 -ref ti.rst7 -p ti.prmtop -O -o ht.out -inf ht.info -e ht.en -r ht.rst7 -x ht.nc -l ht.log 
	pmemd.cuda -AllowSmallBox -i eq.in -c ht.rst7 -ref ht.rst7 -p ti.prmtop -O -o eq.out -inf eq.info -e eq.en -r eq.rst7 -x eq.nc -l eq.log
	pmemd.cuda -AllowSmallBox -i ti.in -c eq.rst7 -ref eq.rst7 -p ti.prmtop -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log
	cd ..
done
cd ..


