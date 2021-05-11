from flask import Flask, redirect, url_for,render_template, request


app = Flask(__name__)


@app.route("/")
def admin():
	return render_template("index.html")

if __name__ == '__main__':
    app.run(host ='0.0.0.0', port = 8000,debug=True )