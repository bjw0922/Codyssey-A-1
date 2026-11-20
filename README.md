<img width="487" height="337" alt="1 환경" src="https://github.com/user-attachments/assets/84c142f2-d70b-4264-93de-950faa360f10" />
# Windows 10 + WSL2 Docker 개발 워크스테이션 구축

> **증거 기록 원칙:** 이 문서는 기존 제출 README를 기반으로 보완한 문서다. `[실제 ...]`로 표시된 부분은 아직 확인하지 못한 출력이므로 반드시 본인의 터미널 결과로 교체한다. 스크린샷은 `docs/screenshots/`에 실제 파일이 있을 때만 링크가 정상 표시된다.

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

### 프로젝트 파일 구조 및 역할 (평가 #10)

```text
workstation-lab/
├── README.md                  # 실행 방법·검증 결과·문제 해결 기록
├── Dockerfile                 # NGINX 커스텀 이미지 빌드 방법
├── .gitignore                 # Git 추적 제외 파일
├── site/
│   ├── index.html             # 포트 8088·8081에서 제공할 웹 페이지
│   └── style.css              # 웹 페이지 디자인
├── bind-site/index.html       # 바인드 마운트 수정 전후 실습
├── linux-practice/           # Linux CLI 및 chmod 실습 파일
└── docs/
    ├── screenshots/           # 실행 화면 증빙 이미지
    └── logs/                  # 터미널 명령 및 텍스트 출력 기록
```

서버 구축 파일과 실습 증거를 분리하여 README에서 결과를 찾기 쉽게 구성하였다. 실제 프로젝트에 존재하지 않는 파일은 최종 제출 전 생성하거나 위 구조에서 제외한다.

### 실습 재현 전제 조건 (평가 #11)

Windows에서 WSL2 Ubuntu와 Docker를 사용할 수 있어야 하며, 모든 프로젝트 명령은 **VS Code의 Ubuntu Bash 터미널**에서 `cd ~/codyssey/workstation-lab`을 실행한 뒤 진행한다. 컨테이너가 이미 존재할 때는 `docker run`을 반복하지 않고 `docker ps -a`로 확인하여 `docker start`를 사용한다.


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
mkdir -p temp-dir
touch temp-dir/delete-me.txt
rm temp-dir/delete-me.txt
rmdir temp-dir
```

**실습 결과**

**./docs/screenshots/1.터미널 기본 조작_1.PNG**

```text
$ pwd
[실제 작업 경로]
$ cat original.txt
[실제 파일 내용]
$ ls -la
[실제 파일 목록]
```

파일 생성(`touch`), 복사(`cp`), 이름 변경(`mv`), 삭제(`rm`/`rmdir`) 명령은 각각 현재 경로의 파일 상태를 바꾼다. `ls -la`와 `cat`으로 최종 상태를 확인한다.

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

### 권한 숫자의 원리 (평가 #15)

Linux 권한은 **소유자(User) / 그룹(Group) / 기타 사용자(Others)** 순서로 표기한다. 읽기 `r=4`, 쓰기 `w=2`, 실행 `x=1`을 더하여 각 자리의 숫자를 만든다. 파일의 `x`는 실행, 디렉터리의 `x`는 내부 경로에 진입·탐색할 수 있는 권한을 의미한다.

| 명령 | 계산 | 결과 문자열의 권한 부분 |
|---|---|---|
| `chmod 600 permission.txt` | 소유자 4+2, 그룹 0, 기타 0 | `rw-------` |
| `chmod 644 permission.txt` | 소유자 4+2, 그룹 4, 기타 4 | `rw-r--r--` |
| `chmod 700 permission-dir` | 소유자 4+2+1, 그룹 0, 기타 0 | `rwx------` |
| `chmod 755 permission-dir` | 소유자 4+2+1, 그룹 4+1, 기타 4+1 | `rwxr-xr-x` |

**실습 결과 — 명령어 및 실제 출력 기록 (평가 #2)**

```text
$ chmod 600 permission.txt && ls -l permission.txt
[실제 ls -l 출력 입력]
$ chmod 700 permission-dir && ls -ld permission-dir
[실제 ls -ld 출력 입력]
$ chmod 644 permission.txt && ls -l permission.txt
[실제 ls -l 출력 입력]
$ chmod 755 permission-dir && ls -ld permission-dir
[실제 ls -ld 출력 입력]
```

위 권한 문자열은 기대값이며, 소유자·날짜·크기 등 실제 출력은 사용자 환경에서 확인해 기록한다.

![권한 변경 전](docs/screenshots/02-permission-before.png)

![권한 변경 후](docs/screenshots/03-permission-after.png)

## 5. Docker 설치 및 실행 상태 확인

```bash
docker --version
docker info
```

**실습 결과**

`docker --version`은 CLI 설치 여부를, `docker info`의 `Server`는 엔진(데몬) 연결 여부를 확인한다. CLI가 설치되어 있더라도 서버에 연결되지 않으면 컨테이너를 실행할 수 없다.

```text
$ docker --version
[실제 Docker 버전 출력]
$ docker info --format 'Server Version: {{.ServerVersion}}'
[실제 Docker Server 버전 출력]
```

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

```text
$ docker logs lab-hello
[실제 출력 중 'Hello from Docker!'가 포함된 부분]
$ docker images
[실제 이미지 목록]
$ docker ps -a
[실제 컨테이너 목록 및 Exited / Up 상태]
$ docker stats --no-stream
[실제 CPU·메모리 출력]
```

**Ubuntu 컨테이너 내부 실습:** `docker exec -it lab-ubuntu bash` 후 `pwd`, `ls -la`, `echo "Hello from Docker Ubuntu"`를 입력하고 결과를 기록한다.

```text
[Ubuntu 컨테이너 내부 프롬프트 및 pwd / ls / echo 출력]
```

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

`FROM`은 기반 이미지, `COPY`는 HTML/CSS를 이미지 안으로 복사하는 명령, `EXPOSE 80`은 사용 포트를 문서화하는 메타데이터이다. `EXPOSE`만으로 호스트 포트가 열리지는 않는다.

**검증 순서:** (1) `site/` 파일 확인 → (2) `docker build` 성공 → (3) `docker images`에서 `lab-nginx:1.0` 확인 → (4) 다음 절에서 컨테이너 실행.

```text
$ docker build --progress=plain -t lab-nginx:1.0 .
[실제 빌드 종료 단계 및 성공 로그]
$ docker images
[실제 lab-nginx:1.0 이미지 행]
```

전체 빌드 로그가 길면 `docs/logs/docker-build.txt`에 저장하고 여기에는 핵심 성공 출력만 인용한다.

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

```text
$ curl -i http://localhost:8088
[실제 HTTP 상태 줄·Server 헤더·HTML 본문 일부]
$ curl -i http://localhost:8081
[실제 HTTP 상태 줄·Server 헤더·HTML 본문 일부]
$ docker ps
[실제 두 컨테이너의 Up 상태 및 8088/8081 매핑 행]
```

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

### 경로 선정 이유 (평가 #14)

`$(pwd)`는 현재 작업 폴더의 **절대 경로**를 반환하므로, 반드시 프로젝트 루트에서 실행하면 `bind-site`의 위치를 명확히 지정할 수 있다. `source`는 호스트 Ubuntu의 실제 파일 폴더, `target`은 NGINX가 정적 파일을 읽는 컨테이너 경로이다. 이 경로를 정확하게 사용하고 파일 읽기 권한을 확보해야 설정을 재현할 수 있다. 바인드 마운트는 컨테이너 이미지의 대상 경로에 원래 있던 파일을 가려 보이게 할 수 있으므로 주의한다.

**검증 순서:** (1) 변경 전 `curl`/브라우저 캡처 → (2) `bind-site/index.html` 수정 및 저장 → (3) **재빌드·재시작 없이** 동일 주소 요청 → (4) `docker inspect lab-bind --format '{{json .Mounts}}'`로 연결 경로 확인.


**실습 결과**

```text
$ curl http://localhost:8089  # HTML 수정 전
[실제 BEFORE 문구가 들어간 HTML 출력]
$ curl http://localhost:8089  # HTML 수정 후
[실제 AFTER 문구가 들어간 HTML 출력]
$ docker inspect lab-bind --format '{{json .Mounts}}'
[실제 Type=bind, Source, Destination이 담긴 JSON]
```

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

**백업·복구 실행 결과:** [실제 `tar` 파일 생성 여부와 파일 내용 확인 후 입력]

**볼륨 삭제 전후의 텍스트 증거 (평가 #8)**

```text
$ docker exec lab-volume1 cat /data/result.txt
[삭제 전 실제 파일 내용]
$ docker rm -f lab-volume1
[실제 컨테이너 삭제 출력]
$ docker exec lab-volume2 cat /data/result.txt
[새 컨테이너에서 확인한 실제 파일 내용]
```


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

git remote add origin https://github.com/본인계정/workstation-lab.git
git push -u origin main
```

**실습 결과**

```text
$ git config --list
[실제 user.name, user.email(공개 가능 여부 확인), init.defaultbranch 설정]
$ git log -1 --oneline
[실제 커밋 해시 및 메시지]
$ git remote -v
[실제 GitHub 원격 주소]
$ git push
[실제 push 성공 시 출력 또는 Everything up-to-date]
```

**주의:** 이미 `origin`이 등록되어 있으면 `git remote add origin`을 반복하지 않는다. README를 수정해 다시 올릴 때는 `git add README.md docs/`, `git commit -m "docs: improve README evidence"`, `git push` 순으로 진행한다. Push 성공 여부는 GitHub 웹 화면과 `git status`, `git log -1`, `git ls-remote --heads origin main`으로 교차 확인한다.

![Git 설정](docs/screenshots/17-git-config.png)

![Git 커밋](docs/screenshots/18-git-commit.png)

![GitHub](docs/screenshots/19-github.png)

## 12. 트러블슈팅

아래 두 유형은 **이전 개발환경 실습에서도 직접 경험한 문제**이며, 현재 `lab-ubuntu` 기준으로 다시 검증할 수 있다. 오류 발생 로그와 해결 후의 실제 출력은 구분하여 기록한다.

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

**결과 확인 명령:**

```bash
docker ps --filter name=lab-ubuntu
docker exec lab-ubuntu echo "Container is running"
```

**재검증 출력:** [실제로 출력된 `Up` 상태와 `Container is running` 메시지를 기록]

이전 과제에서는 같은 유형의 오류가 실제로 발생했고, 새 `lab-ubuntu`에서의 결과는 재검증 후 기입한다.

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

**결과 확인 명령:**

```bash
docker ps -a --filter name=lab-ubuntu
docker start lab-ubuntu
docker ps --filter name=lab-ubuntu
```

**재검증 출력:** [실제로 출력된 컨테이너 이름과 `Up` 상태 입력]

이전 과제에서 같은 유형의 이름 충돌 오류가 실제로 발생했고, 새 컨테이너에서의 결과는 재검증 후 기입한다.

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
- [ ] Docker 이미지/컨테이너 차이 및 빌드·변경 과정 설명
- [ ] 네트워크 네임스페이스와 포트 매핑 원리 설명
- [ ] chmod 숫자 권한 계산 설명
- [ ] 포트 충돌 진단 절차 설명
- [ ] bind 경로 선정 및 볼륨 백업·복구 설명
- [ ] 실제 터미널 출력(버전·권한·빌드·HTTP·볼륨·Git) 첨부
