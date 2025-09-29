FROM python:3.10-slim AS base

# ---------

FROM base AS deps

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

# ---------

FROM base AS runner
WORKDIR /app

COPY --from=deps /opt/venv /opt/venv

COPY src/ ./src

ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 3333

ENV PORT=3333
ENV FLASK_APP=src/main.py
ENV hostname="0.0.0.0"

CMD [ "opentelemetry-instrument", "python", "-m", "src.main" ]