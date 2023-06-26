FROM alpine:3.17

RUN apk add curl gcc git musl-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal --no-modify-path -y

RUN git clone https://github.com/abatkin/route53-utils.git && source ~/.cargo/env && cd route53-utils && cargo build --release

RUN git clone https://github.com/abatkin/routeros-utils.git && source ~/.cargo/env && cd routeros-utils && cargo build --release

FROM alpine:3.17

COPY --from=0 routeros-utils/target/release/routeros-utils route53-utils/target/release/route53-util /usr/bin/

COPY dyndns.sh /usr/bin/dyndns.sh

ENTRYPOINT ["/usr/bin/dyndns.sh"]


