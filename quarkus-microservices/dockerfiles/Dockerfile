FROM amisevsk/che-quarkus-builder:dev as builder
USER 0
RUN yum install -y git

USER 10001
RUN /entrypoint.sh
RUN mkdir /home/user/build
WORKDIR /home/user/build
RUN git clone https://github.com/amisevsk/che-quarkus-demo.git
WORKDIR /home/user/build/che-quarkus-demo
RUN mvn package
RUN mvn package -Pnative

FROM amisevsk/che-quarkus-builder:dev

COPY --from=builder /home/user/.m2 /home/user/.m2
ENV HOME=/home/user
WORKDIR /projects
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["tail", "-f", "/dev/null"]
