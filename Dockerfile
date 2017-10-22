FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y nodejs npm
RUN update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10

ARG app_path="/opt/app"

RUN mkdir ${app_path}
RUN mkdir ${app_path}/logs/

ADD app.py ${app_path}
ADD recommender.py ${app_path}
ADD views ${app_path}/views
ADD obj ${app_path}/obj

ADD requirements.txt ${app_path}
ADD package.json ${app_path}

RUN pip3 install -r ${app_path}/requirements.txt
RUN npm --prefix ${app_path} install ${app_path}

EXPOSE 8000
CMD ["bash","-c","cd /opt/app/ && python3 app.py"]
