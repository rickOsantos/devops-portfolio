# 01‑docker‑multi‑container

This project demonstrates **containerisation** of a simple Node.js application and a supporting Redis cache.

## 📦 What it contains
- `Dockerfile` – multi‑stage build that produces a lean Node.js image.
- `docker-compose.yml` – starts the app together with a Redis container.
- `k8s-manifests/` – Kubernetes `Deployment` and `Service` files for the same app.
- `app.js` – a minimal Express API that reads/writes a counter stored in Redis.

## 🚀 Quick start (Docker Compose)
```bash
cd 01-docker-multi-container
docker compose up -d
```
The API will be reachable at `http://localhost:3000`.

## 📂 Kubernetes deployment
```bash
kubectl apply -f k8s-manifests/
```
A `LoadBalancer` service is created (or `NodePort` on minikube). Use `kubectl get svc` to retrieve the external IP.

## 📊 Monitoring
Both containers expose Prometheus metrics at `/metrics` (Node.js app) and the Redis exporter is included in the `docker‑compose.yml`.

---

## 📄 Documentation
See the individual README files in each sub‑folder for more details on environment variables, health checks, and testing.
