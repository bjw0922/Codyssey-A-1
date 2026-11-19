# Windows 10 + WSL2 Docker 개발 워크스테이션 구축

## 1. 프로젝트 개요

Windows 10 환경에서 WSL2, Ubuntu, VS Code, Docker 및 Git을 활용하여 개발 워크스테이션을 구축하였다.

Linux CLI를 통해 파일·디렉터리와 접근 권한을 관리하고, Docker를 이용하여 이미지 생성, 컨테이너 운영, NGINX 웹 서버 배포, 포트 매핑, 바인드 마운트, 볼륨 영속성 등을 실습하였다.

마지막으로 Git을 이용해 프로젝트의 변경 이력을 기록하고 GitHub에 업로드하였다.

## 2. 개발 환경

| 항목 | 환경 |
|---|---|
| OS | Windows 10 |
| Linux | WSL2 Ubuntu |
| IDE | Visual Studio Code |
| Container | Docker |
| Web Server | NGINX |
| Version Control | Git / GitHub |
| Project Path | `~/codyssey/workstation-lab` |

**버전 확인**

```bash
cat /etc/os-release
docker --version
docker info
git --version
```

[실제 버전 및 환경 출력 입력]

![Docker 환경 확인](docs/screenshots/04-docker-info.png)

## 3. Linux CLI 기본 명령어

**실습 목적:** Linux 명령어를 통해 파일 및 디렉터리를 직접 관리한다.

**주요 명령어**

```bash
pwd
ls -la
mkdir linux-practice
cd linux-practice
touch original.txt
echo "Hello Linux" > original.txt
cat original.txt
cp original.txt copied.txt
mv copied.txt renamed.txt
rm temp-dir/delete-me.txt
rmdir temp-dir
```

**실습 결과**

[실제 실행 결과 및 확인 내용 기록]

![Linux CLI](docs/screenshots/01-linux-cli.png)

## 4. 파일 및 디렉터리 권한

**실습 목적:** chmod 명령으로 접근 권한을 변경하고 전후를 비교한다.

```bash
chmod 600 permission.txt
chmod 700 permission-dir
ls -l permission.txt
ls -ld permission-dir

chmod 644 permission.txt
chmod 755 permission-dir
ls -l permission.txt
ls -ld permission-dir
```

**실습 결과**

[600·700과 644·755 권한 출력 기록]

![권한 변경 전](docs/screenshots/02-permission-before.png)

![권한 변경 후](docs/screenshots/03-permission-after.png)

## 5. Docker 설치 및 실행 상태 확인

```bash
docker --version
docker info
```

**실습 결과**

[Docker CLI 및 Server 정보 확인 결과]

![Docker 상태](docs/screenshots/04-docker-info.png)

## 6. Docker 기본 운영 및 컨테이너 실행

**실습 목적:** 이미지와 컨테이너를 생성·조회하고 로그 및 리소스를 확인한다.

```bash
docker run --name lab-hello hello-world
docker logs lab-hello

docker pull ubuntu:24.04
docker run -dit --name lab-ubuntu ubuntu:24.04 bash
docker exec -it lab-ubuntu bash

docker images
docker ps
docker ps -a
docker stats --no-stream
```

**실습 결과**

[hello-world 출력]

[Ubuntu 내부 ls 및 echo 출력]

[Docker 로그·리소스 출력]

![hello-world](docs/screenshots/05-hello-world.png)

![Docker logs](docs/screenshots/06-docker-logs.png)

![Ubuntu 컨테이너](docs/screenshots/07-ubuntu-container.png)

![Docker stats](docs/screenshots/08-docker-stats.png)

## 7. Dockerfile 기반 NGINX 이미지 제작

**실습 목적:** NGINX 기반 이미지에 직접 만든 HTML 파일을 포함한다.

**Dockerfile**

```dockerfile
FROM nginx:1.27-alpine
LABEL description="WSL2 Docker workstation assignment"
COPY site/ /usr/share/nginx/html/
EXPOSE 80
```

**빌드 명령**

```bash
docker build -t lab-nginx:1.0 .
docker images
```

**실습 결과**

[이미지 빌드 및 확인 결과]

![NGINX 이미지 빌드](docs/screenshots/09-docker-build.png)

## 8. Docker 포트 매핑

**실습 목적:** 하나의 이미지로 두 개의 웹 서버를 실행하고 서로 다른 호스트 포트로 접속한다.

```bash
docker run -d --name lab-web-8088 -p 127.0.0.1:8088:80 lab-nginx:1.0
docker run -d --name lab-web-8081 -p 127.0.0.1:8081:80 lab-nginx:1.0

curl -I http://localhost:8088
curl -I http://localhost:8081
docker ps
```

**실습 결과**

[각 포트의 실제 HTTP 응답]

![NGINX 8088](docs/screenshots/10-nginx-8088.png)

![NGINX 8081](docs/screenshots/11-nginx-8081.png)

![포트 매핑](docs/screenshots/12-port-mapping.png)

## 9. 바인드 마운트

**실습 목적:** 호스트 HTML을 수정하여 컨테이너의 웹 페이지에 즉시 반영되는지 확인한다.

```bash
docker run -d --name lab-bind \
  -p 127.0.0.1:8089:80 \
  --mount type=bind,source="$(pwd)/bind-site",target=/usr/share/nginx/html \
  nginx:1.27-alpine

curl http://localhost:8089
```

**실습 결과**

변경 전: [실제 결과]

변경 후: [실제 결과]

이미지 재빌드나 컨테이너 재시작 없이 HTML 변경사항이 반영되는지 검증하였다.

![수정 전](docs/screenshots/13-bind-before.png)

![수정 후](docs/screenshots/14-bind-after.png)

## 10. Docker 볼륨 영속성

**실습 목적:** 컨테이너를 삭제해도 볼륨에 저장된 데이터가 유지되는지 확인한다.

```bash
docker volume create lab-data

docker run -d --name lab-volume1 \
  -v lab-data:/data ubuntu:24.04 sleep infinity

docker exec lab-volume1 sh -c \
  'echo "Docker volume persistence success" > /data/result.txt'

docker exec lab-volume1 cat /data/result.txt

docker rm -f lab-volume1

docker run -d --name lab-volume2 \
  -v lab-data:/data ubuntu:24.04 sleep infinity

docker exec lab-volume2 cat /data/result.txt
```

**실습 결과**

컨테이너 삭제 전: [실제 출력]

컨테이너 삭제 후: [실제 출력]

![볼륨 저장](docs/screenshots/15-volume-before.png)

![볼륨 영속성](docs/screenshots/16-volume-after.png)

## 11. Git / GitHub

**실습 목적:** 프로젝트 변경 이력을 Git으로 기록하고 GitHub에 업로드한다.

```bash
git config --global user.name "본인 이름"
git config --global user.email "본인 이메일"
git config --global init.defaultBranch main
git config --list

git init
git add .
git commit -m "Complete Docker workstation assignment"

git remote add origin https://github.com/본인계정/workstation-lab.git
git push -u origin main
```

**실습 결과**

[Git 사용자 설정 결과]

[커밋 로그]

[원격 저장소 주소 및 업로드 결과]

![Git 설정](docs/screenshots/17-git-config.png)

![Git 커밋](docs/screenshots/18-git-commit.png)

![GitHub](docs/screenshots/19-github.png)

## 12. 트러블슈팅

### 사례 1

### 트러블슈팅 1. 종료된 컨테이너에 접근 실패

**문제:** Docker 컨테이너에 접속하려고 했지만 실행 중이지 않다는 오류가 발생하였다.

```text
Error response from daemon: container ... is not running
```

**원인:** `docker exec`는 실행 중인 컨테이너에서만 사용할 수 있는데, 해당 컨테이너가 종료된 상태였다.

**해결 과정:** `docker start`로 기존 컨테이너를 다시 실행하였다.

```bash
docker start lab-ubuntu
docker exec lab-ubuntu echo "Container is running"
```

**결과:** 컨테이너가 정상적으로 실행되어 내부 명령어를 수행할 수 있었다.

```text
Container is running
```

### 사례 2

### 트러블슈팅 2. Docker 컨테이너 이름 중복

**문제:** 이미 존재하는 컨테이너와 동일한 이름으로 새 컨테이너를 생성하여 충돌 오류가 발생하였다.

```text
Conflict. The container name "/lab-ubuntu" is already in use
```

**원인:** Docker는 종료된 컨테이너라도 기존 이름을 유지하기 때문에 같은 이름으로 새로운 컨테이너를 생성할 수 없다.

**해결 과정:** `docker ps -a`로 기존 컨테이너를 확인하고, 새로 생성하는 대신 `docker start`로 재사용하였다.

```bash
docker ps -a
docker start lab-ubuntu
```

**결과:** 새로운 컨테이너를 생성하지 않고 기존 컨테이너를 정상적으로 재실행하였다.

```text
lab-ubuntu
```

`docker ps`에서 `lab-ubuntu`가 `Up` 상태로 표시되는 것을 확인할 수 있다.

## 13. 최종 결과

이번 실습을 통해 Linux 기본 명령어와 파일 접근 권한을 관리하는 방법을 익혔다.

Docker 이미지와 컨테이너의 차이를 이해하고, Dockerfile을 이용한 NGINX 이미지 제작과 웹 서버 실행을 수행하였다.

포트 매핑을 통해 두 개의 웹 서버에 접속하고, 바인드 마운트와 볼륨을 이용하여 호스트 파일 공유 및 데이터 영속성을 실습하였다.

마지막으로 Git을 이용하여 프로젝트의 변경 이력을 기록하고 GitHub에 업로드하였다.

**GitHub 저장소:** [최종 저장소 URL]



## 14. 최종 제출 체크리스트

- [ ] Linux CLI 명령어 실습
- [ ] chmod 권한 변경 전후 비교
- [ ] Docker 설치 및 실행 확인
- [ ] Docker 이미지·컨테이너·로그·stats 확인
- [ ] hello-world 및 Ubuntu 컨테이너 실행
- [ ] Dockerfile 작성 및 커스텀 이미지 빌드
- [ ] NGINX 포트 매핑 및 접속 확인
- [ ] 바인드 마운트 변경 전후 검증
- [ ] 볼륨 영속성 확인
- [ ] Git 설정 및 GitHub 업로드
- [ ] 트러블슈팅 2건 이상
- [ ] 스크린샷 및 실제 결과 첨부
