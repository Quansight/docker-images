## PyTorch Docker Image

This image is made specifically to test/build pytorch and its dependencies on Linux.

I built this image to map a volume to, so that way you can edit on the <host> with text editor settings
and compile within the container. 

#### Steps
1. `docker build -t <name> .`
	* This _will_ take a while to compile.
2. `docker run -v <host-pytorch-dir>:/torch/ --rm --it --cap-add=SYS_PTRACE --security-opt setcomp=unconfined <name>`

I have made a /torch/ dir in the VM where pytorch is installed.

##### WARNING: MAKE SURE TO `rm -rf build` BEFORE BUILDING AGAIN

Build PyTorch like normal on a Linux Machine.  
