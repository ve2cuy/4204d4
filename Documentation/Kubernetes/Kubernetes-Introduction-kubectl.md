# Introduction aux commandes de base de `kubectl`
<p align="center">
    <img src="../images/k8s-nginx.png" alt="" width="550" />
</p>

## Créer un pod à partir de nginx

```
kubectl run nginx-pod --image=nginx:latest --port=80

# État du pod
kubectl get pod nginx-pod

# Détails complets
kubectl describe pod nginx-pod

# Port-forward pour tester localement
kubectl port-forward pod/nginx-pod 8080:80

# ATTENTION -> Dans un autre terminal
curl http://localhost:8080

# Effacer le pod
kubectl delete pod/nginx-pod

# Créer un pod interactif

kubectl run test -it --image=busybox
kubectl attach test -c test -i -t
```

---

## Déployer 4 nginx
```
kubectl create deployment nginx-deployment \
  --image=nginx:latest \
  --replicas=4 \
  --port=80

kubectl get pod -o wide
# Tester avec curl
```

## Exposer via une adresse locale commune (ClusterIP)

```
kubectl expose deployment nginx-deployment \
  --name=nginx-service \
  --port=80 \
  --target-port=80  

kubectl get svc -o wide
kubectl describe service/nginx-service
# IP:                       10.98.105.164
# Endpoints:                10.244.0.7:80,10.244.2.5:80,10.244.1.7:80 + 1 more...
# Tester IP avec curl
```

## Effacer le service
```
kubectl delete service/nginx-service
```


## Exposer via une adresse publique (Sous Docker-Desktop = localhost)

```
kubectl expose deployment nginx-deployment \
  --name=nginx-service \
  --type=LoadBalancer \
  --port=80 \
  --target-port=80
```

---

## M-A-J le nombre de replicas

```
kubectl scale deployment nginx-deployment --replicas=12

# Voir les pods se créer en temps réel
# NOTE: Faire la démo avec deux terminaux
kubectl get pods -l app=nginx-deployment --watch

# Via patch JSON
kubectl patch deployment nginx-deployment \
  -p '{"spec": {"replicas": 6}}'

# Éditer directement le manifest en live
kubectl edit deployment nginx-deployment
# Change replicas: 4 → 12, sauvegarde et ferme
```

---

## Exécuter un shell dans un pod

```
kubectl exec -it nginx-deployment-6d95bc85cf-8qsc7 -- bash
cd /usr/share/nginx/html 
echo "Mon site web" > index.html
curl nginx-service # Il est possible d'utiliser le nom d'un service grace au DNS de K8s
exit

# Tester avec curl sur le POD puis sur le service
curl 10.244.1.14 # Mon site web
curl 10.97.12.45 # Plusieurs fois ...
```

---

## Obtenir le log d'un pod

```
kubectl logs nginx-deployment-6d95bc85cf-8qsc7 
kubectl logs nginx-deployment-6d95bc85cf-8qsc7 -f  // En continu
```

---

## Utilisation d'un conteneur d'initialisation

* nginx avec une page personnalisée

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  initContainers:
    - name: init-html
      image: alpine:latest
      command:
        - sh
        - -c
        - "apk add --no-cache git && git clone https://github.com/ve2cuy/superminou-depart /usr/share/nginx/html"
      volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html

  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
      volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html

  volumes:
    - name: html
      emptyDir: {}
```

NOTE: La dépendance est native dans Kubernetes — c'est le comportement par défaut des init containers :

Comportement garanti par Kubernetes
initContainers → s'exécutent en séquence, un par un
                ↓ seulement si exitCode = 0
containers     → démarrent uniquement quand TOUS les init containers sont terminés avec succès

Donc :

Nginx ne démarrera jamais si init-html échoue ou plante.

Si `init-html` plante, Kubernetes le redémarre jusqu'à ce qu'il réussisse
Nginx attend obligatoirement que le fichier soit écrit avant de démarrer.

* Vérifier la séquence en temps réel
  
```bash
kubectl get pod nginx-pod --watch

NAME        READY   STATUS           RESTARTS
nginx-pod   0/1     Init:0/1         0          # init container en cours
nginx-pod   0/1     PodInitializing  0          # init terminé, nginx démarre
nginx-pod   1/1     Running          0          # nginx prêt
```

