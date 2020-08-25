FROM haskell:8

WORKDIR /app

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

CMD ["heed"]