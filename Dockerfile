FROM python:3.10-slim as build

#install curl 
RUN apt-get update \
    && apt-get install -y \
         curl \
         build-essential \
         libffi-dev \
    && rm -rf /var/lib/apt/lists/*

#instal poetry 
ENV POETRY_VERSION=1.6.1
ENV POETRY_HOME=/etc/poetry 
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH=${POETRY_HOME}/bin:${PATH}

#create virtual envioment and install dependencies in pyproject.toml 
WORKDIR /app 
COPY mlapi/pyproject.toml mlapi/poetry.lock ./
RUN python -m venv --copies /app/venv 
RUN . /app/venv/bin/activate && poetry install 


FROM python:3.10-slim as deploy 

# #install curl so we can do healthcheck 
# RUN apt-get update \
#     && apt-get install -y \
#          curl \
#     && rm -rf /var/lib/apt/lists/*

WORKDIR /app 
COPY --from=build /app/venv /app/venv
ENV PATH=/app/venv/bin:${PATH}
COPY . ./


# run uvicorn 
CMD ["uvicorn", "mlapi.src.main:app", "--host", "0.0.0.0", "--port", "8000"]


