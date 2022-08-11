import unittest
from .BookService import BookService

class BookServiceTest(unittest.TestCase):

    def setUp(self):
        self.book_service = BookService()

    def test_list(self):
        self.assertTrue(len(self.book_service.list()) == 0)
    
    def test_add(self):
        self.assertTrue(self.book_service.add({}) == {})

    def test_get(self):
        self.assertTrue(self.book_service.get("id1")["book_id"] == "id1")

    def test_update(self):
        self.assertTrue(self.book_service.update("id1")["book_id"] == "id1")

    def test_delete(self):
        self.assertTrue(self.book_service.delete("id1")["book_id"] == "id1")
  
if __name__ == '__main__':
    unittest.main()