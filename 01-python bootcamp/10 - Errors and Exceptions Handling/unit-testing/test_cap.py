import unittest
from cap import cap_test # type: ignore
'''Unit tests for the cap_test function from cap module.
'''
class TestCap(unittest.TestCase):
    def test_one_word(self):
        '''Test capitalization of a single word.
        '''
        text = 'python'
        result = cap_test(text)
        self.assertEqual(result, 'Python')
    def test_multiple_words(self):
        '''Test capitalization of multiple words.
        '''
        text = 'hello world'
        result = cap_test(text)
        self.assertEqual(result, 'Hello World')
if __name__ == '__main__':
    unittest.main()