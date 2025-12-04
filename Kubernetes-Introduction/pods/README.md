# Liste des commandes du document: Kubernetes - Introduction
## Première section: Les Pods
- kubectl get nodes
- kubectl get pod  
- kubectl get services
- kubectl create -h 
- kubectl run ma-alpine --image=alpine
- kubectl get pod
- kubectl delete pod ma-alpine
- kubectl run ma-alpine --image=alpine --restart=Never
- kubectl run ma-alpine --image=alpine --restart=Never --dry-run=client -oyaml
- kubectl run ma-alpine --image=alpine --restart=Never --dry-run=client -oyaml > creer-pod-alpine.yaml
- kubectl delete pod ma-alpine
- kubectl apply -f creer-pod-alpine.yaml

- kubectl run ma-alpine -it --image=alpine
- kubectl attach ma-alpine -c ma-alpine -i -t