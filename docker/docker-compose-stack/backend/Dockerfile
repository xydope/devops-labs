FROM python:3.14.7-slim

WORKDIR /app

ENV APP_ENV=development \
    APP_PORT=3000

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app/ .

RUN useradd --create-home appuser

USER appuser

CMD ["python", "app.py"]