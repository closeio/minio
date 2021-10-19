#!/bin/bash

set -e

# First start minio provisionally, check if the bucket exists
# and optionally create it with right policy
bash /usr/bin/docker-entrypoint.sh server /data > /tmp/provisional.txt 2>&1 &
MINIO_PID=$!

while ! timeout 1 bash -c "echo > /dev/tcp/localhost/9000" &>/dev/null; do
    sleep 1
    if ! kill -0 $MINIO_PID > /dev/null 2>&1
    then
        >&2 echo "MinIO failed to start:"
        >&2 cat /tmp/provisional.txt
        exit 1
    fi
done

mc config host add minio http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD &>/dev/null
if [[ -z "`mc ls minio | grep $MINIO_BUCKET_NAME`" ]]; then
    mc mb "minio/$MINIO_BUCKET_NAME"
    mc policy set public "minio/$MINIO_BUCKET_NAME"
else
    echo "Bucket minio/$MINIO_BUCKET_NAME exists"
fi

kill -TERM $MINIO_PID

# Now exec the actual Docker entrypoint once fully initialized
exec bash /usr/bin/docker-entrypoint.sh server /data