FROM archlinux/base:latest
FROM elixir:1.9.1 as build
# FROM node:10.16.1

COPY . .

#packman setup
RUN pacman -Syyu --noconfirm
RUN pacman-db-upgrade
RUN pacman -S --noconfirm nodejs wkhtmltopdf
#command to build & release app 
RUN export MIX_ENV=prod && \
    npm i puppeteer-pdf -g \
    rm -Rf _build && \
    mix drinkly.setup && \
    mix release drinkly_linux


#================
#Deployment Stage
#================
FROM pentacent/alpine-erlang-base:latest

#Set environment variables and expose port
EXPOSE 8080
EXPOSE 4000

ENV REPLACE_OS_VARS=true \
    PORT=4000

#Change user
USER default

#command to run our application
CMD drinkly_releases/bin/drinkly_linux start
