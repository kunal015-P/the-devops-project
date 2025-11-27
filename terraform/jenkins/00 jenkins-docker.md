```
// Jenkins using docker 

sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo docker login
sudo docker images
sudo docker pull jenkins/jenkins:jdk21
sudo docker images
sudo docker run -d -p 8080:8080 jenkins/jenkins:jdk21
sudo docker container ls
sudo docker exec -it 5f0d0664d08b bash

// within container
cat /var/lib/jenkins/secrets/initialAdminPassword 

sudo docker container ls
sudo docker container stop 5f0d0664d08b
sudo docker container rm 5f0d0664d08b
sudo docker images
sudo docker rmi 84444d75a07c

```
