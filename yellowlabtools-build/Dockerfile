#ddev-generated
FROM ousamabenyounes/yellowlabtools:latest

USER root

# Install yellowlabtools CLI globally with same Puppeteer config as base image
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN npm install -g yellowlabtools --network-timeout=300000

USER nobody

# Keep server running (default behavior)
CMD ["node", "bin/server.js"]
