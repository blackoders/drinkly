FROM archlinux/base:latest
FROM elixir:latest

RUN mkdir drinkly
WORKDIR drinkly
# FROM node:10.16.1

#packman setup
# RUN ./pacman -Syyu --noconfirm
# RUN ./pacman-db-upgrade
# RUN ./pacman -S --noconfirm nodejs wkhtmltopdf
#command to build & release app 

COPY ./mix.exs /drinkly/mix.exs
COPY ./mix.lock /drinkly/mix.lock


RUN mix local.hex
RUN mix deps.get

COPY ./ /drinkly

ENV PORT 4000
ENV MIX_ENV prod

EXPOSE 4000

RUN mix compile
RUN mix drinkly.setup
RUN mix release drinkly_linux
#
#
#
#
# #================
# #Deployment Stage
# #================
# FROM pentacent/alpine-erlang-base:latest
#
# #Set environment variables and expose port
# EXPOSE 8080
# EXPOSE 4000
#
# ENV REPLACE_OS_VARS=true \
#     PORT=4000
#
# #Change user
# USER default

#command to run our application
CMD drinkly_releases/bin/drinkly_linux start
