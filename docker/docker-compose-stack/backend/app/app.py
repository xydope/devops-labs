import os
import socket

import psycopg
from flask import Flask, jsonify

app = Flask(__name__)

APP_PORT = int(os.getenv("APP_PORT", "3000"))
APP_ENV = os.getenv("APP_ENV", "development")
DB_HOST = os.getenv("DB_HOST", "db")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "app")
DB_USER = os.getenv("DB_USER", "app")
DB_PASSWORD = os.getenv("DB_PASSWORD")


@app.route("/")
def home():
    return "Docker App is running\n"


@app.route("/health")
def health():
    return jsonify(status="healthy")


@app.route("/info")
def info():
    try:
         with psycopg.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
        ) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                database_check = cursor.fetchone()[0]
    except psycopg.Error as error:
        return jsonify(
            hostname=socket.gethostname(),
            environment=APP_ENV,
            database="unavailable",
            error=str(error),
        ), 503

    return jsonify(
        hostname=socket.gethostname(),
        environment=APP_ENV,
        database="connected",
        database_check=database_check,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=APP_PORT)
