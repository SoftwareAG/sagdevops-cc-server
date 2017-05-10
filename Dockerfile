# base Command Central server image
FROM sagdevops/cce:9.12

ADD . /src
WORKDIR /src

# MODIFY THIS to make your env name
ENV CC_ENV=default

# start tooling, apply template(s), cleanup
RUN /sag/profiles/SPM/bin/startup.sh && /sag/profiles/CCE/bin/startup.sh && \
    sagccant waitcc masters licenses stopcc -Denv=$CC_ENV && \
    cd /sag && rm -fr /tmp/* common/conf/nodeId.txt profiles/SPM/logs/* profiles/CCE/logs/*
