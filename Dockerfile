FROM haskell:8

WORKDIR /app

RUN apt update
RUN apt install sqlite3

RUN stack setup

COPY heed.cabal .
COPY stack.yaml .
COPY Setup.hs .
COPY LICENSE .
COPY README.md .

RUN stack install --only-dependencies

ADD src ./src
ADD sql ./sql

RUN stack install

VOLUME /db

RUN sqlite3 /db/heed.db ".read sql/feeds.sql"
RUN sqlite3 /db/heed.db ".read sql/items.sql"


CMD ["heed"]