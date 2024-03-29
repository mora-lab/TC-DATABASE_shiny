<img src="https://github.com/mora-lab/mora-lab.github.io/blob/master/picture/MORALAB_Banner.png">

# Docker and VirtualBox implementations of TC-DATABASE

## Docker TC-DATABASE:

> If you need help to install `Docker`, click [here](https://github.com/mora-lab/installing/tree/main/docker)

> 1. This Docker implementation has been published at https://hub.docker.com/r/moralab/copd-shiny

### Usage:
> 2. Use the following commands to run the TC-DATABASE image:

```shell
sudo docker run -d \
     --publish=7474:7474 --publish=7687:7687 \
     --publish=3838:3838 \
     --publish=8787:8787 \
    --name copd-shiny \
    moralab/copd-shiny
```

> 3. After running it, open `Firefox` and you can check:
- The **neo4j time-course database**:  [http://localhost:7474](http://localhost:7474) using the account `neo4j` and password `neo4j`.
- The **COPD shiny app**: [http://localhost:3838](http://localhost:3838).
- The **RStudio-server**: [http://localhost:8787](http://localhost:8787) using the account `rstudio` and password `rstudio`.

## VirtualBox TC-DATABASE:

> If you need help to install `VirtualBox`, click [here](https://github.com/mora-lab/installing/tree/main/virtualbox)

> 4. This VirtualBox implementation is based on `Ubuntu 20.04` and can be downloaded from: https://zenodo.org/record/5606999#.YX-_O57P2Uk.

> 5. The administrator user and password for this VirtualBox are:   
User: `moralab`    
Password: `moralab`    

> 6. After starting this VirtualBox, you can directly open the Firefox browser to visit `TC-DATABASE`.

- The **neo4j time-course database**: http://localhost:7474 using the account `neo4j` and password `neo4j`.
- The **COPD shiny app**: http://localhost:3838/copd_shiny/

*Last updated: Oct.31st, 2021*
