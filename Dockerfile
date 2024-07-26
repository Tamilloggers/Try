# Base image
FROM docker:latest

# Set environment variables
ENV GitHubMail=tamilloggers@gmail.com
ENV GitHubName=Tamilloggers
ENV Branch=master
ENV GH_TOKEN=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
ENV REPO=Tamilloggers/hero

# Install necessary packages
RUN apk update && apk add --no-cache \
    git \
    curl

# Set Git configs
RUN git config --global user.email $GitHubMail \
    && git config --global user.name $GitHubName \
    && git config --global credential.helper store

# Set up Git credentials
RUN echo "https://${GitHubName}:${GH_TOKEN}@github.com" > ~/.git-credentials

# Clone the secret repository
RUN git clone https://${GH_TOKEN}@github.com/${REPO} -b $Branch source

# Compile the mirroring Docker container
WORKDIR /source
RUN docker container prune --force || true \
    && docker build . --rm --force-rm --compress --no-cache=true --pull --file Dockerfile -t renamer-bot \
    && docker image ls

# Run the Docker container with a timeout of 325 minutes
CMD ["sh", "-c", "docker run --env CONFIG_FILE_URL=${CONFIG_FILE_URL} renamer-bot"]

# Add a health check to monitor the container
HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost/ || exit 1
