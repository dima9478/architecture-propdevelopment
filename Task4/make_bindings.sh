#!/bin/bash
set -e

USER_IB="ib-user"
USER_DEVOPS="devops-user"
NAMESPACE=default

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${USER_IB}-bind-secret-reader
subjects:
- kind: User
  name: $USER_IB
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${USER_DEVOPS}-bind-product-devops
  namespace: $NAMESPACE
subjects:
- kind: User
  name: $USER_DEVOPS
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: product-devops
  apiGroup: rbac.authorization.k8s.io
EOF

