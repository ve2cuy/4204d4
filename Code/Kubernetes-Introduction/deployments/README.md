# Liste des commandes du document: Kubernetes - Introduction
## Deuxième section: Les déploiements
- kubectl create deployment serveur-web --image=nginx
- kubectl get deployment
- kubectl get pod
- kubectl get replicaset 
- kubectl exec -it serveur-web-54bf66d477-8ctwr -- bash
- kubectl expose deployment serveur-web --port=80
- kubectl get svc -owide
- curl 10.111.198.207
- kubectl scale deploy serveur-web --replicas=5
- kubectl get pods -owide
- export KUBE_EDITOR="nano"
- kubectl edit deployment serveur-web
- - Remplacer la ligne : - image: nginx par, - image: nginx:1.18-alpine-perl

- kuberctl get pod  
- kubectl get replicaset 
- kubectl logs serveur-web-54bf66d477-8ctwr
- kubectl describe pod serveur-web-54bf66d477-8ctwr
- kubectl delete deployment serveur-web
- kubectl jet all
- kubectl apply -f uneAlpine.yml
- kubectl get pod
- kubectl logs meta-une-alpine
- Kubectl delete -f uneAlpine.yml
- kubectl apply -f alpine-v2.yml
- kubectl get pod
- kubectl get pods alpine-v2 -o json > resultat.json
- kubectl get pods pod-name -o jsonpath='{.spec.containers[*].name}'
- kubectl get pods -o jsonpath="{.items[*].spec.containers[*].name}"
- kubectl get pods -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' |\
sort
- kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' |\
sort
- kubectl exec -it alpine-v2 --container conteneur-alpine01 -- /bin/sh
- Kubectl delete -f alpine-v2
- kubectl apply -f demo-pod-init.yml
- kubectl get pod
- curl 10.244.0.12
- kubectl apply -f mem-info.yml
- kubectl apply -f init-via-git.yml
- kubectl apply -f 3.1-deploiement-nginx.yml
- kubectl apply -f 3.2-service-nginx.yml
- kubectl describe service nginx-service
- kubectl get pod -o wide
- kubectl apply -f 3.7-service-nginx-LB.yml
- kubectl get service
- kubectl apply -f 3.10-nginx-dep+service.yml
- kubectl get all
