FROM --platform=linux/x86-64 node:18

RUN apt-get update -qq -y && \
    apt-get install -y \
        libasound2 \
        libatk-bridge2.0-0 \
        libgtk-4-1 \
        libnss3 \
        xdg-utils \
        wget && \
    wget -q -O chrome-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/121.0.6167.85/linux64/chrome-linux64.zip && \
    unzip chrome-linux64.zip && \
    rm chrome-linux64.zip && \
    mv chrome-linux64 /opt/chrome/ && \
    ln -s /opt/chrome/chrome /usr/local/bin/ && \
    wget -q -O chromedriver-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/121.0.6167.85/linux64/chromedriver-linux64.zip && \
    unzip -j chromedriver-linux64.zip chromedriver-linux64/chromedriver && \
    rm chromedriver-linux64.zip && \
    mv chromedriver /usr/local/bin/

WORKDIR /usr/src/app
COPY package*.json .
COPY .env .

ENV CHROMEDRIVER_SKIP_DOWNLOAD=true

# RUN npm install --omit=dev
RUN npm install
RUN npm install chromedriver

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]