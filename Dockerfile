FROM centos:latest

MAINTAINER alexandrandreenko

RUN yum install epel-release -y \
    && yum update -y \
    && yum install python3-pip -y \
    && pip3 install pyTelegramBotAPI \
    && mkdir /www

COPY main.py /www/main.py
COPY r.py /www/r.py

CMD ["python3", "/www/main.py"]
