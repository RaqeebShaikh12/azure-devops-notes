FROM ubuntu
RUN apt-get update -y && apt-get install curl -y
WORKDIR /app
COPY ./my-troubleshooting-app.sh .
CMD ["./my-troubleshooting-app.sh"]