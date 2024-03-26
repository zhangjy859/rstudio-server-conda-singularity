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

### run this script

1) clone this project and cd to project directory

2) activate conda environment you want
`conda activate env_name`

3) run script
```
WORKDIRECTORY="/path/to/your/rproject/workdir/" PORT=8787 PASSWORD=PASSWORD ./run_singularity.sh #change the port number if your if your port is already occupied (for example, another rstudio server is running)
```

Your project directory will mount on '/data' in rstudio server

4) visit `http://your_server_ip:8787`

Note: if your server is under a firewall, I recommend using SSH port forwarding.

eg: 

```
# keep this ssh connect running throughout the entire session
ssh user_name@your_server_ip -L 8787:127.0.0.1:8787
```

visit http://127.0.0.1:8787

