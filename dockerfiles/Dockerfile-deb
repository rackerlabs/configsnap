FROM debian:latest
RUN apt update \
    && apt install -y python devscripts build-essential gawk help2man \
    && groupadd -g 1004 builduser \
    && useradd -m -u 1003 -g builduser builduser

USER builduser
RUN mkdir /home/builduser/configsnap
WORKDIR /home/builduser/configsnap
CMD ["make","deb"]
