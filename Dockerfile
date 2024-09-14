# # syntax=docker/dockerfile:1


# FROM golang:1.23.1

# # Set destination for COPY
# WORKDIR /app

# # Download Go modules
# COPY go.mod go.sum ./
# RUN go mod download

# # Copy the source code. Note the slash at the end, as explained in
# # https://docs.docker.com/reference/dockerfile/#copy
# COPY . ./

# # Build
# RUN CGO_ENABLED=0 GOOS=linux go build -o /go-chat
# # Optional:
# # To bind to a TCP port, runtime parameters must be supplied to the docker command.
# # But we can document in the Dockerfile what ports
# # the application is going to listen on by default.
# # https://docs.docker.com/reference/dockerfile/#expose
# EXPOSE 3000

# # Run
# CMD ["/go-chat"]

# Build the application from source
FROM golang:1.23.1 AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . ./

RUN CGO_ENABLED=0 GOOS=linux go build -v -o /go-chat

# Deploy the application binary into a lean image
FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /app

COPY --from=build-stage /app/views /app/views
COPY --from=build-stage /app/static /app/static
COPY --from=build-stage /go-chat ./go-chat

EXPOSE 3000

#USER nonroot:nonroot

ENTRYPOINT ["/app/go-chat"]
