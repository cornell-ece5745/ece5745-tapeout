THIRD_LAYBER_SIZE=10
TWO_LAYBER_SIZE=512
FIRST_LAYBER_SIZE=512
IMAGE_SIZE=28
INPUT_SIZE=IMAGE_SIZE*IMAGE_SIZE

with open('parameters.dat','w') as f:
    x = open('./data/parameters/float64/fc3_fixed_bias_1d.dat').read()
    x = 'int fc3_bias [{}]'.format(THIRD_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open('./data/parameters/float64/fc3_fixed_weights_1d.dat').read()
    x = 'int fc3_weights [{}][{}]'.format(THIRD_LAYBER_SIZE, TWO_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open('./data/parameters/float64/fc2_fixed_bias_1d.dat').read()
    x = 'int fc2_bias [{}]'.format(TWO_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open('./data/parameters/float64/fc2_fixed_weights_1d.dat').read()
    x = 'int fc2_weights [{}][{}]'.format(TWO_LAYBER_SIZE, FIRST_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open('./data/parameters/float64/fc1_fixed_bias_1d.dat').read()
    x = 'int fc1_bias [{}]'.format(FIRST_LAYBER_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open('./data/parameters/float64/fc1_fixed_weights_1d.dat').read()
    x = 'int fc1_weights [{}][{}]'.format(FIRST_LAYBER_SIZE, INPUT_SIZE) + ' = {' +x+'};\n'
    f.write(x)
    x = open('./data/test_images/float32/test_img0_fixed_1d.dat').read()
    x = 'int input [{}]'.format(INPUT_SIZE) + ' = {' +x+'};\n'
    f.write(x)
f.close()