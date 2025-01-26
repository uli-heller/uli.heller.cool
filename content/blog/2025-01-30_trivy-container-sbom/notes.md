sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount /home/uli/bin/trivy rootfs "/var/snap/lxd/common/lxd/containers/build-2404/rootfs/" --format spdx-json --output trivy-spdx-container-sbom.json
sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount /home/uli/bin/trivy rootfs "/var/snap/lxd/common/lxd/containers/build-2404/rootfs/" --format cyclonedx --output /home/uli/trivy-cdx-container-sbom.json

trivy image --input build/jib-image.tar

----

java-example-jib

./gradlew jibBuildTar
# -> build/jib-image.tar 107M

trivy image --input build/jib-image.tar \
 --format cyclonedx --output /home/uli/trivy-cdx-jib-sbom.json

trivy image --input build/jib-image.tar \
 --format spdx-json --output /home/uli/trivy-spdx-jib-sbom.json

sudo nsenter --target "$(cat /var/snap/lxd/common/lxd.pid)" --mount /home/uli/bin/trivy rootfs "/var/snap/lxd/common/lxd/containers/build-2404/rootfs/"
