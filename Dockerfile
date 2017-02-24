# base Command Central server image
FROM sagdevops/cce:9.12

ADD . /src
WORKDIR /src

# start tooling, apply template(s), cleanup
RUN /sag/profiles/SPM/bin/startup.sh && /sag/profiles/CCE/bin/startup.sh && \
    sagccant waitcc tuneup masters stopcc -Dcc=docker-build && \
    cd /sag && rm -fr /tmp/* common/conf/nodeId.txt profiles/SPM/logs/* profiles/CCE/logs/*
