FROM python:3.8-alpine as dict-build

RUN mkdir -p /tmp/dict-build/artifacts
WORKDIR /tmp/dict-build

RUN apk add alpine-sdk git && \
    git clone https://github.com/BoboTiG/ebook-reader-dict && \
    pip install --no-cache-dir -r ebook-reader-dict/requirements.txt

WORKDIR /tmp/dict-build/ebook-reader-dict

RUN python -m scripts --locale sv

WORKDIR /tmp/dict-build/ebook-reader-dict

FROM alpine:latest 

#RUN mkdir -p /tmp/artifacts
COPY --from=dict-build /tmp/dict-build/ebook-reader-dict/data/sv/dicthtml-sv.zip /tmp/
CMD [ "cp", "/tmp/dicthtml-sv.zip", "/tmp/artifacts/" ]
