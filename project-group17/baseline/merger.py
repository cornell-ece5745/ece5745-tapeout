import sys
import argparse

THIRD_LAYBER_SIZE=10
TWO_LAYBER_SIZE=512
FIRST_LAYBER_SIZE=512
IMAGE_SIZE=28
INPUT_SIZE=IMAGE_SIZE*IMAGE_SIZE

NUM_ARGV_EXPECTED = 2
ARG_NAME = ['fracwidth', 'imgnum']
ARG_TYPES = [int, int]
METAVARS = ['fw', 'in']
DESCRIPTIONS = ['width of fraction part in fixed point', 'total number of test images']

if len(ARG_NAME) != NUM_ARGV_EXPECTED:
    print ('ARG_NAME initialization error!');
    sys.exit(1)
if len(ARG_TYPES) != NUM_ARGV_EXPECTED:
    print ('ARG_TYPES initialization error!');
    sys.exit(1)
if len(METAVARS) != NUM_ARGV_EXPECTED:
    print ('METAVARS initialization error!');
    sys.exit(1)
if len(DESCRIPTIONS) != NUM_ARGV_EXPECTED:
    print ('DESCRIPTIONS initialization error!');
    sys.exit(1)

parser=argparse.ArgumentParser(
    description="Description")
for i in range(0,NUM_ARGV_EXPECTED):
    parser.add_argument(ARG_NAME[i], metavar=METAVARS[i], type=ARG_TYPES[i], help=DESCRIPTIONS[i])
args=parser.parse_args()

 
with open('../app/ubmark/parameters.dat','w') as f:
    PATHPARA = './parameter_generator/fixed_parameters/' + str(args.fracwidth)
    x = open(PATHPARA + '/fc3_fixed_bias_1d.dat').read()
    x = 'int fc3_bias [{}]'.format(THIRD_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open(PATHPARA + '/fc3_fixed_weights_1d.dat').read()
    x = 'int fc3_weights [{}][{}]'.format(THIRD_LAYBER_SIZE, TWO_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open(PATHPARA + '/fc2_fixed_bias_1d.dat').read()
    x = 'int fc2_bias [{}]'.format(TWO_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open(PATHPARA + '/fc2_fixed_weights_1d.dat').read()
    x = 'int fc2_weights [{}][{}]'.format(TWO_LAYBER_SIZE, FIRST_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open(PATHPARA + '/fc1_fixed_bias_1d.dat').read()
    x = 'int fc1_bias [{}]'.format(FIRST_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open(PATHPARA + '/fc1_fixed_weights_1d.dat').read()
    x = 'int fc1_weights [{}][{}]'.format(FIRST_LAYBER_SIZE, INPUT_SIZE) + ' = {' +x+'};\n'
    f.write(x)

    for i in range(args.imgnum):
        PATHPARA = './parameter_generator/fixed_parameters/' + str(args.fracwidth)
        FILENAME = '/test_img' + str(i) + '_1d.dat'
        x = open(PATHPARA+FILENAME).read()
        x = 'int input_{} [{}]'.format(i, INPUT_SIZE) + ' = {' +x+'};\n'
        f.write(x)
f.close()