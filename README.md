# Windows 10 + WSL2 Docker 개발 워크스테이션 구축

> 실습 과정의 화면 증거는 `docs/screenshots/`에 정리하였다. 각 이미지에는 해당 실습 단계의 설명을 함께 표기하였다.

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

### 프로젝트 파일 구조 및 역할 (평가 #10)

```text
workstation-lab/
├── README.md                 # 실습 과정·명령어·결과 설명
├── Dockerfile                # NGINX 이미지 설정
├── .gitignore                # Git 추적 제외 설정
├── site/index.html           # 커스텀 NGINX 웹 페이지
├── bind-site/index.html      # 바인드 마운트 웹 페이지
├── labs/cli-demo/            # Linux CLI 실습 파일
│   ├── original.txt
│   └── permission.txt
└── docs/screenshots/         # 실습 단계별 스크린샷
```

실행 파일과 실습 증거를 분리하여 README에서 단계별 결과를 쉽게 확인할 수 있도록 구성하였다.

### 실습 재현 전제 조건 (평가 #11)

Windows에서 WSL2 Ubuntu와 Docker를 사용할 수 있어야 하며, 모든 프로젝트 명령은 **VS Code의 Ubuntu Bash 터미널**에서 `cd ~/codyssey/workstation-lab`을 실행한 뒤 진행한다. 컨테이너가 이미 존재할 때는 `docker run`을 반복하지 않고 `docker ps -a`로 확인하여 `docker start`를 사용한다.


## 3. Linux CLI 기본 명령어

**실습 목적:** Linux 명령어를 통해 파일 및 디렉터리를 직접 관리한다.

**주요 명령어**

```bash
pwd
ls -la
mkdir -p labs/cli-demo
cd labs/cli-demo
touch original.txt
echo "Hello Linux" > original.txt
cat original.txt
cp original.txt copied.txt
mv copied.txt renamed.txt
mkdir -p temp-dir
touch temp-dir/delete-me.txt
rm temp-dir/delete-me.txt
rmdir temp-dir
```

**실습 결과**
![Linux CLI 명령어 실습 1](docs/screenshots/1.%ED%84%B0%EB%AF%B8%EB%84%90%20%EA%B8%B0%EB%B3%B8%20%EC%A1%B0%EC%9E%91_1.PNG)
![Linux CLI 명령어 실습 2](docs/screenshots/1.%ED%84%B0%EB%AF%B8%EB%84%90%20%EA%B8%B0%EB%B3%B8%20%EC%A1%B0%EC%9E%91_2.PNG)

파일 생성(`touch`), 복사(`cp`), 이름 변경(`mv`), 삭제(`rm`/`rmdir`) 명령으로 작업 디렉터리 내 파일 상태를 변경한다. `ls -la`와 `cat`으로 최종 상태를 확인한다.


## 4. 파일 및 디렉터리 권한

**실습 목적:** chmod 명령으로 접근 권한을 변경하고 전후를 비교한다.

```bash
mkdir -p permission-dir
chmod 600 permission.txt
chmod 700 permission-dir
ls -l permission.txt
ls -ld permission-dir

chmod 644 permission.txt
chmod 755 permission-dir
ls -l permission.txt
ls -ld permission-dir
```

### 권한 숫자의 원리 (평가 #15)

Linux 권한은 **소유자(User) / 그룹(Group) / 기타 사용자(Others)** 순서로 표기한다. 읽기 `r=4`, 쓰기 `w=2`, 실행 `x=1`을 더하여 각 자리의 숫자를 만든다. 파일의 `x`는 실행, 디렉터리의 `x`는 내부 경로에 진입·탐색할 수 있는 권한을 의미한다.

| 명령 | 계산 | 결과 문자열의 권한 부분 |
|---|---|---|
| `chmod 600 permission.txt` | 소유자 4+2, 그룹 0, 기타 0 | `rw-------` |
| `chmod 644 permission.txt` | 소유자 4+2, 그룹 4, 기타 4 | `rw-r--r--` |
| `chmod 700 permission-dir` | 소유자 4+2+1, 그룹 0, 기타 0 | `rwx------` |
| `chmod 755 permission-dir` | 소유자 4+2+1, 그룹 4+1, 기타 4+1 | `rwxr-xr-x` |

**실습 결과 — 권한 변경 확인 (평가 #2)**
![chmod 권한 변경 실습](docs/screenshots/2.%20chmod%20%ED%8C%8C%EC%9D%BC%20%EB%B0%8F%20%EB%94%94%EB%A0%89%ED%84%B0%EB%A6%AC%20%EA%B6%8C%ED%95%9C%20%EB%B3%80%EA%B2%BD.PNG)

위 권한 문자열은 기대값이며, 소유자·날짜·크기 등 실제 출력은 사용자 환경에서 확인해 기록한다.


## 5. Docker 설치 및 실행 상태 확인

```bash
docker --version
docker info
```

**실습 결과**
![Docker 설치 및 데몬 상태](docs/screenshots/3.%20Docker%20%EC%84%A4%EC%B9%98%C2%B7%EB%8D%B0%EB%AA%AC%20%ED%99%95%EC%9D%B8.PNG)
`docker --version`은 CLI 설치 여부를, `docker info`의 `Server`는 엔진(데몬) 연결 여부를 확인한다. CLI가 설치되어 있더라도 서버에 연결되지 않으면 컨테이너를 실행할 수 없다.


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

### 이미지와 컨테이너의 차이 (평가 #12)

**이미지(Image)**는 프로그램과 실행 환경을 담은 읽기 전용 템플릿이고, **컨테이너(Container)**는 해당 이미지를 기반으로 생성한 실행 인스턴스이다. 하나의 이미지로 여러 컨테이너를 만들 수 있다.

| 과정 | 명령 | 무엇이 달라지는가 |
|---|---|---|
| 이미지 확보 | `docker pull ubuntu:24.04` | 로컬에 이미지 다운로드 |
| 이미지 제작 | `docker build -t lab-nginx:1.0 .` | Dockerfile로 새 이미지 생성 |
| 컨테이너 실행 | `docker run ...` | 이미지를 기반으로 컨테이너 생성·실행 |
| 기존 컨테이너 재실행 | `docker start lab-ubuntu` | 기존 컨테이너를 다시 실행, 새로 만들지 않음 |
| 웹 파일 수정 | `site/index.html` 편집 | 로컬 소스만 변경; 이미 빌드한 이미지에는 자동 반영되지 않음 |
| 수정 내용 배포 | `docker build` 후 컨테이너 재생성 | 새 이미지로 만든 컨테이너에 변경된 웹 파일 적용 |

바인드 마운트로 연결된 파일은 예외적으로 이미지 재빌드 없이 변경 내용이 반영될 수 있다. `docker exec`는 실행 중인 컨테이너에 명령을 실행하고, `docker logs`는 프로세스 출력을 확인한다.


**실습 결과**
![hello-world 이미지 실행](docs/screenshots/4.%20hello-world%20%EC%9D%B4%EB%AF%B8%EC%A7%80%20%EC%8B%A4%ED%96%89.PNG)
![hello-world 실행 후 컨테이너 상태](docs/screenshots/5.%20Docker%20hello-world%20%EB%AA%A9%EB%A1%9D%20%EB%B0%8F%20%EC%A2%85%EB%A3%8C%20%ED%99%95%EC%9D%B8.PNG)

**Ubuntu 컨테이너 내부 실습:** `docker exec -it lab-ubuntu bash` 후 `pwd`, `ls -la`, `echo "Hello from Docker Ubuntu"`를 입력하고 결과를 기록한다.
![Ubuntu 컨테이너 내부 명령어 1](docs/screenshots/6.%20%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%20%EB%82%B4%EB%B6%80%20%EC%8B%A4%EC%8A%B5.PNG)
![Ubuntu 컨테이너 내부 명령어 2](docs/screenshots/6.%20%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%20%EB%82%B4%EB%B6%80%20%EC%8B%A4%EC%8A%B5_2.PNG)
![컨테이너 상태 및 리소스 확인](docs/screenshots/7.%20%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%EC%9D%98%20%EC%83%81%ED%83%9C%20%EB%B0%8F%20%EC%9E%90%EC%9B%90%20%ED%99%95%EC%9D%B8.PNG)

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

`FROM`은 기반 이미지, `COPY`는 웹 파일을 이미지 안으로 복사하는 명령, `EXPOSE 80`은 사용 포트를 문서화하는 메타데이터이다. `EXPOSE`만으로 호스트 포트가 열리지는 않는다.

**검증 순서:** (1) `site/` 파일 확인 → (2) `docker build` 성공 → (3) `docker images`에서 `lab-nginx:1.0` 확인 → (4) 다음 절에서 컨테이너 실행.
![Dockerfile 작성 및 이미지 빌드](docs/screenshots/8.%20Dockerfile%EA%B3%BC%20%EB%B9%8C%EB%93%9C%20%EA%B2%B0%EA%B3%BC.PNG)
![커스텀 웹 서버 컨테이너 실행](docs/screenshots/9.%20%EC%BB%A4%EC%8A%A4%ED%85%80%20%EC%9D%B4%EB%AF%B8%EC%A7%80%EC%9D%98%20%EC%9B%B9%20%EC%84%9C%EB%B2%84%20%EC%8B%A4%ED%96%89%20%EB%B0%8F%20%EB%AA%A9%EB%A1%9D.PNG)

빌드 과정은 아래 스크린샷에서 확인할 수 있으며, 장문의 출력은 필요할 경우 별도 로그 파일로 관리할 수 있다.

## 8. Docker 포트 매핑

**실습 목적:** 하나의 이미지로 두 개의 웹 서버를 실행하고 서로 다른 호스트 포트로 접속한다.

```bash
docker run -d --name lab-web-8088 -p 127.0.0.1:8088:80 lab-nginx:1.0
docker run -d --name lab-web-8081 -p 127.0.0.1:8081:80 lab-nginx:1.0

curl -I http://localhost:8088
curl -I http://localhost:8081
docker ps
```

### 네트워크 격리와 포트 포워딩 (평가 #13)

Linux 컨테이너는 일반적으로 별도 **네트워크 네임스페이스**에서 동작하므로 호스트와 네트워크 인터페이스·IP·포트 공간이 분리된다. NGINX가 컨테이너 내부 `80`번 포트를 사용한다고 해서 호스트의 `80`번 포트로 자동 공개되는 것은 아니다. `-p 127.0.0.1:8088:80`은 **호스트 루프백 주소 127.0.0.1의 8088번 포트**를 **컨테이너의 80번 포트**로 게시·전달하는 설정이다.

```text
Windows 브라우저 / Ubuntu curl
          │ http://localhost:8088
          ▼
호스트 127.0.0.1:8088
          │ Docker 포트 게시·전달
          ▼
lab-web-8088 컨테이너 :80 (NGINX)

호스트 127.0.0.1:8081 ──> lab-web-8081 컨테이너 :80
```

두 컨테이너는 모두 내부 `80`번 포트를 사용하지만 호스트에서는 서로 다른 포트(`8088`, `8081`)를 사용하여 충돌하지 않는다. `127.0.0.1`로 바인딩했기 때문에 기본적으로 로컬에서 접근하도록 제한된다.

### 포트 충돌 시 진단 순서 (평가 #16)

`port is already allocated` 등의 오류가 발생하면 다음 순서로 확인한다.

1. **Docker 점유 확인:** `docker ps --format 'table {{.Names}}\t{{.Ports}}'`로 해당 호스트 포트를 사용하는 컨테이너를 찾는다.
2. **Ubuntu 소켓 확인:** `sudo ss -ltnp | grep ':8088'`로 리스닝 소켓을 확인한다. WSL2/Docker Desktop 구성에서는 이 출력만으로 Windows 측 포트 점유자를 모두 확인할 수 없다.
3. **Windows 점유 확인(필요 시):** Ubuntu 터미널에서 `cmd.exe /C "netstat -ano | findstr :8088"`로 PID를 확인하고, Windows 작업 관리자에서 PID에 해당하는 프로세스를 확인한다.
4. **해결:** 기존 컨테이너를 중지해도 되는 경우 `docker stop lab-web-8088`; 기존 서비스를 유지해야 한다면 새 컨테이너를 `-p 127.0.0.1:8090:80`으로 실행한다. 알 수 없는 프로세스에 무조건 `kill`을 실행하지 않는다.
5. **재검증:** `docker ps`와 `curl -I http://localhost:8090` 또는 원래 포트의 응답을 확인한다.

이 절차는 **포트 충돌이 발생했을 때의 대응 방법**이며, 이번 실습에서 실제로 포트 충돌 오류가 발생했다는 뜻은 아니다.


**실습 결과**
![10. 도커 포트매핑을 통한 웹서버 생성-1](docs/screenshots/10.%20%EB%8F%84%EC%BB%A4%20%ED%8F%AC%ED%8A%B8%EB%A7%A4%ED%95%91%EC%9D%84%20%ED%86%B5%ED%95%9C%20%EC%9B%B9%EC%84%9C%EB%B2%84%20%EC%83%9D%EC%84%B1-1.PNG)
![10. 도커 포트매핑을 통한 웹서버 생성-8088](docs/screenshots/10.%20%EB%8F%84%EC%BB%A4%20%ED%8F%AC%ED%8A%B8%EB%A7%A4%ED%95%91%EC%9D%84%20%ED%86%B5%ED%95%9C%20%EC%9B%B9%EC%84%9C%EB%B2%84%20%EC%83%9D%EC%84%B1-8088.PNG)
![10. 도커 포트매핑을 통한 웹서버 생성-2](docs/screenshots/10.%20%EB%8F%84%EC%BB%A4%20%ED%8F%AC%ED%8A%B8%EB%A7%A4%ED%95%91%EC%9D%84%20%ED%86%B5%ED%95%9C%20%EC%9B%B9%EC%84%9C%EB%B2%84%20%EC%83%9D%EC%84%B1-2.PNG)
![10. 도커 포트매핑을 통한 웹서버 생성-8081](docs/screenshots/10.%20%EB%8F%84%EC%BB%A4%20%ED%8F%AC%ED%8A%B8%EB%A7%A4%ED%95%91%EC%9D%84%20%ED%86%B5%ED%95%9C%20%EC%9B%B9%EC%84%9C%EB%B2%84%20%EC%83%9D%EC%84%B1-8081.PNG)

## 9. 바인드 마운트

**실습 목적:** 호스트 HTML을 수정하여 컨테이너의 웹 페이지에 즉시 반영되는지 확인한다.

```bash
docker run -d --name lab-bind \
  -p 127.0.0.1:8089:80 \
  --mount type=bind,source="$(pwd)/bind-site",target=/usr/share/nginx/html \
  nginx:1.27-alpine

curl http://localhost:8089
```

### 경로 선정 이유 (평가 #14)

`$(pwd)`는 현재 작업 폴더의 **절대 경로**를 반환하므로, 반드시 프로젝트 루트에서 실행하면 `bind-site`의 위치를 명확히 지정할 수 있다. `source`는 호스트 Ubuntu의 실제 파일 폴더, `target`은 NGINX가 정적 파일을 읽는 컨테이너 경로이다. 이 경로를 정확하게 사용하고 파일 읽기 권한을 확보해야 설정을 재현할 수 있다. 바인드 마운트는 컨테이너 이미지의 대상 경로에 원래 있던 파일을 가려 보이게 할 수 있으므로 주의한다.

**검증 순서:** (1) 변경 전 `curl`/브라우저 캡처 → (2) `bind-site/index.html` 수정 및 저장 → (3) **재빌드·재시작 없이** 동일 주소 요청 → (4) `docker inspect lab-bind --format '{{json .Mounts}}'`로 연결 경로 확인.


**실습 결과**
![11. 바인드 마운트용 폴더 생성](docs/screenshots/11.%20%EB%B0%94%EC%9D%B8%EB%93%9C%20%EB%A7%88%EC%9A%B4%ED%8A%B8%EC%9A%A9%20%ED%8F%B4%EB%8D%94%20%EC%83%9D%EC%84%B1.PNG)
![11. 바인드 마운트 이전 웹사이트](docs/screenshots/11.%20%EB%B0%94%EC%9D%B8%EB%93%9C%20%EB%A7%88%EC%9A%B4%ED%8A%B8%20%EC%9D%B4%EC%A0%84%20%EC%9B%B9%EC%82%AC%EC%9D%B4%ED%8A%B8.PNG)
![11. 바인드 마운트 내용 변경됨](docs/screenshots/11.%20%EB%B0%94%EC%9D%B8%EB%93%9C%20%EB%A7%88%EC%9A%B4%ED%8A%B8%20%EB%82%B4%EC%9A%A9%20%EB%B3%80%EA%B2%BD%EB%90%A8.PNG)
![11. 바인드 마운트 이후 웹사이트](docs/screenshots/11.%20%EB%B0%94%EC%9D%B8%EB%93%9C%20%EB%A7%88%EC%9A%B4%ED%8A%B8%20%EC%9D%B4%ED%9B%84%20%EC%9B%B9%EC%82%AC%EC%9D%B4%ED%8A%B8.PNG)

이미지 재빌드나 컨테이너 재시작 없이 HTML 변경사항이 반영되는지 검증하였다.

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
![12. 볼륨 첫번째 컨테이너 저장](docs/screenshots/12.%20%EB%B3%BC%EB%A5%A8%20%EC%B2%AB%EB%B2%88%EC%A7%B8%20%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%20%EC%A0%80%EC%9E%A5.PNG)
![12. 볼륨 두번째 컨테이너 저장 후 실행 결과](docs/screenshots/12.%20%EB%B3%BC%EB%A5%A8%20%EB%91%90%EB%B2%88%EC%A7%B8%20%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%20%EC%A0%80%EC%9E%A5%20%ED%9B%84%20%EC%8B%A4%ED%96%89%20%EA%B2%B0%EA%B3%BC.PNG)
![12. 볼륨 목록 및 결과](docs/screenshots/12.%20%EB%B3%BC%EB%A5%A8%20%EB%AA%A9%EB%A1%9D%20%EB%B0%8F%20%EA%B2%B0%EA%B3%BC.PNG)
### 볼륨 백업 및 복구 (평가 #17)

볼륨은 컨테이너와 별도로 데이터를 관리하지만, **볼륨 자체를 삭제하거나 Docker 데이터 저장소를 초기화하면 데이터가 사라질 수 있어** 중요한 데이터는 백업한다. 아래는 실습용 `lab-data` 볼륨을 `backup/`에 `tar.gz`로 저장하고, 별도의 `lab-restored` 볼륨에 복구하는 예시이다. **프로젝트 루트에서 실행하며, 실제 실행 후 결과를 기록한다.**

```bash
mkdir -p backup
# 원본 볼륨을 읽기 전용으로 연결해 아카이브 생성
docker run --rm -v lab-data:/data:ro -v "$(pwd)/backup":/backup alpine \
  tar -czf /backup/lab-data.tar.gz -C /data .
# 복구 볼륨은 원본과 별개로 생성
docker volume create lab-restored
docker run --rm -v lab-restored:/data -v "$(pwd)/backup":/backup:ro alpine \
  tar -xzf /backup/lab-data.tar.gz -C /data
# 복구 검증
docker run --rm -v lab-restored:/data:ro ubuntu:24.04 cat /data/result.txt
```

**참고:** 볼륨 백업·복구 명령은 추가 검증을 위한 예시이며, 해당 실행 결과는 첨부된 화면에 포함되지 않는다.

**볼륨 삭제 전후 확인 방법 (평가 #8)**


## 11. Git / GitHub

**실습 목적:** 프로젝트 변경 이력을 Git으로 기록하고 GitHub에 업로드한다.

```bash
git config --global user.name "본인 이름"
git config --global user.email "본인 이메일"
git config --global init.defaultBranch main
git config --list

# 최초 저장소 생성 시에만 git init 실행
git init
git add .
git commit -m "Complete Docker workstation assignment"

git remote add origin https://github.com/bjw0922/Codyssey-A-1.git
git push -u origin main
```

**실습 결과**
![13. git 버전 및 사용자 설정](docs/screenshots/13.%20git%20%EB%B2%84%EC%A0%84%20%EB%B0%8F%20%EC%82%AC%EC%9A%A9%EC%9E%90%20%EC%84%A4%EC%A0%95.PNG)
![14. git 추가 후 커밋](docs/screenshots/14.%20git%20%EC%B6%94%EA%B0%80%20%ED%9B%84%20%EC%BB%A4%EB%B0%8B.PNG)
![14. git 업로드 완료](docs/screenshots/14.%20git%20%EC%97%85%EB%A1%9C%EB%93%9C%20%EC%99%84%EB%A3%8C.PNG)  

**주의:** `git init`과 `git remote add origin`은 최초 설정할 때만 사용한다. 이미 연결된 저장소는 수정 후 `git add README.md docs/`, `git commit -m "docs: improve README evidence"`, `git push` 순으로 갱신한다. 원격 변경이 있다면 먼저 충돌을 해결해야 하며 `git push --force`는 피한다.

## 12. 트러블슈팅

아래는 Docker 실행 과정에서 다룬 대표적인 문제와 해결 절차다. 오류 상황은 각 항목의 스크린샷을 참고한다.

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
![15. 트래블슈터 종료된 컨테이너](docs/screenshots/15.%20%ED%8A%B8%EB%9E%98%EB%B8%94%EC%8A%88%ED%84%B0%20%EC%A2%85%EB%A3%8C%EB%90%9C%20%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88.PNG)
**결과 확인 명령:**

```bash
docker ps --filter name=lab-ubuntu
docker exec lab-ubuntu echo "Container is running"
```

**재확인:** `docker ps`에서 `Up` 상태를 확인하고 `docker exec` 명령이 실행되는지 확인한다.

종료된 컨테이너는 새로 생성할 필요 없이 기존 컨테이너를 시작한 뒤 접근할 수 있다.

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
![15. 트래블슈터 컨테이너 이름 중복](docs/screenshots/15.%20%ED%8A%B8%EB%9E%98%EB%B8%94%EC%8A%88%ED%84%B0%20%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88%20%EC%9D%B4%EB%A6%84%20%EC%A4%91%EB%B3%B5.PNG)
**결과 확인 명령:**

```bash
docker ps -a --filter name=lab-ubuntu
docker start lab-ubuntu
docker ps --filter name=lab-ubuntu
```

**재확인:** `docker ps -a`에서 기존 이름을 확인하고 `docker start` 후 `Up` 상태를 확인한다.

동일 이름의 컨테이너가 존재할 때는 기존 컨테이너를 재사용하거나 다른 이름을 지정해야 한다.

## 13. 최종 결과

이번 실습을 통해 Linux 기본 명령어와 파일 접근 권한을 관리하는 방법을 익혔다.

Docker 이미지와 컨테이너의 차이를 이해하고, Dockerfile을 이용한 NGINX 이미지 제작과 웹 서버 실행을 수행하였다.

포트 매핑을 통해 두 개의 웹 서버에 접속하고, 바인드 마운트와 볼륨을 이용하여 호스트 파일 공유 및 데이터 영속성을 실습하였다.

마지막으로 Git을 이용하여 프로젝트의 변경 이력을 기록하고 GitHub에 업로드하였다.

**GitHub 저장소:** [Codyssey-A-1](https://github.com/bjw0922/Codyssey-A-1)

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
- [ ] Docker 이미지/컨테이너 차이 및 빌드·변경 과정 설명
- [ ] 네트워크 네임스페이스와 포트 매핑 원리 설명
- [ ] chmod 숫자 권한 계산 설명
- [ ] 포트 충돌 진단 절차 설명
- [ ] bind 경로 선정 및 볼륨 백업·복구 설명
- [ ] 실제 터미널 출력(버전·권한·빌드·HTTP·볼륨·Git) 첨부
