# Pull base image.
FROM dockerfile/python

# Set instructions on build.
RUN virtualenv /env
ADD requirements.txt /app/
RUN /env/bin/pip install -r /app/requirements.txt
ADD . /app/

# Define working directory.
WORKDIR /app

# Define default command.
CMD ["/env/bin/python", "/app/core.py"]

# Expose ports.
EXPOSE 8000



