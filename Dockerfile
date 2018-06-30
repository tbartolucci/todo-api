FROM microsoft/aspnetcore-build:2.0 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY ./src .
RUN dotnet restore TodoApi.sln && \
	dotnet test ./TodoApi.Tests

# Copy everything else and build
RUN dotnet publish ./TodoApi/TodoApi.csproj -c Release -o /app/out -r linux-x64

# Build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .

ENV ASPNETCORE_URLS http://+:5000

RUN apt update -y && \
	apt install -y nginx

RUN rm /etc/nginx/nginx.conf
COPY ./src/nginx.conf /etc/nginx

RUN mkdir -p /etc/nginx/conf.d/certs && \
	openssl req -x509 -newkey rsa:2048 \
	-keyout /etc/nginx/conf.d/certs/server.key \
	-out /etc/nginx/conf.d/certs/server.cer \
	-days 1460 -nodes -subj "/C=US/ST=New Jersey/L=Westfield/O=BitsByBit/CN=bitsbybit.com"

RUN mkdir -p /static
COPY ./src/revision.txt /static/
COPY ./src/start.py /

RUN apt update -y && \
	apt install -y dos2unix python3 python3-pip jq && \
	pip3 install requests boto3 awscli --upgrade && \
	dos2unix /start.py

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# to see stdout from python in docker logs
ENV PYTHONUNBUFFERED=1

EXPOSE 443

ENTRYPOINT ["python3", "/start.py"]