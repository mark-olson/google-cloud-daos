#!/bin/bash

CONTAINER_NAME="us-central1-docker.pkg.dev/cloud-daos-perf-testing/docker-registry/daos-centos"

USER_DATA_FILE="cloud-init"
MACHINE_TYPE="n2-custom-36-262144"
SERVICE_ACCT=""

HOSTLIST=(
  "daos-server-test-0001"
  "daos-server-test-0002"
  "daos-server-test-0003"
  "daos-server-test-0004"
)

# odd number, 1, 3, 5
ACCESS_POINTS=(
  "daos-server-test-0001"
  "daos-server-test-0002"
  "daos-server-test-0003"
)

function fmtArray
{
  arr=("$@")
  t=$(printf "'%s'," "${arr[@]}")
  echo ${t%,}
}

HOSTLIST_STR=$(fmtArray "${HOSTLIST[@]}")
ACCESS_POINTS_STR=$(fmtArray "${ACCESS_POINTS[@]}")

for NAME in "${HOSTLIST[@]}"; do
  gcloud compute instances delete "${NAME}" \
    --quiet \
    --zone=us-central1-f \
    --project=cloud-daos-perf-testing &
done

wait 

for NAME in "${HOSTLIST[@]}"; do
  gcloud compute instances create "${NAME}" \
    --project=cloud-daos-perf-testing \
    --zone=us-central1-f \
    --machine-type="${MACHINE_TYPE}" \
    --network-interface=network-tier=PREMIUM,subnet=default,nic-type=VIRTIO_NET \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="${SERVICE_ACCT}" \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --create-disk=auto-delete=yes,boot=yes,device-name=daos-cos,image=projects/cos-cloud/global/images/cos-101-17162-40-5,mode=rw,size=100,type=projects/cloud-daos-perf-testing/zones/us-central1-f/diskTypes/pd-balanced \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --metadata "^;^access-points=${ACCESS_POINTS_STR};hostlist=${HOSTLIST_STR};container-name=${CONTAINER_NAME}" \
    --metadata-from-file "user-data=${USER_DATA_FILE}" &
done

wait
