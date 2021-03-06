FROM haskell:8

WORKDIR /app

RUN apt update
RUN apt install sqlite3


COPY heed.cabal .
COPY stack.yaml .
COPY Setup.hs .
COPY LICENSE .

RUN stack setup
RUN stack install --only-dependencies

ADD src ./src
ADD sql ./sql

RUN stack install

VOLUME /db

RUN sqlite3 /db/heed.db ".read sql/feeds.sql"
RUN sqlite3 /db/heed.db ".read sql/items.sql"
RUN sqlite3 /db/heed.db ".read sql/settings.sql"


CMD ["heed"]