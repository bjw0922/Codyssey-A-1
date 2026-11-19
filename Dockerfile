FROM nginx:1.27-alpine

LABEL description="WSL2 Docker workstation assignment"

COPY site/ /usr/share/nginx/html/

EXPOSE 80