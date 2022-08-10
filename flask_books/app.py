import logging
import os

import boto3
from flask import Flask, render_template, request, jsonify
from services import BookService

app = Flask(__name__)
book_service = BookService()

@app.route('/')
def render_index():
    return render_template("index.html")

@app.route('/api/books', methods=['GET', 'POST'])
def render_books():
    methods = {
        'GET': book_service.list,
        'POST': book_service.add
        }
    return methods[request.method]()

@app.route('/api/books/<book_id>', methods=['GET', 'POST', 'DELETE'])
def render_book(book_id: str):
    methods = {
        'GET': book_service.get,
        'POST': book_service.update,
        'DELETE': book_service.delete,
        }
    return methods[request.method](book_id)

@app.route('/health')
def render_health():
    return "OK"

@app.errorhandler(Exception)
def error_handler_server_error(e):
  """Handle internal server errors
  """
  app.logger.error(e, exc_info=True)
  return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    """Start the Flask application.
    """
    port = int(os.environ.get("PORT", 5000))
    debug = bool(os.environ.get("DEBUG", False))
    if debug:
        logging.getLogger().setLevel(logging.DEBUG)
    app.run(debug=debug, host='0.0.0.0', port=port)
