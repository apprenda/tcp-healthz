# tcp-healthz

[![Build Status](https://snap-ci.com/ulSrRsof30gMr7eaXZ_eufLs7XQtmS6Lw4eYwkmATn4/build_image)](https://snap-ci.com/apprenda/tcp-healthz/branch/master)

Expose a liveness or readiness probe for off-cluster services that expose TCP endpoints.

## How it works
The tcp-healthz container leverages the exechealthz server maintained by the Kubernetes community. This server exposes a `/healthz` endpoint that is driven by the successful execution of a given command.

The tcp-healthz container's entrypoint is still `exechealthz`. Using arguments, we tell `exechealthz` to run the `tcp-healthz` binary with the relevant ports.

In the case that all TCP endpoints are up and accessible, `tcp-healthz` will exit with a zero status. This results in successful responses to incoming `/healthz` requests.

In the case that a TCP endpoint is deemed unaccessible, `tcp-healthz` will exit with a failure status. This results in non-successful responses to incoming `/healthz` requests.

See the `examples` directory for usage examples.
