# DevOps Flask Dashboard

**Author:** [Kunal Mithare](https://github.com/kunal015-P) | [LinkedIn](https://www.linkedin.com/in/kunal-mithare-7b407a27a/)

## 🚀 Quick Run Instructions

### Local Development
```bash
cd app && pip install -r requirements.txt && python app.py
```
Open: http://localhost:5000

### Docker
```bash
docker build -t flask-app . && docker run -p 5000:5000 flask-app
```

### Kubernetes (EKS)
```bash
# Create cluster
./scripts/create-cluster.sh

# Deploy app
kubectl apply -f k8s/

# Get service URL
kubectl get svc -o wide
```

## 📁 Project Structure
```
├── app/app.py              # Flask API + Web UI
├── app/templates/          # HTML templates
├── k8s/*.yaml             # Kubernetes configs (28 lines total)
├── Dockerfile             # Container config (7 lines)
└── scripts/create-cluster.sh
```

## 💡 DevOps Theory Points

### Containerization
- **Docker**: Packages app + dependencies into portable containers
- **Image Layers**: Efficient caching and distribution
- **Multi-stage Builds**: Smaller production images

### Orchestration
- **Kubernetes**: Container orchestration platform
- **Pods**: Smallest deployable units
- **Services**: Network abstraction for pod access
- **LoadBalancer**: External traffic routing

### Cloud Native
- **EKS**: Managed Kubernetes on AWS
- **eksctl**: Simplified cluster creation
- **Infrastructure as Code**: Declarative YAML configs

## ❓ Interview Q&A

**Q: What is Docker?**
A: Containerization platform that packages applications with dependencies into lightweight, portable containers.

**Q: Kubernetes vs Docker?**
A: Docker creates containers, Kubernetes orchestrates them at scale.

**Q: What is a Pod?**
A: Smallest K8s unit containing one or more containers sharing network/storage.

**Q: Service Types in K8s?**
A: ClusterIP (internal), NodePort (node access), LoadBalancer (external).

**Q: What is eksctl?**
A: CLI tool for creating and managing EKS clusters easily.

## 🔧 Coding Reminders

### Flask Best Practices
```python
# Environment variables
os.environ.get('PORT', 5000)

# JSON responses
return jsonify({'status': 'healthy'})

# Template rendering
return render_template('index.html', data=data)
```

### Docker Optimization
```dockerfile
# Use specific versions
FROM python:3.11-slim

# Copy requirements first (layer caching)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app code last
COPY . .
```

### Kubernetes Essentials
```yaml
# Always set resource limits
resources:
  limits:
    memory: "256Mi"
    cpu: "250m"

# Health checks
livenessProbe:
  httpGet:
    path: /health
    port: 5000
```

## 🛠 Tech Stack
- **Flask** - Python web framework
- **Docker** - Containerization 
- **Kubernetes** - Container orchestration
- **AWS EKS** - Managed K8s service
