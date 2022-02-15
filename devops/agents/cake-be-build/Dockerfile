FROM cakebuild/cake:sdk-6.0-focal-amd64

RUN mkdir /home/agent/ && cd /home/agent/ && chmod o+w /home/agent/ \
    && wget -c https://vstsagentpackage.azureedge.net/agent/2.170.1/vsts-agent-linux-x64-2.170.1.tar.gz && tar zxvf * 

COPY ./start.sh /home/agent/

RUN apt-get update -y
RUN apt-get install -y mono-runtime-common

WORKDIR /home/agent/
ENTRYPOINT ["./start.sh"]
