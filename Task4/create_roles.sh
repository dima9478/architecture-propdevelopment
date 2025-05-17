#!/bin/bash
set -e

PRODUCT_NAMESPACE=default

echo "Создание ClusterRole: secret-reader"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
EOF

echo "Создание ClusterRole: cluster-reader"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-reader
rules:
- apiGroups: ["", "apps", "networking.k8s.io"]
  resources: ["pods", "deployments", "services", "ingresses", "nodes"]
  verbs: ["get", "list", "watch"]
EOF

echo "Создание ClusterRole: cluster-operator"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-operator
rules:
- apiGroups: ["", "apps", "networking.k8s.io", "autoscaling"]
  resources: ["deployments", "services", "ingresses", "configmaps", "horizontalpodautoscalers"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
EOF

echo "Создание Role: product-devops"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: product-devops
  namespace: $PRODUCT_NAMESPACE
rules:
- apiGroups: ["", "apps", "batch", "networking.k8s.io"]
  resources: ["pods", "deployments", "services", "jobs", "configmaps", "ingresses"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
EOF

echo "Создание Role: product-observer"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: product-observer
  namespace: $PRODUCT_NAMESPACE
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
EOF
