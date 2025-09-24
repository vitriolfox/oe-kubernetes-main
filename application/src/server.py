# server.py

from flask import Flask, jsonify
import database


app = Flask(__name__)


@app.route('/book', methods=['GET'])
def get_books():
    books = database.book_database
    return jsonify(books)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
