#--------- 1. Builder --------
FROM python:3.9-slim AS builder

WORKDIR /build

RUN pip install --no-cache-dir poetry==1.8.3

COPY pyproject.toml poetry.lock* ./
RUN poetry export --without dev --format requirements.txt --output requirements.txt --without-hashes

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

#-------- 2. runtime --------
FROM python:3.9-slim AS runtime

RUN groupadd --system app && useradd --system --gid app --no-create-home app

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app
COPY /app ./app/
COPY alembic.ini ./

USER app

EXPOSE 8000
CMD ["/bin/sh", "-c", "alembic upgrade head && \
    uvicorn app.main:app --host=0.0.0.0 --port=8000"]