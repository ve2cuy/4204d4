# K8s - Config Map et Secrets

<img src="../images/k8s-configmap.png" alt="" width="550" />

---

Contenu:

3. **[Les 'configmaps'](#item3)**
4. **[Monter un volume à partir d'un configmap](#item4)**
5. **Laboratoire**
   1. **Déployer une application utilisant un configmap comme source d'un dossier**
6. **[Les 'secrets'](#item6)**
7. **[Exemple complet, mosquitto+Node-RED+volume+configMap+secret](#item7)** (**TP02**)

---

## 3 – Les 'configMaps'

configMap – définition:

Les '**configMaps**' offrent un moyen d'implémenter une couche d'abstraction sur les informations, des fichiers manifestes, qui peuvent varier dans le temps. Habituellement utilisés pour les fichiers de configurations des applications.

Par exemple,

* Un nom d'utilisateur, (voir secrets)
* un mot de passe, (voir secrets)
* un lien vers un volume,
* le contenu d'un fichier.
* php.ini, apache.conf, …

Au lieu de coder, en dur, ces informations dans les fichiers manifestes, il est possible de les enregistrer dans une BD locale.

Voici un exemple:

**Action 3.1 –** Renseigner le fichier 'unConfigMap.yml'

```
# ------------------------------------------------------------------------------
# Fichier: unConfigMap.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.03.31-2023.04.04
# ------------------------------------------------------------------------------
# Description:  Exemple d'un configMap K8s
# ------------------------------------------------------------------------------
kind: ConfigMap
apiVersion: v1
metadata:
  name: kekun
data:
  # Voici des variables définies à la pièce:
  nom: Bob
  prenom: Binette

  # Voici des variables définies en bloc:
  unBlocDeClef: |

    age.bloc=33
    email.bloc=binette@brrr.poff
    cell.bloc=123.456.7890
```

Voici comment utiliser ce configMap:

**Action 3.2 –** Renseigner le fichier manisfeste 'busybox.yml'

```
# ------------------------------------------------------------
# Fichier: busybox.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.03.31-2023.04.04
# ------------------------------------------------------------
# Exemple d'un manifeste pour un Pod avec des variables d'env,
# renseignées par un configMap
# https://cloud.google.com/kubernetes-engine/docs/concepts/configmap?hl=fr
# ------------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: meta-busybox
spec:
  containers:
  - name: ma-busybox
    image: busybox
    command: ["/bin/sh", "-c",  "env"]

# Lors des exemples précédents, nous avons renseigné la Var ENV comme suit:
#   env:
#   - name: ENV01
#     value: YoDouloudou
# Remarquez qu'avec un configMap, la syntaxe est un peu différente!
    env:
    # Voici des exemples d'utilisation de variables définies à la pièce:
    - name: NOM
      valueFrom: 
        configMapKeyRef:
          name: kekun  # kekun est le nom de la configMap
          key: nom

    - name: PRENOM
      valueFrom: 
        configMapKeyRef:
          name: kekun
          key: prenom

    # Voici un exemple d'utilisation de variables définies en bloc:
    - name: LEBLOC
      valueFrom: 
        configMapKeyRef:
          name: kekun
          key: unBlocDeClef
```

**Labo 3.2.1 –** Appliquer les deux (2) manifestes et valider la présence des variables d'environnement.

---

### **MySql avec un configmap**

Voici un exemple d'utilisation 'MySQL' de variables individuelles d'environnement, via un 'configMap'

**Action 3.3 –** Renseigner le fichier suivant:

```
# Fichier: mysqlConfigMap.yml
# Projet: 420-4D4-Semaine 09
# Date: 2021.03.31-2023.04.04
# ------------------------------------------------------------------------------
# Description:  Exemple d'un configMap pour un Pod MySQL
# ------------------------------------------------------------------------------
kind: ConfigMap
apiVersion: v1
metadata:
  name: mysql-env
data:
  MYSQL_ROOT_PASSWORD: yo
  MYSQL_DATABASE: wordpress
  MYSQL_USER: wp
  MYSQL_PASSWORD: wp
```

**Action 3.4 –** Renseigner le fichier suivant:

```
# ------------------------------------------------------------
# Fichier: mysql.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.01-2023.04.04
# -------------------------------------------------------------------------
# Exemple d'un manifeste pour un Pod mysql avec des variables d'env,
# renseignées par un configMap
# -------------------------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: meta-mysql
spec:
  containers:
  - name: mysql
    image: mysql
    env:
    - name: MYSQL_ROOT_PASSWORD
      valueFrom: 
        configMapKeyRef:
          name: mysql-env  # mysql-env est le nom de la configMap
          key: MYSQL_ROOT_PASSWORD # MYSQL_ROOT_PASSWORD est le nom de la var dans le configMap

    - name: MYSQL_DATABASE
      valueFrom: 
        configMapKeyRef:
          name: mysql-env
          key: MYSQL_DATABASE

    - name: MYSQL_USER
      valueFrom: 
        configMapKeyRef:
          name: mysql-env
          key: MYSQL_USER

    - name: MYSQL_PASSWORD
      valueFrom: 
        configMapKeyRef:
          name: mysql-env
          key: MYSQL_PASSWORD
```

**Action 3.4.1 –** Appliquer les deux manifestes:

```
Kubectl apply -f mysqlConfigMap.yml

# Attention, l'ordre est important.  
# Le 'configmap' doit exister avant de créer le 'pod'. 

Kubectl apply -f mysql.yml
```

**Validation:**

**Action 3.5 –** Valider la création de la BD 'wordpress'

```
kubectl exec -it meta-mysql -- bash
```

```
mysql> show databases;

+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
```

**Action 3.5.1 –**Valider la création du compte 'wp'

```
mysql> SELECT user,host FROM mysql.user;
+------------------+-----------+
| user             | host      |
+------------------+-----------+
| root             | %         |
| wp               | %         |
| mysql.infoschema | localhost |
| mysql.session    | localhost |
| mysql.sys        | localhost |
| root             | localhost |
+------------------+-----------+
```

**Action 3.5.2 –**Valider les droits du compte 'wp'

```
mysql> show grants for 'wp';
+--------------------------------------------------+
| Grants for wp@%                                  |
+--------------------------------------------------+
| GRANT USAGE ON *.* TO `wp`@`%`                   |
| GRANT ALL PRIVILEGES ON `wordpress`.* TO `wp`@`%`|
+--------------------------------------------------+
```

**NOTE:**

*Un version 'bloc' ne fonctionnera pas ici. Le conteneur 'mysql' s'attend à trouver des variables individuelles. Dans le cas d'une consolidation de**l'insertion de plusieurs variables, il est possible d'utiliser la directive 'envFrom:'.  Voici un exemple;*

### 3.6 – La directive 'envFrom'

La directive '*envFrom*' permet l'importation des toutes les variables d'un '*configMap*'.

**Action 3.6.1 –** Renseigner le fichier suivant:

```
# -----------------------------------------------------------------
# Fichier: mysql-v2.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.01-2023.04.04
# ------------------------------------------------------------------
# Exemple d'un manifeste pour un Pod mysql avec des variables d'env,
# renseignées par un configMap complet, la directive 'envFrom'
# ------------------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: meta-mysql-v2
spec:
  containers:
  - name: mysql-v2
    image: mysql

    # Noter que la directive est 'envFrom:' 
    # et non pas 'env:' 
    envFrom:

      # Noter que la directive est 'configMapRef 
      # et non pas 'configMapKeyRef' 
    - configMapRef:
        name: mysql-env
```

**Action 3.6.2 –** Appliquer le manifeste et vérifier que le SGBD fonctionne selon les directives des variables d'environnement.

```
kubectl apply -f mysql-v2.yml

Kubectl exec -it meta-mysql-v2 -- bash
```

---

<img src="../images/labo03.png" alt="" width="700" />

### Laboratoire 4

Reprendre le **Laboratoire 1** en utilisant la directive **envFrom** pour les variables d'environnement du SGDB et de WordPress.

**Note**:  Il faut utiliser deux 'configMap'.

---

## 4 – **Monter un volume à partir d'un configmap**

<img src="../images/graphic-of-persistent-volume-bond.png" alt="" width="550" />

**Note**: Dans ce module, nous verrons comment présenter des donnés stockées dans un configmap sous forme d'un volume. Les notions plus approfondies sur volumes K8S sont disponibles dans ce [document](https://4204d4.ve2cuy.com/kubernetes-les-volumes/).

---

## Voici l'exemple d'un volume K8S monté localement.

**Note**: Ceci n'est pas une pratique recommandée.

**Action 4.1 –** Créer un dossier et un fichier index.html, pour la liaison avec un pod de type nginx:

```
# 1 - créer un dossier
mkdir web-data

# 2 - Obtenir le chemin absolu du dossier pour référence dans l'étape suivante:
pwd

# Dans mon cas:

  /Users/alain/420-4D4/semaine09/web-data/

# 3 - Dans ce répertoire, créer un fichier 'index.html' avec le contenu suivant:

echo 'Ceci est la page index.html du serveur web.' > web-data/index.html
```

**Action 4.2 –** Renseigner le manifeste suivant:

```
# -------------------------------------------------------------
# Fichier: nginx_volume.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.03-2023.04.04
# -------------------------------------------------------------
# Exemple d'un manifeste pour un Pod nginx avec un volume local
# https://kubernetes.io/fr/docs/concepts/storage/volumes/
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
# -------------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: serveur-web
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: volume-web

# Définition des volumes
  volumes:
  - name: volume-web
    hostPath:
      # chemin du dossier sur l'hôte
      # Il faut renseigner le chemin en utilisant l'adressage absolu.
      # Utiliser le chemin absolu de 4.1
      path: /Users/alain/420-4D4/semaine09/web-data/
      # ce champ est optionnel
      type: Directory
```

**Action 4.3 –** Appliquer le manifeste et tester la liaison de volume:

```
# 1 - appliquer le manifeste
kubectl apply -f nginx+volume.yml

# 2 - Se connecter au shell du pod
kubectl exec -it serveur-web -- bash

# 3 - AU BESOIN, installer 'curl'
apt update
apt install curl

$ 4 - Tester le service web
curl localhost

Résultat -->

  Ceci est la page index.html du serveur web.
```

*L'exemple précédent est l'utilisation la plus simple possible d'un volume.  Kubernetes offre un large éventail de volumes permettant d'assurer le partage et la persistance des données.*

*Nous explorerons plus de possibilités dans un laboratoire à [venir](http://ve2cuy.com/420-4d4b/index.php/kubernetes-les-volumes/).*

Référence Kubernetes sur les [volumes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

---

### NOTE: Volume hostPath Minikube sur Linux

La version **Minikube** de **Linux** n'**expose pas automatiquement** le système de fichiers du host aux Pods.

Il faut monter manuellement  les volumes de la façon suivante:

```
minikube mount /home/alain/420-4d4/web-data:/usr/share/nginx/html
```

Une autre alternative et d'utiliser la directive '***DirectoryOrCreate***'

```
  volumes:
  - name: volume-web
    hostPath:
     path: /420-4d4/web-data/
     type: DirectoryOrCreate
```

Cette directive va créer le dossier à l'intérieur de la VM de Minikube.

En s'y connectant, il sera possible de valider la présence du dossier:

```
$ minikube ssh
                         _             _            
            _         _ ( )           ( )           
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __  
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$ ls /home/alain/420-4d4/web-data
index.html
```

---

### 4.4 – configMap + volume

Dans l'exemple suivant, nous allons renseigner le contenu d'un fichier lié à un pod à partir d'un configMap.

**Action 4.4.1 –** Renseigner le manifeste suivant:

```
# ------------------------------------------------------------------------------
# Fichier: configMapNginx.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.03-2023.04.04
# ------------------------------------------------------------------------------
# Description:  Exemple d'un volume (fichier) à partir d'un configMap
# ------------------------------------------------------------------------------
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-config-map
data:
 # Voici le contenu, défini en bloc:
  contenu: |
    <head>
      <meta charset="UTF-8">
    </head>
    Il fît de la sorte,<br/>
    un assez long chemin.<br/>
    <bold>;-)</bold>
```

**Action 4.4.2 –** Renseigner le manifeste suivant:

```
# -------------------------------------------------------------
# Fichier: nginx+volumeVer2.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.03-2023.04.04
# -------------------------------------------------------------
# Exemple d'un manifeste pour un Pod nginx avec un volume local
#   défini via un configMap.
# -------------------------------------------------------------
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
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: volume-web
    # Définition des volumes
      volumes:
      - name: volume-web
        configMap:
          name: nginx-config-map # tel que nommé dans le configMap
          items:
            - key: contenu       # tel que nommé
              path: index.html

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  type: LoadBalancer
  ports:
    - protocol: TCP
      # Port à exposer au reseau local K8s
      port: 80
      # Port du conteneur - containerPort
      targetPort: 80
      nodePort: 30003
```

**Action 4.4.3 –** Appliquer les manifestes et tester l'application

```
kubectl apply -f configMapNginx.yml
kubectl apply -f nginx+volumeVer2.yml
minikube service nginx-service
```

**Note:** Le manifeste pour nginx est identique à celui que nous avons vu [ici à l'action 3.10](http://ve2cuy.com/420-4d4b/index.php/kubernetes-introduction/).  *Seules les directives au volume ont été ajoutées.*

---

**4.5 –** **Utilisation d'un configMap comme source d'un dossier**

**Action 4.5.0 –** Créer deux fichiers, **i1.html et** **i2.html**, dans le dossier **web-data**:

```
echo "Ceci est le fichier i1.html" > web-data/i1.html
echo "Ceci est le fichier i2.html" > web-data/i2.html
```

### Créer un configmap à partir de la ligne de commande

**Action 4.5 –** Créer un ConfigMap avec le cli, **kubectl create configmap**:

```
# Créer un configMap, contenant deux fichiers, avec le cli:
kubectl create configmap un-dir --from-file=web-data/i1.html --from-file=web-data/i2.html
```

**Action 4.5.1 –** Afficher le contenu du *configmap*:

```
kubectl describe configmaps un-dir 
Name:         un-dir
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
i1.html:
----
Ceci est le fichier i1.html
i2.html:
----
Ceci est le fichier i2.html
Events:  <none>
```

**Action 4.5.2 –** Renseigner un manifeste qui utilise le *configmap* comme source d'un dossier local:

```
# ------------------------------------------------------
# Fichier: nginx+volumeVer3.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.03-2023.04.04
# ------------------------------------------------------
# Exemple d'un manifeste pour un Pod nginx avec un 
#   dossier local défini via un configMap.
# ------------------------------------------------------
apiVersion: apps/v1
kind: Deployment
# Section 1 - Les Méta-données
metadata:
  name: nginx-deployment-v3
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
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: contenu-web

    # Définition des volumes
      volumes:
      - name: contenu-web
        configMap:
          name: un-dir
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  type: LoadBalancer
  ports:
    - protocol: TCP
      # Port à exposer au reseau local K8s
      port: 85
      # Port du conteneur - containerPort
      targetPort: 80
      nodePort: 30003
```

**Action 4.5.3 –** **À vous de tester, dans un fureteur, les deux documents du serveur Web.**

---

## 6 – Les 'secrets'

<img src="../images/keepingsecretsfromspouse-header-1024x538.jpg" alt="" width="450" />

> ***« Ce que tu veux tenir secret ne le dis à personne »***

---

Kubernetes offre la possibilité d'insérer des informations encryptées grace à l'utilisation de l'objet 'secret'.

Voyons comment cela fonctionne.

Pré-requis – Savoir créer le contenu d'un objet à partir d'un littéral.  Par exemple,

**Action 6.0 –** Créer, avec le cli, un configmap à partir d'un littéral:

```
kubectl create configmap nom-projet --from-literal=NOM_PROJET="Intro aux secrets K8s"

kubectl describe configmaps nom-projet 
Name:         nom-projet
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
NOM_PROJET:
----
Intro aux secrets K8s
Events:  <none>
```

**Action 6.0.1 –** Éditer le configmap, ajouter la ligne 6 (VERSION: V1.0):

```
$ kubectl edit configmaps nom-projet

apiVersion: v1
data:
  NOM_PROJET: Intro aux secrets K8s
  VERSION: V1.0
kind: ConfigMap
metadata:
  creationTimestamp: "2021-04-03T17:42:12Z"
  name: nom-projet
  namespace: default
  resourceVersion: "845860"
  uid: 2943be07-a21d-4f1e-a000-b8a89f39df6e
```

**Action 6.0.2 –** Afficher le contenu du configmap édité:

```
$ kubectl describe configmaps nom-projet

Name:         nom-projet
Namespace:    default

Data
====
NOM_PROJET:
----
Intro aux secrets K8s
VERSION:
----
V1.0
Events:  <none>
```

**Voila, nous sommes prêt à passer à l'action.**

**Action 6.1 –** Créer, avec le cli, un '*secret*' à partir d'un littéral:

```
kubectl create secret generic mysql-password --from-literal=MYSQL_ROOT_PASSWORD=JTELEDISPAS

secret/mysql-password created

# ATTENTION au nom du secret, seulement [a-z,-,.]
```

**Action 6.1.1 –** Afficher l'objet 'secret:mysql-password':

```
$ kubectl get secrets

NAME               TYPE                                  DATA   AGE
mysql-password     Opaque                                1      29m

$ kubectl describe secrets mysql-password

Name:         mysql-password
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
MYSQL_ROOT_PASSWORD:  11 bytes

# ---------

$ kubectl edit secrets mysql-password

# Note: Remarquez l'encodage du mot de passe, base64.
```

**Action 6.2 –** Renseigner le manifeste suivant:

```
# ------------------------------------------------------------
# Fichier: mysql+secret.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.03-2023.04.04
# -------------------------------------------------------------------------
# Exemple d'un manifeste pour un Pod mysql avec le mot de passe 'root'
#   dans un 'secret'.
# -------------------------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: mysql-secret
spec:
  containers:
  - name: mysql
    image: mysql
    env:
    - name: MYSQL_ROOT_PASSWORD
      valueFrom:
        # Noter que la directive est 'secretKeyRef' 
        # et non pas 'configMapKeyRef'  
        secretKeyRef:
          name: mysql-password  # mysql-password est le nom de l'objet 'secret'
          key: MYSQL_ROOT_PASSWORD # MYSQL_ROOT_PASSWORD est le nom de la var dans le secret
```

**Action 6.2.1 –** Appliquer le manifeste et tester le SGDB:

```
kubectl apply -f mysql+secret.yml 

kubectl exec -it mysql-secret -- bash

root@mysql-secret:/# mysql -uroot -JTELEDISPAS

mysql> show DATABASES;
```

---

### Création et utilisation d'un manifeste de type 'secret'

Voici comment renseigner un manifeste de type 'secret' et l'utiliser en un seul bloc dans un conteneur.

**Action 6.3 –** Renseigner un manifeste de type 'secret', 'top-secret-mysql.yml':

```
# Fichier: top-secret-mysql.yml
apiVersion: v1
kind: Secret
metadata:
  name: top-secret-mysql
type: Opaque
data:
  mysql-user: d3A=                          # echo -n 'wp' | base64
  mysql-user-password: dGVwYXNzZXJpZXV4     # echo -n 'tepasserieux' | base64
  mysql-database: d29yZHByZXNz              # echo -n 'wordpress' | base64
  mysql-root-password: aWxmaXRkZWxhc29ydGU= # echo -n 'ilfitdelasorte' | base64
```

**Action 6.3.1 –** Renseigner un manifeste de type 'Pod', 'mysql\_secretV2.yml':

```
# ------------------------------------------------------------
# Fichier: mysql+secretV2.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 09
# Date: 2021.04.03-2023.04.04
# -------------------------------------------------------------------------
# Exemple d'un manifeste pour un Pod mysql avec toutes les informations
#   de création du conteneur, dans un 'secret'.
# -------------------------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: mysql-secret-v2
spec:
  containers:
  - name: mysql
    image: mysql
    # Note: envFrom: au lieu de env:
    envFrom:
    - secretRef:
        name: top-secret-mysql
```

**Action 6.3.1 –** Appliquer les deux (2) manifestes et tester l'application

**NOTE**: Le SGBD retournera des messages d'erreur lors du démarrage (*kubectl logs mysql-secret-v2*):

```
2023-04-04 17:11:01+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
    You need to specify one of the following as an environment variable:
    - MYSQL_ROOT_PASSWORD
    - MYSQL_ALLOW_EMPTY_PASSWORD
    - MYSQL_RANDOM_ROOT_PASSWORD
```

**Expliquer les erreurs:**

---

---

Corriger le(s) manifeste(s) et relancer l'application.

```
kubectl apply -f top-secret-mysql.yml
kubectl apply -f mysql+secretV2.yml
kubectl exec -it mysql-secret-v2 -- bash

root@mysql-secret-v2:/# mysql -uroot -pilfitdelasorte

mysql> show DATABASES;
```

---

<img src="../images/labo02.png" alt="" width="700" />

### Laboratoire 6

Reprendre le **Laboratoire 3** en utilisant une ressource 'secret' pour le mot de passe et un configMap pour les autres informations.

---

## 7 – TP2: Mosquitto+node-red

* [Voici un exemple complet](http://ve2cuy.com/420-4d4b/index.php/kubernetes-node-red-mosquitto-configmap-secret/) d'une application [Node-RED](https://nodered.org) + [mosquitto](https://mosquitto.org) + configMap (pour les fichiers de configuration) + secret.

Encodage en [Base64](https://fr.wikipedia.org/wiki/Base64), [encodeur/décodeur](https://www.base64decode.org)

Référence: [K8s-secret](https://kubernetes.io/fr/docs/concepts/configuration/secret/)

---

###### Document rédigé par Alain Boudreault (c) 2021-2026 – version 2025.12.05.01

site par ve2cuy</parameter>