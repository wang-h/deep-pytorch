FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu16.04
MAINTAINER Hao WANG <wang-hao@shu.edu.cn>
ARG PYTHON_VERSION=3.8

# apt更新为国内阿里源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get clean
RUN apt-get update

# 配置sshd
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo '<span style="color:#ff0000;">root:root</span>' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# 开放端口
EXPOSE 22


# 配置环境
RUN apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev && \
     rm -rf /var/lib/apt/lists/*

# 安装conda
RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include ninja cython typing && \
     /opt/conda/bin/conda install -y -c pytorch magma-cuda100 && \
     /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH
# This must be done before pip so that requirements.txt is available
WORKDIR /opt/pytorch
COPY . .
 
WORKDIR /workspace
RUN chmod -R a+w .
EXPOSE 22 
CMD ["/usr/sbin/sshd", "-D"]
