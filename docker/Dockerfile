ARG JAVA_VERSION=17
FROM mcr.microsoft.com/azure-functions/java:4-java$JAVA_VERSION-appservice

COPY ./app/ /home/site/wwwroot

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true
