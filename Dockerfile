FROM minio/minio:RELEASE.2021-01-16T02-19-44Z

RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/bin/mc && chmod a+x /usr/bin/mc

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]