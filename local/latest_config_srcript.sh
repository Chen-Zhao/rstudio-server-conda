## configure env

# config env
export CONDA_ROOT_PRE=/home/chenzhao/project/narcolepsy_CHINA/conda
export conda_env_name=narcolepsy_china
cd $CONDA_ROOT_PRE
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
bash Miniconda3-py39_4.12.0-Linux-x86_64.sh -b -p ${CONDA_ROOT_PRE}/miniconda3


tmux -S ${conda_env_name}
source miniconda3/bin/activate

vi narcolepsy_china.yml
name: narcolepsy_china
channels:
  - conda-forge
dependencies:
  - mamba
  - r-base=4.1.2
  - r-nloptr=2.0.1
  - r-gmp=0.6_5
  - r-pbkrtest=0.5.1
  - r-car=3.0_13
  - r-meta=5.2_0
  - r-devtools=2.4.3
  - python=3.9.12=h9a8a25e_1_cpython
  - r-reticulate=1.25=r41h7525677_1
  - r-BiocManager=1.30.18=r41hc72bb7e_0


conda env create -f narcolepsy_china.yml
conda activate narcolepsy_china

## speed up R

vi $CONDA_PREFIX/lib/R/etc/Renviron
MAKE=${MAKE-'make -j 8'}

# check .libPaths()
# R_LIBS_USER=${R_LIBS_USER-'~/R/x86_64-conda-linux-gnu-library/4.1'}

# system libR
# cp /home/chenzhao/project/kaggle/msci/conda/miniconda3/envs/kaggle_msci/lib/R/lib/libR.so /home/chenzhao/project/kaggle/msci/conda/miniconda3/envs/kaggle_msci/lib/

# rstudio server
git clone https://github.com/Chen-Zhao/rstudio-server-conda.git
cd ./rstudio-server-conda/local
chmod 755 *.sh

wget https://download2.rstudio.org/server/centos7/x86_64/rstudio-server-rhel-2022.07.1-554-x86_64.rpm
rpm2cpio rstudio-server-rhel-2022.07.1-554-x86_64.rpm | cpio -idmv 


export CONDA_ROOT=$CONDA_PREFIX_1
export CONDA_ENV=narcolepsy_china
export RSTUDIO_SERVER_ROOT=/home/chenzhao/project/narcolepsy_CHINA/conda/rstudio-server-conda/local/usr/lib/rstudio-server/
export PATH_TO_RUN_DIR=~/tmp/${CONDA_ENV}
export PATH_TO_CONFIG_DIR=/home/chenzhao/project/narcolepsy_CHINA/conda/rstudio-server-conda/
mkdir -p ~/tmp/${CONDA_ENV}

sed -i -e '36i export XDG_STATE_HOME='${PATH_TO_RUN_DIR}'/.local/state' start_rstudio_server.sh
sed -i -e '36i export XDG_DATA_HOME='${PATH_TO_RUN_DIR}'/.local/share' start_rstudio_server.sh

sed -i -e '/conda activate/d' rsession.sh
sed -i -e '17i export XDG_STATE_HOME='${PATH_TO_RUN_DIR}'/.local/state' rsession.sh
sed -i -e '17i export XDG_DATA_HOME='${PATH_TO_RUN_DIR}'/.local/share' rsession.sh
sed -i -e '17i source '$CONDA_ROOT'/bin/activate '$CONDA_ENV rsession.sh
sed -i -e '17i #activate conda' rsession.sh
sed -i -e '17i RSTUDIO_SERVER_ROOT='$RSTUDIO_SERVER_ROOT rsession.sh
sed -i -e '17i CONDA_PREFIX='$CONDA_PREFIX rsession.sh
sed -i -e '17i CONDA_PREFIX='$CONDA_ROOT rsession.sh
sed -i -e '/www-address/d' rserver.conf

source ~/.rstudioserver/.pwd
RSTUDIO_PASSWORD=${RS_PASSWORD} \
LD_LIBRARY_PATH=${CONDA_PREFIX}/lib/ \
RSTUDIO_RUN_ROOT=$PATH_TO_RUN_DIR/local/run/ \
RSTUDIO_CONFIG_ROOT=$PATH_TO_CONFIG_DIR/local ./start_rstudio_server_v2.sh 8790

## config git 
cd /home/chenzhao/project/narcolepsy_CHINA/narcolepsy_china
touch .Rprofile

ssh -T git@github.com
git clone git@github.com:Chen-Zhao/narcolepsy_china.git
mv narcolepsy_china/.git* ./
mv narcolepsy_china/LICENSE ./
#rm narcolepsy_china -rf
git config remote.origin.url git@github.com:Chen-Zhao/narcolepsy_china.git

## use git@github.com in .git/config
#restart rsession to have git panel

#Rstudio->git panel->shell
#git remote add origin git@github.com:Chen-Zhao/narcolepsy_china.git

git config user.email "zhaochen.tcm@gmail.com"

cat .git/config
git pull git@github.com:Chen-Zhao/narcolepsy_china.git

git push git@github.com:Chen-Zhao/narcolepsy_china.git --force

#Rstudio->git panel->switch remote and branch
#git branch -M master
#git push -u origin master
# use the raw

## shortcut for chrome
# chrome-extension:SHORTKEYS
# add ctrl+shift+c: 
# run script ==> document.execCommand('copy') ==> Activation settings

# theme
wget -O src/tomorrow_night_eighties_HL.rstheme https://github.com/Chen-Zhao/Metabolism_MG_P1/raw/main/source/tomorrow_night_eighties_HL.rstheme

#### start

export CONDA_ROOT=$CONDA_PREFIX_1
export CONDA_ENV=narcolepsy_china
export RSTUDIO_SERVER_ROOT=/home/chenzhao/project/narcolepsy_CHINA/conda/rstudio-server-conda/local/usr/lib/rstudio-server/
export PATH_TO_RUN_DIR=~/tmp/${CONDA_ENV}
export PATH_TO_CONFIG_DIR=/home/chenzhao/project/narcolepsy_CHINA/conda/rstudio-server-conda/
mkdir -p ~/tmp/${CONDA_ENV}

source ~/.rstudioserver/.pwd
RSTUDIO_PASSWORD=${RS_PASSWORD} \
LD_LIBRARY_PATH=${CONDA_PREFIX}/lib/ \
RSTUDIO_RUN_ROOT=$PATH_TO_RUN_DIR/local/run/ \
RSTUDIO_CONFIG_ROOT=$PATH_TO_CONFIG_DIR/local ./start_rstudio_server_v2.sh 8790
