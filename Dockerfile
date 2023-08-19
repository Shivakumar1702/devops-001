FROM httpd:latest
LABEL maintainer="shiva"
WORKDIR /usr/local/apache2/htdocs/
COPY ./index.html ./
EXPOSE 80