# Kubernetes – Manifestes
 6 Décembre 2025

-----

**Action 2.8 –** Mettre à jour le déploiement

Lors de Action 2.7 (du document précédent) K8s a généré un manifeste de déploiement.  Plus tard, nous verrons comment renseigner nos propres manifestes.  Ce schéma contient des informations tel que, le nombre de duplicatas requis, la version des images, les ports exposés, …

Le fichier est constitué de trois sections:

Les Méta données (metadata:)
Les spécifications (spec:)
Ainsi que l’état du système (status:)



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

 
### 3 – Renseigner un manifeste Kubernetes en format Yaml


### 3.0 – Manifeste d’un Pod


**Action 3.0.1 –** Manifeste d’un Pod, renseigner le fichier uneAlpine.yml

```yaml
# ------------------------------------------------------------
# Fichier: uneAlpine.yml
# Exemple d'un manifeste pour un Pod avec des variables d'env.
# k apply -f uneAlpine.yml
# k logs meta-une-alpine
# ------------------------------------------------------------
apiVersion: v1
kind: Pod
# Section 1 - Les Méta-données
metadata:
  name: meta-une-alpine
# Section 2 - Les spécifications
spec:
  containers:
  - name: ma-alpine
    image: alpine
    command: ["/bin/sh", "-c",  "env"]
    env:
    - name: ENV01
      value: YoDouloudou
    - name: ENV02
      value: Coucou  
  restartPolicy: Never
````

**Note:** Remarquer le type du manifeste \*\*– \*\* **kind: Pod.** 

**Action 3.0.2 –** Déployer le système:

```bash
$ kubectl apply -f uneAlpine.yml
pod/meta-une-alpine created
```

```bash
kubectl get pod
NAME                           READY   STATUS      RESTARTS   AGE
meta-une-alpine                0/1     Completed   0          92s
```

**Note:** Remarquer le ‘STATUS: Completed‘

**Action 3.0.3 –** Afficher les logs du déploiement précédent:

```bash
$ kubectl logs meta-une-alpine
KUBERNETES_PORT=tcp://10.96.0.1:443
NGINX_SERVICE_SERVICE_PORT=80
ENV01=YoDouloudou
ENV02=Coucou
```

**Action 3.0.3.1 –** Faire un test avec le bloc suivant:

```yaml
kind: Pod
# Section 1 - Les Méta-données
metadata:
  # Placer 'name' en commentaire et appliquer le manifeste
  #name: meta-une-alpine
```

Résultat?

**Action 3.0.3.2 –** Effacer le résultat d’un manifeste:

```bash
Kubectl delete -f nomDuManifeste.yml
```

**Action 3.0.4 –** Manifeste d’un Pod avec deux conteneurs, fichier alpine-v2.yml:

```yaml
# ---------------------------------------------------------
# Fichier: alpine-v2.yml
# Auteur:  Alain Boudreault
# Exemple d'un manifeste avec deux conteneurs dans un Pod
# ---------------------------------------------------------
# Lister les conteneurs d'un Pod
# $ k get pods alpine-v2 -o json > resultat.json
# $ k describe po alpine-v2
 
apiVersion: v1
kind: Pod
metadata:
  name: alpine-v2
  # namespace: default
spec:
  containers:
  - image: alpine
    name: conteneur-alpine01
    stdin: true
    tty: true
#  restartPolicy: Always
  - image: alpine
    # Fournir une tâche à exécuter pour le conteneur
    # Sinon, il va s'arrêter.
    command: [ "/bin/sh", "-c", "while true; do sleep 5; done;" ]
    imagePullPolicy: IfNotPresent
    name: conteneur-alpine02
  restartPolicy: Always
```

Afficher le résultat:

```bash
$ kubectl get pod
NAME                           READY   STATUS      RESTARTS   AGE
alpine-v2                      2/2     Running     0          7m30s
```

**Action 3.0.5 –** Obtenir les détails du pod précédent:

```bash
kubectl get pods alpine-v2 -o json > resultat.json

====

Voici un extrait du fichier résultat.json:

    "spec": {
        "containers": [
            {
                "image": "alpine",
                "imagePullPolicy": "Always",
                "name": "conteneur-alpine01",
                "resources": {},
                "stdin": true,
                "terminationMessagePath": "/dev/termination-log",
                "terminationMessagePolicy": "File",
                "tty": true,
                "volumeMounts": [
                    {
                        "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                        "name": "default-token-z4rpp",
                        "readOnly": true
                    }
                ]
            },
            {
                "command": [
                    "/bin/sh",
                    "-c",
                    "while true; do sleep 5; done;"
                ],
                "image": "alpine",
                "imagePullPolicy": "IfNotPresent",
                "name": "conteneur-alpine02",
                "resources": {},
                "terminationMessagePath": "/dev/termination-log",
                "terminationMessagePolicy": "File",
                "volumeMounts": [
                    {
                        "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                        "name": "default-token-z4rpp",
                        "readOnly": true
                    }
                ]
            }
        ],
```

**Action 3.0.5.1 –** Extraire des information du résultat json, par exemple, la liste des conteneurs:

```bash
# 1 - Liste des conteneurs pour un Pod:
kubectl get pods pod-name -o jsonpath='{.spec.containers[*].name}'

# 2 - Liste des conteneurs de tous les Pods:
kubectl get pods -o jsonpath="{.items[*].spec.containers[*].name}"

# 3 - Liste des conteneurs par Pod de l'espace de nom par défaut - pretty:
kubectl get pods -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' |\
sort

# 4 - Liste des conteneurs par Pod de tous les espaces de nom:
kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}' |\
sort
```

Référence: [kubernetes](https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/)

**Action 3.0.6 –** Exécuter une commande dans un conteneur lorsque le Pod en possède plusieurs:

```bash
$ kubectl exec -it alpine-v2 --container conteneur-alpine01 -- /bin/sh
```

\*\*Note:  \*\*Les deux conteneurs utilisent l’adresse IP du Pod.

-----

**3.0.7a** – Utilisation d’un conteneur d’initialisation

```yaml
# ---------------------------------------------------------
# Fichier: demo-pod-init.yml
# Auteur:  Alain Boudreault
# Exemple d'un 'initContainer' qui copie un contenu externe
# vers le dossier racine du serveur nginx.
# ---------------------------------------------------------
# demo-pod-init.yml
apiVersion: v1
kind: Pod
metadata:
  name: pod-demo
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  initContainers:
  - name: demo-init
    image: busybox
    command: ['sh', '-c', 'wget -O /usr/share/data/index.html [http://google.com](http://google.com)']
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/data
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
```

```bash
$ka demo-pod-init.yml$ kgp
NAME        READY   STATUS            RESTARTS   AGE
pod-demo    0/1     PodInitializing   0          5s

$ kgp -owide
NAME        READY   STATUS    RESTARTS   AGE    IP            NODE        NOMINATED NODE
pod-demo    1/1     Running   0          2m7s   10.244.0.12   k8smaster   <none>

$ curl 10.244.0.12
```

```bash
Action: Tester dans un fureteur sur le serveur
```

\<img src="../images/Capture-decran-2025-12-04-124211.png" alt="" width="" /\>

-----

**3.0.7b** – Utilisation d’un autre conteneur d’initialisation

```yaml
# ---------------------------------------------------------
# Fichier: mem-info.yml
# Auteur:  Alain Boudreault
# Exemple d'un 'initContainer' qui envoie le contenu 
# de /proc/meminfo vers le dossier racine du serveur nginx
# ---------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: plusieurs-pods
spec:

  volumes:
  - name: dossier-de-partage
    emptyDir: {}

  initContainers:
  - name: meminfo
    image: alpine
    restartPolicy: Always
    command: ['sh', '-c', 'sleep 5; while true; do cat /proc/meminfo > /usr/share/data/index.html; sleep 10; done;']
    volumeMounts:
    - name: dossier-de-partage
      mountPath: /usr/share/data
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: dossier-de-partage
      mountPath: /usr/share/nginx/html
```

**3.0.7c** – Utilisation d’un autre conteneur d’initialisation

```yaml
# ---------------------------------------------------------
# Fichier: init-via-git.yml
# Auteur:  Alain Boudreault
# Exemple d'un 'initContainer' qui clone le contenu 
# d'un dépôt vers le dossier racine du serveur nginx
# ---------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: nginx-super-init
spec:
  volumes:
  - name: www
  containers:
  - name: nginx-superminou
    image: nginx
    volumeMounts:
    - name: www
      mountPath: /usr/share/nginx/html/

  initContainers:
  - name: git
    image: alpine
    # Installation de git dans le conteneur, suivi d'un git clone vers le dossier de partage
    command: [ "sh", "-c", "apk add --no-cache git && git clone [https://github.com/ve2cuy/superMinou](https://github.com/ve2cuy/superMinou) /www" ]
    volumeMounts:
    - name: www
      mountPath: /www/
```

-----

### 3.1 – Manifeste d’un déploiement

**Action 3.1 –** Manifeste d’un déploiement, renseigner le fichier ‘*3.1-d\*\*eploiement-nginx.yml*‘ suivant:

```yaml
# ---------------------------------------------------------
# Fichier: 3.1-deploiement-nginx.yml
# Auteur:  Alain Boudreault
# Déploiement de deux pods nginx version 1.16
# ---------------------------------------------------------
apiVersion: apps/v1
kind: Deployment
# Section 1 - Les Méta-données
metadata:
  name: nginx-deployment
  labels:
    app: nginx
# Section 2 - Les spécifications
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.16
        ports:
        - containerPort: 80
# Section 3 - État du déploiement - sera complétée par K8s
```

**Note:** Remarquer \*\*– \*\* **kind: Deployment**

**Action 3.2 –** Renseigner le fichier ‘*3.2-service-nginx.yml*‘ suivant:

```yaml
# -------------------------------------------------------------------------------------
# Fichier: 3.2-service-nginx.yml
# Auteur:  Alain Boudreault
# Voici comment exposer un service de type Cluster-IP -via un port- au réseau local K8s 
# pour accéder aux pods nginx déployés dans le manifeste 3.1-deploiement-nginx.yml
# Le lien entre le service et les pods est fait via les labels:
#   selector:
#    app: nginx
# fait référence au label app: nginx dans le manifeste 3.1-deploiement-nginx.yml
# -------------------------------------------------------------------------------------
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  # fait référence au label app: nginx dans le manifeste 3.1-deploiement-nginx.yml
  selector:
    app: nginx 
  ports:
    - protocol: TCP
      # Port à exposer au reseau local K8s
      port: 80
      # Port du conteneur - containerPort
      targetPort: 80
```

**Note:** Remarquer \*\*– \*\* **kind: Service**

\*\*Action 3.3 – \*\*Nous allons maintenant appliquer nos deux schémas; le déploiement et le service.

```bash
kubectl apply -f 3.1-deploiement-nginx.yml

deployment.apps/nginx-deployment created

--

kubectl apply -f 3.2-service-nginx.yml

service/nginx-service created

--

kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           62s

kubectl get service               
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP   26d
nginx-service   ClusterIP   10.108.129.91   <none>        80/TCP    82s
```

**Action 3.4 –** Vérifier que le service achemine bien les requêtes http vers les pods de nginx

```bash
kubectl describe service nginx-service

Name:              nginx-service
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=nginx
Type:              ClusterIP
IP:                10.108.129.91
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         172.17.0.2:80,172.17.0.5:80
Session Affinity:  None
Events:            <none>
```

**Note:** Remarquer la ligne ‘Endpoints: *172.17.0.2:80*,*172.17.0.5:80*‘.  Les requêtes seront envoyées vers deux pods sur leur port 80.

**Action 3.5 –** Vérifier l’adresse IP deux deux pods.

```bash
kubectl get pod -o wide

NAME                               READY   STATUS    RESTARTS   AGE   IP           NODE
nginx-deployment-f4b7bbcbc-qt8kd   1/1     Running   0          12m   172.17.0.5   minikube
nginx-deployment-f4b7bbcbc-tcr7l   1/1     Running   0          12m   172.17.0.2   minikube
```

**Action**: Tester dans le fureteur disponible sur le serveur:

\<img src="../images/Capture-decran-2025-12-04-155550.png" alt="" width="" /\>

-----

**Action 3.6 –** Obtenir le schéma complet du Déploiement.  Il est disponible dans le *etcd.*

```bash
kubectl get deployment nginx-deployment -o yaml > nginx-dep-info.yml
```

**Action 3.7 –** Exposer nginx au monde extérieur – *service type: LoadBalancer*.

En rappel, voici la configuration de service-nginx

```bash
nginx-service   **ClusterIP** 10.108.129.91   <none>        80/TCP    26m
```

Voici une version modifiée du fichier *3.2-service-nginx.yml* de l’action 3.2

```yaml
# --------------------------------------------------------------------------------------
# Fichier: 3.7-service-nginx-LB.yml
# Auteur:  Alain Boudreault
# Voici comment exposer un service de type LoadBalancer -via un port- au reseau local K8s 
# pour accéder aux pods nginx déployés dans le manifeste 3.1-deploiement-nginx.yml
# Le lien entre le service et les pods est fait via les labels:
#   selector:
#    app: nginx
# fait référence au label app: nginx dans le manifeste 3.1-deploiement-nginx.yml
# --------------------------------------------------------------------------------------
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  # Ajout 1  
  type: LoadBalancer
  ports:
    - protocol: TCP
      # Port à exposer au reseau local K8s
      port: 80
      # Port du conteneur
      targetPort: 80
      # ajout 2 - port externe.  Doit être entre 30000 et 32767
      nodePort: 30000
```

\*\*Action 3.8 – \*\*Appliquer le schéma modifié

```bash
$ kubectl apply -f 3.7-service-nginx-LB.yml

service/nginx-service configured

---

$ kubectl get service               
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP      10.96.0.1       <none>        443/TCP        26d
nginx-service   LoadBalancer   10.108.129.91   <pending>     80:30000/TCP   60m
```

**Note:**  Remarquer que *nginx-service* est maintenant de type ‘*LoadBalancer*‘.  Remarquer aussi que ‘EXTERNAL-IP‘ est \<pending\> car sous *minikube*, la gestion des adresses externes est légèrement différente.  Nous aurons une étape de plus à réaliser avant que le serveur Web soit disponible via notre poste de travail.

\~\~**Action 3.9 –** Attribuer une adresse IP externe à *nginx-service*.\~\~

```bash
$ minikube service nginx-service

$ minikube service list

**Note**: Sous Docker_Desktop+Kubernetes, le tunnel vers votre machine sera automatique et le service accessible via 'localhost'

|-------------|---------------|--------------|-----------------------------|
|  NAMESPACE  |     NAME      | TARGET PORT  |             URL             |
|-------------|---------------|--------------|-----------------------------|
| default     | kubernetes    | No node port |
| default     | nginx-service |           80 | [http://192.168.59.100:30000](http://192.168.59.100:30000) |
| kube-system | kube-dns      | No node port |
|-------------|---------------|--------------|-----------------------------|

# Note: Selon la version de minikube et/ou du pilote de VM, il est possible
que le fureteur soit lancé automatiquement.
```

**NOTE**:  En classe, (D139) nous avons remarqué que le ‘tunneling’ de services ne fonctionnait pas avec le driver ‘docker’.  Voir:

  * https://minikube.sigs.k8s.io/docs/handbook/accessing/
  * https://stackoverflow.com/questions/40767164/expose-port-in-minikube
  * https://serverfault.com/questions/1052349/unable-to-connect-to-minikube-ingress-via-minikube-ip

**[Action 3.10](https://www.google.com/search?q=%23action-3-10) –** Consolidation des deux schémas.  Renseigner le fichier ‘*3.10-nginx-dep+service.yml*‘

```yaml
# -----------------------------------------------------------
# Fichier: 3.10-nginx-dep+service.yml
# Auteur:  Alain Boudreault
# -----------------------------------------------------------
# Voici la version consolidée de:
#    3.1-deploiement-nginx.yml et
#    3.7-service-nginx-LB.yml
# -----------------------------------------------------------
apiVersion: apps/v1
kind: Deployment
# Section 1 - Les Méta-données
metadata:
  name: nginx-deployment
  # Les 'labels' ici, sont facultatifs.
  labels:
    app: nginx-app
# Section 2 - Les spécifications
spec:
  replicas: 4
  selector:
    matchLabels:
      # Le label app doit correspondre à celui de la ligne 21 
      app: nginx-app-label
  template:
    metadata:
      labels:
      # Le label app doit correspondre à celui de la ligne 16 
        app: nginx-app-label
    spec:
      containers:
      - name: conteneur-nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
      # Le selector app doit correspondre au matchLabel de la ligne 16
      # Note: Il est aussi possible d'utiliser le nom d'un Pod.   
    app: nginx-app-label
  # Ajout 1  
  type: LoadBalancer
  ports:
    - protocol: TCP
      # Port à exposer au réseau local K8s
      port: 80
      # Port du conteneur
      targetPort: 80
      # ajout 2 - port externe.  Doit être entre 30000 et 32767
      nodePort: 30080
```

**Labo 3.11 –** Effacer les déploiements précédents, redéployer à partir du fichier 3.10 et tester le service Web.

**Labo 3.12 –** Remplacer l’image nginx utilisée dans le fichier de labo 3.11 par ‘alainboudreault/phpweb’  et augmenter le nombre de duplicatas à 20.

  * Tester dans deux fureteurs différents.
  * Actualiser la page des fureteurs plusieurs fois.
  * Tester dans un terminal: curl http://192.168.99.100:30080/info.php

-----

## Référence 01 – K8S: Type de ressources

| NOM | NOM COURT | VERSION API | NAMESPACED | KIND |
| :--- | :--- | :--- | :--- | :--- |
| `bindings` |  | v1 | true | Binding |
| `componentstatuses` | `cs` | v1 | false | ComponentStatus |
| `configmaps` | `cm` | v1 | true | ConfigMap |
| `endpoints` | `ep` | v1 | true | Endpoints |
| `events` | `ev` | v1 | true | Event |
| `limitranges` | `limits` | v1 | true | LimitRange |
| `namespaces` | `ns` | v1 | false | Namespace |
| `nodes` | `no` | v1 | false | Node |
| `persistentvolumeclaims` | `pvc` | v1 | true | PersistentVolumeClaim |
| `persistentvolumes` | `pv` | v1 | false | PersistentVolume |
| `pods` | `po` | v1 | true | Pod |
| `podtemplates` |  | v1 | true | PodTemplate |
| `replicationcontrollers` | `rc` | v1 | true | ReplicationController |
| `resourcequotas` | `quota` | v1 | true | ResourceQuota |
| `secrets` |  | v1 | true | Secret |
| `serviceaccounts` | `sa` | v1 | true | ServiceAccount |
| `services` | `svc` | v1 | true | Service |
| `mutatingwebhookconfigurations` |  | admissionregistration.k8s.io/v1 | false | MutatingWebhookConfiguration |
| `validatingwebhookconfigurations` |  | admissionregistration.k8s.io/v1 | false | ValidatingWebhookConfiguration |
| `customresourcedefinitions` | `crd,crds` | apiextensions.k8s.io/v1 | false | CustomResourceDefinition |
| `apiservices` |  | apiregistration.k8s.io/v1 | false | APIService |
| `controllerrevisions` |  | apps/v1 | true | ControllerRevision |
| `daemonsets` | `ds` | apps/v1 | true | DaemonSet |
| `deployments` | `deploy` | apps/v1 | true | Deployment |
| `replicasets` | `rs` | apps/v1 | true | ReplicaSet |
| `statefulsets` | `sts` | apps/v1 | true | StatefulSet |
| `tokenreviews` |  | authentication.k8s.io/v1 | false | TokenReview |
| `localsubjectaccessreviews` |  | authorization.k8s.io/v1 | true | LocalSubjectAccessReview |
| `selfsubjectaccessreviews` |  | authorization.k8s.io/v1 | false | SelfSubjectAccessReview |
| `selfsubjectrulesreviews` |  | authorization.k8s.io/v1 | false | SelfSubjectRulesReview |
| `subjectaccessreviews` |  | authorization.k8s.io/v1 | false | SubjectAccessReview |
| `horizontalpodautoscalers` | `hpa` | autoscaling/v2 | true | HorizontalPodAutoscaler |
| `cronjobs` | `cj` | batch/v1 | true | CronJob |
| `jobs` |  | batch/v1 | true | Job |
| `certificatesigningrequests` | `csr` | certificates.k8s.io/v1 | false | CertificateSigningRequest |
| `leases` |  | coordination.k8s.io/v1 | true | Lease |
| `endpointslices` |  | discovery.k8s.io/v1 | true | EndpointSlice |
| `events` | `ev` | events.k8s.io/v1 | true | Event |
| `flowschemas` |  | flowcontrol.apiserver.k8s.io/v1beta2 | false | FlowSchema |
| `prioritylevelconfigurations` |  | flowcontrol.apiserver.k8s.io/v1beta2 | false | PriorityLevelConfiguration |
| `ingressclasses` |  | networking.k8s.io/v1 | false | IngressClass |
| `ingresses` | `ing` | networking.k8s.io/v1 | true | Ingress |
| `networkpolicies` | `netpol` | networking.k8s.io/v1 | true | NetworkPolicy |
| `runtimeclasses` |  | node.k8s.io/v1 | false | RuntimeClass |
| `poddisruptionbudgets` | `pdb` | policy/v1 | true | PodDisruptionBudget |
| `podsecuritypolicies` | `psp` | policy/v1beta1 | false | PodSecurityPolicy |
| `clusterrolebindings` |  | rbac.authorization.k8s.io/v1 | false | ClusterRoleBinding |
| `clusterroles` |  | rbac.authorization.k8s.io/v1 | false | ClusterRole |
| `rolebindings` |  | rbac.authorization.k8s.io/v1 | true | RoleBinding |
| `roles` |  | rbac.authorization.k8s.io/v1 | true | Role |
| `priorityclasses` | `pc` | scheduling.k8s.io/v1 | false | PriorityClass |
| `csidrivers` |  | storage.k8s.io/v1 | false | CSIDriver |
| `csinodes` |  | storage.k8s.io/v1 | false | CSINode |
| `csistoragecapacities` |  | storage.k8s.io/v1 | true | CSIStorageCapacity |
| `storageclasses` | `sc` | storage.k8s.io/v1 | false | StorageClass |
| `volumeattachments` |  | storage.k8s.io/v1 | false | VolumeAttachment |

```bash
NOTE: Il est possible d'obtenir cette liste à partir du cli de K8S:
$ kubectl api-resources
```

-----

## test

  * [Killercoda Interactive Environments](https://killercoda.com/)
  * [Rancher](https://www.rancher.com/)
  * [K9s](https://k9scli.io/)
  * [Documentation officielle](https://kubernetes.io/fr/docs/home/)

-----

Prochain document [K8s-partie2](https://www.google.com/search?q=http://ve2cuy.com/420-4d4b/index.php/kubernetes-partie-2/)

-----

###### Document rédigé par Alain Boudreault (c) 2021-2025 – version 2025.12.03.1

```
```