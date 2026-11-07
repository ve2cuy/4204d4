# 47 - Kubectl – Référence rapide

*Révision du 2026.11.07*

## Contenu

- [**🔧 Contexte & Configuration**](#section-contexte-configuration)
- [**📦 Pods**](#section-pods)
- [**🚀 Déploiements**](#section-deploiements)
- [**🌐 Services & Réseau**](#section-services-reseau)
- [**⚙️ ConfigMaps & Secrets**](#section-configmaps-secrets)
- [**🔐 RBAC**](#section-rbac)
- [**📂 Namespaces**](#section-namespaces)
- [**📊 Jobs & CronJobs**](#section-jobs-cronjobs)
- [**📦 Stockage**](#section-stockage)
- [**🔍 Débogage**](#section-debogage)
- [**📄 YAML & Apply**](#section-yaml-apply)
- [**🧹 Nettoyage**](#section-nettoyage)
- [**📝 Exemples pour la création de ressources**](#section-exemples-pour-la-creation-de-ressources)
- [**Contextes – Tableau de référence rapide**](#section-contextes-tableau-de-reference-rapide)
- [**Workspaces (Namespaces) – Tableau de référence rapide**](#section-workspaces-namespaces-tableau-de-referen)

---

## 🔧 Contexte & Configuration {#section-contexte-configuration}

| Commande | Description |
| :--- | :--- |
| `kubectl config get-contexts` | Lister les contextes |
| `kubectl config use-context <ctx>` | Basculer de contexte |
| `kubectl config current-context` | Voir le contexte actif |
| `kubectl config set-context --current --namespace=<ns>` | Définir le namespace par défaut |

-----

## 📦 Pods {#section-pods}

| Commande | Description |
| :--- | :--- |
| `kubectl get pods [-A]` | Lister les pods |
| `kubectl describe pod <pod>` | Détails d’un pod |
| `kubectl logs <pod> [-c <container>]` | Logs |
| `kubectl exec -it <pod> -- sh` | Shell dans un pod |
| `kubectl delete pod <pod>` | Supprimer/redémarrer un pod |

-----

## 🚀 Déploiements {#section-deploiements}

| Commande | Description |
| :--- | :--- |
| `kubectl get deploy` | Lister les déploiements |
| `kubectl scale deploy <name> --replicas=N` | Mise à l’échelle |
| `kubectl rollout status\|history\|undo deploy <name>` | Suivi / rollback |
| `kubectl edit deploy <name>` | Modifier en place |

-----

## 🌐 Services & Réseau {#section-services-reseau}

| Commande | Description |
| :--- | :--- |
| `kubectl get svc` | Lister les services |
| `kubectl expose deploy nginx --port=80 --type=LoadBalancer` | Exposer un déploiement |
| `kubectl port-forward svc/<svc> 8080:80` | Redirection de port |
| `kubectl get ingress` | Lister les ingress |

-----

## ⚙️ ConfigMaps & Secrets {#section-configmaps-secrets}

| Commande | Description |
| :--- | :--- |
| `kubectl get configmap\|secret` | Lister |
| `kubectl create configmap <name> --from-literal=key=val` | Créer ConfigMap |
| `kubectl create secret generic <name> --from-literal=key=val` | Créer Secret |
| `kubectl get secret <name> -o yaml` | Voir encodé |
| `kubectl get secret <name> -o jsonpath="{.data.key}" \| base64 -d` | Décoder (pour la valeur d'une clé) |

-----

## 🔐 RBAC {#section-rbac}

| Commande | Description |
| :--- | :--- |
| `kubectl create sa <name>` | Créer ServiceAccount |
| `kubectl get clusterrolebinding -A` | Lister bindings |
| `kubectl auth can-i get pods --as=system:sa:ns:sa` | Vérifier accès |

-----

## 📂 Namespaces {#section-namespaces}

| Commande | Description |
| :--- | :--- |
| `kubectl get ns` | Lister |
| `kubectl create ns <name>` | Créer |
| `kubectl delete ns <name>` | Supprimer |

-----

## 📊 Jobs & CronJobs {#section-jobs-cronjobs}

| Commande | Description |
| :--- | :--- |
| `kubectl create job hello --image=busybox -- echo Hi` | Créer un Job simple |
| `kubectl create cronjob hello --image=busybox --schedule="*/5 * * * *" -- echo Hi` | Créer un CronJob |
| `kubectl get jobs\|cronjob` | Lister Jobs et CronJobs |

-----

## 📦 Stockage {#section-stockage}

| Commande | Description |
| :--- | :--- |
| `kubectl get pv\|pvc` | Lister PersistentVolumes et PersistentVolumeClaims |
| `kubectl describe pvc <name>` | Détails d'un PersistentVolumeClaim |
| `kubectl delete pvc <name>` | Supprimer un PersistentVolumeClaim |

-----

## 🔍 Débogage {#section-debogage}

| Commande | Description |
| :--- | :--- |
| `kubectl get events --sort-by=.metadata.creationTimestamp` | Événements |
| `kubectl logs <pod> --previous` | Logs d’un pod qui a crashé |
| `kubectl debug -it <pod> --image=busybox` | Pod de debug (ajout d'un conteneur temporaire) |
| `kubectl top pod` | Ressources CPU/Mémoire |

-----

## 📄 YAML & Apply {#section-yaml-apply}

| Commande | Description |
| :--- | :--- |
| `kubectl apply -f file.yaml` | Appliquer une configuration depuis un fichier |
| `kubectl delete -f file.yaml` | Supprimer les ressources définies dans le fichier |
| `kubectl explain <resource>` | Afficher le schéma d'une ressource |

-----

## 🧹 Nettoyage {#section-nettoyage}

| Commande | Description |
| :--- | :--- |
| `kubectl delete all --all` | Tout supprimer dans un namespace (pods, services, etc.) |
| `kubectl delete pod,svc -l app=nginx` | Supprimer par label |

-----

## 📝 Exemples pour la création de ressources {#section-exemples-pour-la-creation-de-ressources}

### Création rapide

  * **Création d’un Pod simple :**
    ```bash
    kubectl run nginx --image=nginx
    ```
  * **Création d’un déploiement :**
    ```bash
    kubectl create deployment nginx --image=nginx
    ```
  * **Création d’un Service exposant un déploiement :**
    ```bash
    kubectl expose deployment nginx --port=80 --target-port=80 --type=LoadBalancer
    ```
  * **Création d’un ConfigMap :**
    ```bash
    kubectl create configmap mon-config --from-literal=cle=valeur
    ```
  * **Création d’un Secret générique :**
    ```bash
    kubectl create secret generic mon-secret --from-literal=motdepasse=123456
    ```

-----

## Contextes – Tableau de référence rapide {#section-contextes-tableau-de-reference-rapide}

| **Commande** | **Description** | **Exemple** |
| :--- | :--- | :--- |
| `kubectl config get-contexts` | Liste tous les contextes du kubeconfig | `kubectl config get-contexts` |
| `kubectl config current-context` | Affiche le contexte actif | `kubectl config current-context` |
| `kubectl config use-context NAME` | Bascule vers un contexte existant | `kubectl config use-context dev-cluster` |
| `kubectl config set-context NAME --cluster=C --user=U --namespace=N` | Crée ou met à jour un contexte | `kubectl config set-context prod --cluster=prod-cl --user=admin --namespace=default` |
| `kubectl config set-cluster NAME --server=URL --certificate-authority=FILE` | Définir ou modifier une entrée cluster | `kubectl config set-cluster prod-cl --server=https://1.2.3.4` |
| `kubectl config set-credentials NAME --token=TOKEN` | Créer ou mettre à jour des identifiants utilisateur | `kubectl config set-credentials ci-user --token=abc123` |
| `kubectl config view --minify` | Affiche la configuration du contexte courant uniquement | `kubectl config view --minify` |
| `kubectl config unset contexts.NAME` | Supprime un contexte du kubeconfig | `kubectl config unset contexts.old-context` |
| `kubectl config rename-context OLD_NAME NEW_NAME` | Renomme un contexte existant | `kubectl config rename-context staging staging-old` |
| `kubectl config view --flatten` | Fusionne et aplatit les fichiers kubeconfig pour export | `kubectl config view --flatten > merged-kubeconfig` |

-----

## Workspaces (Namespaces) – Tableau de référence rapide {#section-workspaces-namespaces-tableau-de-referen}

| **Tâche** | **Commande kubectl** | **Description** |
| :--- | :--- | :--- |
| **Lister les Namespaces** | `kubectl get namespaces` ou `kubectl get ns` | Affiche tous les espaces de noms existants dans le cluster. |
| **Créer un Namespace** | `kubectl create namespace <nom-du-ns>` | Crée un nouvel espace de noms. |
| **Supprimer un Namespace** | `kubectl delete namespace <nom-du-ns>` | Supprime l’espace de noms et **toutes les ressources qu’il contient** (Pods, Deployments, Services, etc.). |
| **Afficher les détails** | `kubectl describe namespace <nom-du-ns>` | Affiche les informations détaillées sur un espace de noms spécifique. |
| **Vérifier les ressources dans un NS** | `kubectl get all -n <nom-du-ns>` | Affiche un aperçu de la plupart des ressources (Pods, Deployments, Services, etc.) dans l’espace de noms spécifié. |
| **Exécuter une commande dans un NS spécifique** | `kubectl <commande> <ressource> -n <nom-du-ns>` | Applique une commande (comme `get`, `apply`, `delete`) uniquement aux ressources de cet espace de noms. |
| **Définir un Namespace par défaut (Temporaire)** | `kubectl config set-context --current --namespace=<nom-du-ns>` | Change l’espace de noms par défaut pour le contexte `kubectl` actuel. |
| **Créer un Namespace via YAML** | `kubectl apply -f <fichier.yml>` (où `fichier.yml` définit `kind: Namespace`) | Méthode déclarative pour la création, souvent utilisée en production. |

**ATTENTION:** vérifiez toujours le contexte actif avant toute opération à risque avec `kubectl config current-context`.

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2026*  
*Version 2025.12.03.1 - Révision 2026.11.07.1*  
*Site par ve2cuy*