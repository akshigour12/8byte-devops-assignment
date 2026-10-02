from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return {
        "application": "8byte-devops-assignment",
        "status": "running",
        "environment": "staging"
    }


@app.route("/health")
def health():
    return {
        "status": "healthy"
    }
