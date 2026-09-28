import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)

APP_PORT = int(os.getenv("APP_PORT", "3000"))
APP_ENV = os.getenv("APP_ENV", "development")


@app.route("/")
def home():
    return "Docker App is running\n"


@app.route("/health")
def health():
    return jsonify(status="healthy")


@app.route("/info")
def info():
    return jsonify(
        hostname=socket.gethostname(),
        environment=APP_ENV
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=APP_PORT)