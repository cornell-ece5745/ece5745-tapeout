cd ./parameter_generator/fixed_parameters
python convert_fixed.py $1 1 $2
python convert_fixed.py $1 0 $2
cd ../../
python fixed_float_model_compare.py $1 $2
python merger.py $1 $2
rm temp.dat