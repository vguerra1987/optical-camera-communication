import multiprocessing
import MultispectralCamera
import time

# First of all we create the pipe
parent_pipe, child_pipe = multiprocessing.Pipe()

# And then we start the process
process = multiprocessing.Process(target=MultispectralCamera.camera_loop, args=(parent_pipe, ))
process.start()

while True:
    data = child_pipe.recv()
    print(data)

