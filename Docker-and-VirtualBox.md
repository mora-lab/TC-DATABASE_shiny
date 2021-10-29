# Docker for TC-DATABASE

This Docker version published at https://hub.docker.com/r/moralab/copd-shiny.

## Usage
Using the command to run this image:

```shell
sudo docker run -d \
     --publish=7474:7474 --publish=7687:7687 \
     --publish=3838:3838 \
     --publish=8787:8787 \
    --name copd-shiny \
    moralab/copd-shiny
```

After you run it, you can check:
- The **time-course database**:  [http://localhost:7474](http://localhost:7474) with account `neo4j` with password `neo4j`.
- The **COPD-shiny**: [http://localhost:3838](http://localhost:3838).
- The **RStudio-server**: [http://localhost:8787](http://localhost:8787) with account `rstudio` with password `rstudio`.

# VirtualBox for TC-DATABASE

This virtualBox based on Ubuntu 20.04 locates at https://zenodo.org/deposit/5606999.

The user and password for administrator of this virtualBox are:   
User: `moralab`    
Password: `moralab`    

After you start this VirtualBox, you can directly open the Firefox browser to visit TC-DATABASE_shiny .

- The time-course database: http://localhost:7474 with account `neo4j` with password `neo4j`.
- The COPD-shiny: http://localhost:3838/copd_shiny/.



