# Stage 1: Build the binary
FROM golang:1.23 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the entire source code
COPY . .

# Build the Go binary by specifying the correct package path and ensuring static linking
RUN CGO_ENABLED=0 go build -o postgres_exporter ./cmd/postgres_exporter

# Stage 2: Create the final image using Alpine as an example
FROM alpine:3.18

LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"

# Install necessary dependencies (if any)
# For most Go binaries with CGO disabled, this may not be necessary

# Copy the compiled binary from the builder stage
COPY --from=builder /app/postgres_exporter /bin/postgres_exporter

# Ensure the binary has execute permissions
RUN chmod +x /bin/postgres_exporter

# Expose the required port
EXPOSE 9187

# Set the user to nobody for security
USER nobody

# Define the entrypoint
ENTRYPOINT [ "/bin/postgres_exporter" ]
