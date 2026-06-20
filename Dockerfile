# Base OS image - Ubuntu has cowsay/fortune/netcat-openbsd readily available via apt
FROM ubuntu:22.04

# Prevents apt from pausing for interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install exactly what wisecow.sh needs:
# - cowsay, fortune-mod  -> the actual "wisdom" generators (engines)
# - fortunes-min         -> the actual quote/text database fortune-mod reads from
# - netcat-openbsd       -> provides nc WITH the -N flag the script uses
# - bash                 -> script's shebang requires bash, not just sh
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cowsay \
        fortune-mod \
        fortunes-min \
        netcat-openbsd \
        bash && \
    rm -rf /var/lib/apt/lists/*

# On Debian/Ubuntu, cowsay & fortune binaries live in /usr/games,
# which isn't on PATH by default for non-login shells - fix that
ENV PATH="/usr/games:${PATH}"

# Working directory inside the container
WORKDIR /app

# Copy the script from your repo into the image
COPY wisecow.sh .

# Strip Windows-style CRLF line endings that break the #!/bin/bash shebang
RUN sed -i 's/\r$//' wisecow.sh

# Make sure it's executable
RUN chmod +x wisecow.sh

# Documents which port the app listens on
EXPOSE 4499

# Container's main process: run the script
CMD ["./wisecow.sh"]
