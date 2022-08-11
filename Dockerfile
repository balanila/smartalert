FROM alpine:3.15.5
RUN apk update && apk add --no-cache smartmontools curl sed bash tzdata
ENV TZ=Europe/Chisinau
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

