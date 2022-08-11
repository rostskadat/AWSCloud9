class BookService(object):
    
    def __init__(self):
        """Initiliaze the BookService"""
        return
    
    def list(self):
        return []

    def add(self, book: any):
        return book

    def get(self, book_id: str):
        return {"book_id": book_id}

    def update(self, book_id: str):
        return {"book_id": book_id}
        
    def delete(self, book_id: str):
        return {"book_id": book_id}
        