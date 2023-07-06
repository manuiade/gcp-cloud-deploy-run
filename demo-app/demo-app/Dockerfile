FROM golang:1.19 AS builder
WORKDIR /go/src/demo
COPY . .
RUN CGO_ENABLED=0 go build -o /go/bin/demo

FROM gcr.io/distroless/static-debian11
COPY --from=builder /go/bin/demo /
CMD ["/demo"]
