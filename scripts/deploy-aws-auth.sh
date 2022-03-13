#!/bin/bash

set -ex

function main() {
  local -r script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
  local -r cluster_name=$1

  aws eks update-kubeconfig --name $cluster_name

  cat <<EOS >${script_dir}/aws-auth-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: arn:aws:iam::171457761414:user/44smkn
      username: 44smkn
      groups:
        - system:masters
EOS

  cat ${script_dir}/aws-auth-cm.yaml
  kubectl apply -f ${script_dir}/aws-auth-cm.yaml
  kubectl describe configmap -n kube-system aws-auth
}

main "$@"
