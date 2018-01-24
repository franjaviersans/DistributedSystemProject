FROM python:3

ENV MAIN_APP_FILE client.py

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt


ENTRYPOINT ["python", $MAIN_APP_FILE]

