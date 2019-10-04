#!/bin/bash
# Setup Jenkins Project
if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/redhat-gpte-devopsautomation/advdev_homework_template.git na311.openshift.opentlc.com"
    exit 1
fi

GUID="$1"
REPO="$2"
CLUSTER="$3"
SONAR_URL='http://sonarqube.gpte-hw-cicd.svc:9000'
NEXUS_RELEASE_URL='http://nexus3.gpte-hw-cicd.svc:8081/repository/releases'
DOCKER_NEXUS_URL='docker://nexus-registry.gpte-hw-cicd.svc.cluster.local:5000'
LABEL_APP='app=homework'
echo "Setting up Jenkins in project ${GUID}-jenkins from Git Repo ${REPO} for Cluster ${CLUSTER}"

# Cleanup old resources
#oc delete all -l ${LABEL_APP}
#oc delete sa -l ${LABEL_APP}
#oc delete rolebindings -l ${LABEL_APP}

# Set up Jenkins with sufficient resources
# for persistent  -p VOLUME_CAPACITY=1Gi \
oc new-app --template jenkins-ephemeral \
   -p ENABLE_OAUTH=false \
   -p MEMORY_LIMIT=3Gi \
   -p DISABLE_ADMINISTRATIVE_MONITORS=true \
   -n ${GUID}-jenkins \
   -l ${LABEL_APP}

# Create custom agent container image with skopeo
oc new-build  -D $'FROM docker.io/openshift/jenkins-agent-maven-35-centos7:v3.11\n\
     USER root\n\
     RUN yum -y install skopeo \
     && yum clean all\n\
     USER 1001' \
     --name=jenkins-agent-appdev \
     -n ${GUID}-jenkins \
     -l role=jenkins-slave \
     -l ${LABEL_APP}

# Create pipeline build config pointing to the ${REPO} with contextDir `openshift-tasks`
oc new-build ${REPO} \
   --name tasks-pipeline \
   --strategy pipeline \
   --context-dir openshift-tasks \
   --env REPO=${REPO} \
   --env GUID=${GUID} \
   --env CLUSTER=${CLUSTER} \
   --env NEXUS_RELEASE_URL=${NEXUS_RELEASE_URL} \
   --env SONAR_URL=${SONAR_URL} \
   --env DOCKER_NEXUS_URL=${DOCKER_NEXUS_URL} \
   -n ${GUID}-jenkins \
   -l ${LABEL_APP}

# Make sure that Jenkins is fully up and running before proceeding!
while : ; do
  echo "Checking if Jenkins is Ready..."
  AVAILABLE_REPLICAS=$(oc get dc jenkins -n ${GUID}-jenkins -o=jsonpath='{.status.availableReplicas}')
  if [[ "$AVAILABLE_REPLICAS" == "1" ]]; then
    echo "...Yes. Jenkins is ready."
    break
  fi
  echo "...no. Sleeping 10 seconds."
  sleep 10
done
