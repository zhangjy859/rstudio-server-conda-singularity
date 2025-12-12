## rstudio-server-conda-singularity
Run rstudio-server in conda environment with singularity installed

## Acknowledgements
I adopted script from @grst's project `rstudio-server-conda` (https://github.com/grst/rstudio-server-conda)

This script use @rocker's rstudio  singularity img (https://github.com/rocker-org/rocker)

## install
### install singularity
#### with root privilege
`https://docs.sylabs.io/guides/3.0/user-guide/installation.html`
#### without root privilege
`https://docs.sylabs.io/guides/3.5/admin-guide/installation.html#install-nonsetuid`

also see: `https://blog.csdn.net/lazysnake666/article/details/122834329` (Chinese)

#### bulidin script
- install dependency
  ```
  # ubuntu
  sudo apt install wget curl gcc g++ make
  ## use conda instead if you dont have root privilege
  ```
- run `install_singularity.sh`
```
### add executable permission if necessary
./install_singularity.sh <tmp_dir> <install_path> [use_mirror]
# check install ok
$ singularity
Usage:
  singularity [global options...] <command>

Available Commands:
  build       Build a Singularity image
  cache       Manage the local cache
  capability  Manage Linux capabilities for users and groups
  completion  generate the autocompletion script for the specified shell
  config      Manage various singularity configuration (root user only)
  delete      Deletes requested image from the library
  exec        Run a command within a container
  inspect     Show metadata for an image
  instance    Manage containers running as services
  key         Manage OpenPGP keys
  oci         Manage OCI containers
  overlay     Manage an EXT3 writable overlay image
  plugin      Manage Singularity plugins
  pull        Pull an image from a URI
  push        Upload image to the provided URI
  remote      Manage singularity remote endpoints, keyservers and OCI/Docker registry credentials
  run         Run the user-defined default command within a container
  run-help    Show the user-defined help for an image
  search      Search a Container Library for images
  shell       Run a shell within a container
  sif         siftool is a program for Singularity Image Format (SIF) file manipulation
  sign        Attach digital signature(s) to an image
  test        Run the user-defined tests within a container
  verify      Verify cryptographic signatures attached to an image
  version     Show the version for Singularity
```
Note: If the executable file of go cannot be downloaded in the region or network you are in, you can try set `use_mirror` to true

### run this script

1) clone this project and cd to project directory

2) activate conda environment you want
`conda activate env_name`

3) run script
```
WORKDIRECTORY="/path/to/your/rproject/workdir/" PORT=8787 PASSWORD=PASSWORD ./run_singularity.sh #change the port number if your port is already occupied (for example, another rstudio server is running)
```

Your `r project` directory will mount on '/data' in rstudio server

4) visit `http://your_server_ip:8787`

Note: if your server is under a firewall, I recommend using SSH port forwarding.

eg: 

```
# keep this ssh connect running throughout the entire session
ssh user_name@your_server_ip -L 8787:127.0.0.1:8787
```

visit http://127.0.0.1:8787


### Troubleshooting
1. Network error/libcurl error
    You can try downloading the sif file [here](https://mega.nz/file/GNcmVQzB#0bYDqIvQBLvl5-Hl1Q-Ae52DIM0e1C-bMGRqhl-UlAs) to the project folder, rename it to rstudioserver-docker.sif (this image is based on @rocker's image and has been modified), and then try to run it again
