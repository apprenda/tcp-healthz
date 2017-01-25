FROM gcr.io/google_containers/exechealthz-amd64:1.2

ADD bin/tcp-healthz-linux-amd64 /tcp-healthz-amd64

ENTRYPOINT /exechealthz
