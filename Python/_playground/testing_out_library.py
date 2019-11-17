'''
    Here we will test out the brain module to get something out quick and dirty
    I am following this: http://visbrain.org/brain.html
    they say if we want other brain template we can look here: https://drive.google.com/drive/folders/0B6vtJiCQZUBvd0xfTHJqcHg2bTA

'''

import numpy as np

from visbrain.gui import Brain, Figure
from visbrain.objects import SourceObj, ConnectObj
from visbrain.io import download_file

# Load the xyz coordinates and corresponding subject name :
mat = np.load(download_file('xyz_sample.npz', astype='example_data'))
xyz = mat['xyz']

# An npz is a archive version of npy which is simply a numpy array
num_electrodes = xyz.shape[0]  # Number of electrodes

# Now, create some random data between [-50,50]
data = np.random.uniform(-50, 50, num_electrodes) 
# THIS IS THE NODE DATA (IT CAN BE SOMETHING LIKE ITS AVERAGE GLOBAL CONNECTIVITY)
# This will control the radius of the ball

"""Create the source object :
"""
s_obj = SourceObj('SourceObj1', xyz, data, color='crimson', alpha=.5,
                  edge_width=2., radius_min=0., radius_max=20.)

"""
To connect sources between them, we create a (N, N) array.
This array should be either upper or lower triangular to avoid
redondant connections.
"""
connect = 1000 * np.random.rand(num_electrodes, num_electrodes)
connect[np.tril_indices_from(connect)] = 0  # Set to zero inferior triangle

"""
Because all connections are not necessary interesting, it's possible to select
only certain either using a select array composed with ones and zeros, or by
masking the connection matrix. We are giong to search vealues between umin and
umax to limit the number of connections :
"""
small_weight_threshold = 1
large_weight_threshold = 999

# Here we need two threshold where above large is the big weight
# and small weight we below is the small weights

# 2 - Using masking (True: hide, 1: display):
connect = np.ma.masked_array(connect, mask=True)
# This will show (set to hide = False) only the large and small connection
connect.mask[np.where((connect >= large_weight_threshold) | (connect <= small_weight_threshold))] = False
#print('1 and 2 equivalent :', np.array_equal(select, ~connect.mask + 0))

"""Create the connectivity object :
"""
c_obj = ConnectObj('ConnectObj1', xyz, connect, color_by='strength',
                   cmap='Greys', vmin=small_weight_threshold,
                   vmax=large_weight_threshold, under='blue', over='red',
                   antialias=True)

"""Finally, pass source and connectivity objects to Brain :
"""
vb = Brain(source_obj=s_obj, connect_obj=c_obj)

vb.screenshot('main.png', canvas='main', print_size=(10, 20))

# What is left to do here is to take different shot of the brain to create a figure of the overal connectivity
# through time

#vb.show()

'''
    Bottom line: We can't set the width of our edges to be bigger or smaller
    We can modify the colormap thought.

    we can use a combination of vmin,under, vmax,over and cmap to highlight
    different connection stength

'''