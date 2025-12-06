**Action 2.5** – ***kubectl create -h***, afficher l’aide de la commande ***create***

```bash
kubectl create -h 
  
Create a resource from a file or from stdin.

 JSON and YAML formats are accepted.

Examples:
  # Create a pod using the data in pod.json.
  kubectl create -f ./pod.json
  
  # Create a pod based on the JSON passed into stdin.
  cat pod.json | kubectl create -f -
  
  # Edit the data in docker-registry.yaml in JSON then create the resource using the edited data.
  kubectl create -f docker-registry.yaml --edit -o json

Available Commands:
  clusterrole... 
  deployment          Create a deployment with the specified name.
  job                 Create a job with the specified name.
...
```

**NOTE:** Avec *Kubernetes*, le **‘pod‘** est la plus petite unité possible d’une application. Ils sont habituellement créés par l’intermédiaire d’un **‘deployment‘**. L’objet ‘*deployment*‘ permet d’assurer la présence constante des **‘pods‘** constituant une application.

**Action 2.5.1a –** Créer un pod

```bash
$ kubectl run ma-alpine --image=alpine

pod/ma-alpine created

kubectl get pod
NAME                        READY   STATUS              RESTARTS   AGE
ma-alpine   0/1             ContainerCreating   0          5s

kubectl get pod
NAME                        READY   STATUS             RESTARTS   AGE
ma-alpine                   0/1     CrashLoopBackOff   1          9s
```

**Note**: Le Pod de type ‘alpine’ n’a rien à exécuter, alors il est terminé puis, redémarré à l’infini (**CrashLoopBackOff**).

Nous allons l’effacer:

```bash
$ kubectl delete pod ma-alpine

pod "ma-alpine" deleted
```

```bash
# Alternative de création pour prévenir le 'CrashLoopBackOff'
$ kubectl run ma-alpine --image=alpine --restart=Never

$ k get pods
NAME        READY   STATUS      RESTARTS   AGE
ma-alpine   0/1     Completed   0          34s
```

**Action 2.5.1b –** Générer un manifeste yaml à partir d’une commande en ligne

```bash
$ kubectl run ma-alpine --image=alpine --restart=Never --dry-run=client -oyaml

# =========================================================================
# Résultat à l'écran:
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: ma-alpine
  name: ma-alpine
spec:
  containers:
  - image: alpine
    name: ma-alpine
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
# =========================================================================

# Sauvegarder le résultat dans un fichier

$ kubectl run ma-alpine --image=alpine --restart=Never --dry-run=client -oyaml > creer-pod-alpine.yaml
```

-----

*(Les actions 2.6 et 2.7 — Créer et afficher le déploiement de base — ne sont pas explicitement numérotées, mais le résultat se voit dans l'action 2.7.1)*

-----

**Action 2.7.1 –** Afficher le pod créé par le déploiement

```bash
kubectl get pod -owide
NAME                           READY   STATUS    RESTARTS   AGE
serveur-web-54bf66d477-4gxtx   1/1     Running   0          3m33s
```

**NOTE:** Entre le déploiement et le pod, il y a une autre couche d’abstraction nommée **‘replicaset‘**.

```bash
kubectl get replicaset 

NAME                     DESIRED   CURRENT   READY   AGE
serveur-web-54bf66d477   1         1         1       8m40s
```

Le ‘***replicaset***‘ permet de gérer les répliques – le nombre d’instances – d’un ***pod***.

**NOTE:** Nous n’avons pas à interagir avec les ‘***replicaset***‘. Nous le ferons avec les déploiements et les pods.

**Action 2.7.2 –** Interagir avec un pod

```bash
 kubectl exec -it serveur-web-54bf66d477-8ctwr -- bash
```

**Action 2.7.3** – Exposer le port du serveur Web via le(s) pod(s)

```bash
$ kubectl expose deployment serveur-web --port=80

$ kubectl get svc -owide
NAME             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE    SELECTOR
kubernetes       ClusterIP      10.96.0.1        <none>        443/TCP        156m   <none>
serveur-web      ClusterIP   -->10.111.198.207   <none>        80/TCP         21m    app=serveur-web

$ curl 10.111.198.207

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

```bash
# Changer le nombre de réplicats:
kubectl scale deploy serveur-web --replicas=5

kubectl get pods -owide
```

-----

### Résumé

Prenons une pause ici pour mettre le tout en contexte. Qu’avons nous fait? Nous avons démarrez un service Web. Au départ il se peut que le service soit peu sollicité.

Avec le temps, si nous sommes chanceux, il sera de plus en plus sollicité. Puis à un certain moment, l’unique instance de notre service ne sera plus en mesure de répondre à la demande, nous devenons de plus en plus populaire.

Avec notre amas **Kubernetes**, il sera facile de dupliquer le service web sur d’autres serveurs.

En bref,

- Un ‘Deployment‘ permet la gestion d’un ‘ReplicatSet‘,
- Un ‘ReplicatSet‘ permet la gestion de tous les duplicatas d’un ‘Pod’,
- Un Pod est une abstraction d’un conteneur.
- Et tout ce qui est sous le déploiement est géré par Kubernetes.

-----

**Action 2.8 –** Mettre à jour le déploiement

*(Cette action n'est pas détaillée explicitement, mais mène à l'Action 2.9)*

**Action 2.9 –** Afficher les pods mis à jour

```bash
NAME                           READY   STATUS    RESTARTS   AGE
serveur-web-6589df7667-vzzq4   1/1     Running   0          101s
```

**NOTE:** Remarquez la modification du nom du **‘pod’**. De plus, suite à la modification, le déploiement a été automatique.

**Action 2.10 –** Déploiement par l'intermédiaire d'un schéma YAML

*(Cette action n'est pas détaillée explicitement, mais mène à l'Action 2.11)*

**Action 2.11 –** Afficher l’historique des duplicatas.

```bash
kubectl get replicaset
NAME                     DESIRED   CURRENT   READY   AGE
serveur-web-54bf66d477   0         0         0       54m
serveur-web-6589df7667   1         1         1       4m56s
```

**NOTE:** Pas de ‘pods’ dans la version précédente: `serveur-web-54bf66d477 0 0 0 54m`

**Action 2.11.2 –** Afficher le log d’un pod

```bash
kubectl logs serveur-web-54bf66d477-8ctwr

---

/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```

**Action 2.11.3 –** Obtenir une liste exhaustive d’information sur un pod

```bash
kubectl describe pod serveur-web-54bf66d477-8ctwr
----
Name:         serveur-web-54bf66d477-8ctwr
Namespace:    default
Priority:     0
Node:         minikube/192.168.99.100
Start Time:   Sat, 20 Mar 2021 17:47:22 -0400
Labels:       app=serveur-web
              pod-template-hash=54bf66d477
Annotations:  <none>
Status:       Running
IP:           172.17.0.2
IPs:
  IP:           172.17.0.2
Controlled By:  ReplicaSet/serveur-web-54bf66d477
Containers:
  nginx:

...
```

**Note:** Il est possible d’appliquer la commande précédente sur d’autres objets. Par exemple, ‘*kubectl describe deployments*‘.

**Labo 2.12 –** Renseigner 3 duplicatas dans le schéma puis, afficher la liste des pods.

**Action 2.13 –** Effacer un Déploiement

```bash
kubectl delete deployment serveur-web

kubectl get deployment
kubectl get replicaset
kubectl get pod
```

-----

La prochaine section est **3 – Renseigner un manifeste de déploiement**.

Avez-vous besoin que je convertisse la section 3 ?