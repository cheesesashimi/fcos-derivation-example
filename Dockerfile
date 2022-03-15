ARG RHCOS_BASE_IMAGE=registry.ci.openshift.org/rhcos-devel/rhel-coreos:latest

# Build a small Go program
FROM registry.ci.openshift.org/ocp/builder:rhel-8-golang-1.17-openshift-4.10 AS builder
WORKDIR /build
ENV GOFLAGS=""
COPY . .
RUN go build hello-world.go

FROM $RHCOS_BASE_IMAGE
# Inject our binary into the OS
COPY --from=builder /build/hello-world /usr/bin
# And add our unit file
ADD hello-world.service /etc/systemd/system/hello-world.service
# Also add irssi (my go-to example of strace is already in RHCOS)
ADD RPM-GPG-KEY-centosofficial /etc/pki/rpm-gpg/
ADD centos.repo /etc/yum.repos.d
RUN rpm-ostree install irssi && rm -rf /var/cache 
