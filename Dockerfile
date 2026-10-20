FROM nginx:alpine

LABEL maintainer="Gondal Digital Agency"
LABEL project="Dockerized Web Application"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
