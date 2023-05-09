# tfy-manifests-template
This chart is an empty chart which is used to deploy k8s manifests directly from argo.

There is one variable namely `manifests` which is used to pass multiple manifest objects.

Below is the sample values file that can write multiple manifests
```
manifests:
- apiVersion: v1
  kind: Service
  metadata:
    name: helm-guestbook
    labels:
      app: helm-guestbook
  spec:
    type: ClusterIP
    ports:
      - port: 80
        targetPort: http
        protocol: TCP
        name: http
    selector:
      app: helm-guestbook
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: helm-guestbook
    labels:
      foo: bar
  spec:
    replicas: 1
    revisionHistoryLimit: 3
    selector:
      matchLabels:
        app: helm-guestbook
    template:
      metadata:
        labels:
          app: helm-guestbook
      spec:
        containers:
          - name: helm-guestbook
            image: "gcr.io/heptio-images/ks-guestbook-demo:0.1"
            imagePullPolicy: IfNotPresent
            ports:
              - name: http
                containerPort: 80
                protocol: TCP
            livenessProbe:
              httpGet:
                path: /
                port: http
            readinessProbe:
              httpGet:
                path: /
                port: http
            resources:
              limits:
                memory: 512Mi

```