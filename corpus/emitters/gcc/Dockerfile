FROM gcc:15.3.0
RUN apt-get update && apt-get install -y --no-install-recommends lcov python3-pip \
 && pip3 install --break-system-packages gcovr==8.8 \
 && rm -rf /var/lib/apt/lists/*
