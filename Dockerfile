FROM python:3.10-slim

RUN python -m pip install --upgrade pip

# Create a non-privileged user for extra security. Install the requirements. Create an /app/ directory.
RUN useradd sapio -u 1000 -s /bin/sh && mkdir -p /app


ADD requirements.txt .
RUN pip install -r requirements.txt

ADD . /app/
USER sapio
WORKDIR /app


# Open 8080 and run the server.
EXPOSE 8080
# ENTRYPOINT python server.py
ENTRYPOINT gunicorn server:app