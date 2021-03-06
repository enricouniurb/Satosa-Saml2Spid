FROM alpine:3.12.3
MAINTAINER Giuseppe De Marco <demarcog83@gmail.com>

RUN apk update
RUN apk add libffi-dev libressl-dev python3 py3-pip python3-dev procps git openssl build-base gcc wget bash 
RUN apk add build-base libressl libffi-dev libressl-dev libxslt-dev libxml2-dev xmlsec-dev xmlsec

ENV BASEDIR='/satosa_proxy'

WORKDIR $BASEDIR/
COPY requirements.txt $BASEDIR/
RUN pip3 install -r requirements.txt --ignore-installed
RUN cd ..
COPY example/ $BASEDIR/

# demo certificates
RUN mkdir $BASEDIR/pki/
COPY oids.conf $BASEDIR/pki/
COPY build_spid_certs.sh $BASEDIR/pki/
WORKDIR $BASEDIR/pki/
RUN chmod +x $BASEDIR/pki/build_spid_certs.sh

COPY example/plugins/microservices/processors/legacy_processor.py /usr/lib/python3.8/site-packages/satosa/micro_services/processors

ENV COMMON_NAME="SPID example proxy"
ENV LOCALITY_NAME="Roma"
ENV ORGANIZATION_IDENTIFIER="PA:IT-c_h501"
ENV ORGANIZATION_NAME="SPID example proxy"
ENV SERIAL_NUMBER="1234567890"
ENV SPID_SECTOR="public"
ENV URI="https://spid.proxy.example.org"
ENV DAYS="7300"

RUN echo $(cd $BASEDIR/pki/ && ls -la)
RUN $BASEDIR/pki/build_spid_certs.sh

WORKDIR $BASEDIR/

# Metadata
RUN mkdir -p metadata/idp
RUN mkdir -p metadata/sp

# COPY Metadata 
ARG SP_METADATA_URL
ARG IDP_METADATA_URL
RUN wget $SP_METADATA_URL -O metadata/sp/my-sp.xml --no-check-certificate
RUN wget $IDP_METADATA_URL -O metadata/idp/my-idp.xml --no-check-certificate
RUN wget https://registry.spid.gov.it/metadata/idp/spid-entities-idps.xml -O metadata/idp/spid-entities-idps.xml

RUN adduser --disabled-password wert 
RUN chown -R  wert .

COPY demo-run.sh .



