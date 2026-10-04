import os
from datetime import datetime
from pathlib import Path

from flask import Flask, redirect

app = Flask(__name__)
PORT = int(os.getenv("APP_PORT", "8080"))

PATHS = {
    "container": Path("/container/message.txt"),
    "volume": Path("/volume/message.txt"),
    "bind": Path("/bind/message.txt"),
}


def read(name):
    path = PATHS[name]
    if not path.exists():
        return "(empty)"
    return path.read_text().strip()


def write(name):
    path = PATHS[name]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f"Updated at {datetime.now():%H:%M:%S}\n")


@app.get("/")
def home():
    rows = ""
    for name, path in PATHS.items():
        rows += f"""
        <tr>
          <td>{name}</td>
          <td><code>{path}</code></td>
          <td>{read(name)}</td>
          <td><a href="/write/{name}">write</a></td>
        </tr>
        """
    return f"""
    <h1>Docker Persistence</h1>
    <table border="1" cellpadding="8">
      <tr><th>type</th><th>path</th><th>message</th><th></th></tr>
      {rows}
    </table>
    <p>
      Write to all three → remove &amp; recreate the container →
      container is lost, volume and bind survive.
    </p>
    """


@app.get("/write/<name>")
def write_route(name):
    if name not in PATHS:
        return "unknown", 404
    write(name)
    return redirect("/")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
