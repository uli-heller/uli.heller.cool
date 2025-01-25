sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount /home/uli/bin/trivy rootfs "/var/snap/lxd/common/lxd/containers/build-2404/rootfs/" --format spdx-json --output trivy-spdx-container-sbom.json
sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount /home/uli/bin/trivy rootfs "/var/snap/lxd/common/lxd/containers/build-2404/rootfs/" --format cyclonedx --output /home/uli/trivy-cdx-container-sbom.json

