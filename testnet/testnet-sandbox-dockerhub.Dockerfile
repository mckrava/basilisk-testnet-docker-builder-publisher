FROM --platform=$BUILDPLATFORM node:16

ARG VERSION_POLKADOT_NODE
ARG VERSION_BASILISK_NODE

#RUN apt-get update && curl https://getsubstrate.io -sSf | bash -s -- --fast
RUN apt-get update && curl https://sh.rustup.rs -sSf | sh -s -- -y

# ___ Prepare Polkadot project ___

# Download repository source code (instead of git clone)
RUN wget -O polkadot.tar.gz https://github.com/paritytech/polkadot/archive/refs/tags/v$VERSION_POLKADOT_NODE.tar.gz
RUN tar -xvzf polkadot.tar.gz
RUN mv polkadot-$VERSION_POLKADOT_NODE polkadot

WORKDIR /polkadot/target/release

# Download node build binaries
RUN wget https://github.com/paritytech/polkadot/releases/download/v$VERSION_POLKADOT_NODE/polkadot
RUN chmod +x polkadot

WORKDIR /

# ___ Prepare Basilisk-node project ___

# Download repository source code (instead of git clone)
RUN wget -O Basilisk-node.tar.gz https://github.com/galacticcouncil/Basilisk-node/archive/refs/tags/v$VERSION_BASILISK_NODE.tar.gz
RUN tar -xvzf Basilisk-node.tar.gz
RUN mv Basilisk-node-$VERSION_BASILISK_NODE Basilisk-node

WORKDIR /Basilisk-node/target/release

# Download node build binaries
RUN wget https://github.com/galacticcouncil/Basilisk-node/releases/download/v$VERSION_BASILISK_NODE/basilisk
RUN cp basilisk testing-basilisk
RUN chmod +x basilisk
RUN chmod +x testing-basilisk

# Use locally built bins instead of fetching release bin files from the repository. Insert locally built bin file into ./testnet folder.
#COPY ./testnet/basilisk basilisk
#COPY ./testnet/basilisk testing-basilisk
#RUN chmod +x basilisk
#RUN chmod +x testing-basilisk

WORKDIR /

# ___ Prepare Basilisk-api project ___

RUN git clone -b feature/dockerize-testnet https://github.com/galacticcouncil/Basilisk-api.git
#COPY . /Basilisk-api
WORKDIR /Basilisk-api

# Clean up redundant bin files.
#RUN rm testnet/basilisk
RUN yarn install --frozen-lockfile --network-timeout 600000

CMD ["yarn", "run", "testnet:start"]
