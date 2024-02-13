FROM python:3.10-slim

RUN python -m pip install --upgrade pip

# Create a non-privileged user for extra security. Install the requirements. Create an /app/ directory.
RUN useradd sapio -u 1000 -s /bin/sh && mkdir -p /app


ADD requirements.txt .
RUN pip install -r requirements.txt

ADD . /app/
USER sapio
WORKDIR /app

# This is specific to waitress. Not gunicorn. If this is set to True the server hot-reload your code when it changes.
ENV SapioWebhooksDebug=False

# When set to True, the server will not verify the SSL certificate of the webhook server. This is useful for doing local development.
ENV SapioWebhooksInsecure=False


# Open 8080 and run the server.
EXPOSE 8080
# ENTRYPOINT python server.py
ENTRYPOINT gunicorn server:app