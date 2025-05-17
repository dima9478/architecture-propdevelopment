#!/bin/bash
set -e


mkdir -p configs

USER_IB=ib-user
USER_DEVOPS=devops-user

generate_csr() {
  USERNAME=$1

  echo "Генерация ключа и CSR для $USERNAME"

  openssl genrsa -out configs/${USERNAME}.key 2048
  openssl req -new -key configs/${USERNAME}.key -out configs/${USERNAME}.csr -subj "/CN=${USERNAME}"
  CSR_BASE64=$(cat configs/${USERNAME}.csr | base64 | tr -d '\n')

  cat <<EOF > configs/${USERNAME}-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${USERNAME}-csr
spec:
  groups:
  - system:authenticated
  request: ${CSR_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 2592000
  usages:
  - client auth
EOF
  kubectl apply -f configs/${USERNAME}-csr.yaml
}

generate_csr $USER_IB
generate_csr $USER_DEVOPS

kubectl certificate approve ${USER_IB}-csr
kubectl certificate approve ${USER_DEVOPS}-csr

for USER in $USER_IB $USER_DEVOPS; do
  kubectl get csr ${USER}-csr -o jsonpath='{.status.certificate}' | base64 --decode > configs/${USER}.crt
  echo "Подписанный сертификат сохранён в ${USER}.crt"
done


# Uncomment for updating kubeconfig
#kubectl config set-credentials $USER_IB \
#  --client-certificate=configs/${USER_IB}.crt \
#  --client-key=configs/${USER_IB}.key \
#  --embed-certs=true
#
#kubectl config set-context ${USER_IB}-context \
#  --cluster=minikube \
#  --user=$USER_IB \
#  --namespace=default
#
#kubectl config set-credentials $USER_DEVOPS \
#  --client-certificate=configs/${USER_DEVOPS}.crt \
#  --client-key=configs/${USER_DEVOPS}.key \
#  --embed-certs=true
#
#kubectl config set-context ${USER_DEVOPS}-context \
#  --cluster=minikube \
#  --user=$USER_DEVOPS \
#  --namespace=default