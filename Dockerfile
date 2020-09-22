FROM ubuntu:16.04 

LABEL Author="Hao WANG" 
LABEL Email="<wang-hao@shu.edu.cn>"
LABEL version="1.0"
LABEL description="A dockerize ubuntu for pytorch with GPU support."
ARG PYTHON_VERSION=3.8

# apt更新为国内阿里源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get clean



# 开放端口
EXPOSE 22 8080 80 8009 8005 8443
 
#安装ssh服务
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:1234' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
RUN mkdir /root/.ssh
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
CMD ["/usr/sbin/sshd", "-D"]
