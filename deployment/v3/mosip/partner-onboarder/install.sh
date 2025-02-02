#!/bin/sh
# Onboards default partners 
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=onboarder
CHART_VERSION=12.0.1

echo Create $NS namespace
kubectl create ns $NS

echo Istio label
kubectl label ns $NS istio-injection=enabled --overwrite
helm repo update

echo Copy configmaps
./copy_cm.sh

API_URL=https://$(kubectl get cm global -o jsonpath={.data.mosip-api-internal-host})
HOST=$(kubectl get cm global -o jsonpath={.data.mosip-onboarder-host})
CERT_MANAGER_PASSWORD=$(kubectl get secret --namespace keycloak keycloak-client-secrets -o jsonpath="{.data.mosip_deployment_client_secret}" | base64 --decode)

echo Onboarding default partners
helm -n $NS install partner-onboarder  mosip/partner-onboarder --set onboarding.apiUrl=$API_URL --set onboarding.certManagerPassword=$CERT_MANAGER_PASSWORD --set istio.hosts[0]=$HOST --version $CHART_VERSION

echo Review reports at https://$HOST
