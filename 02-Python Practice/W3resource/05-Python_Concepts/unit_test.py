# Import the 'unittest' module for writing unit tests.
import unittest
# Define a function 'is_palindrome' to check if a string is a palindrome.
def is_palindrome(string):
    return string == string[::-1]
# Define a test case class 'TestPalindrome' that inherits from 'unittest.TestCase'.
class TestPalindrome(unittest.TestCase):
    # Define a test method 'test_palindrome_string' to test palindrome strings.
    def test_palindrome_string(self):
        # Define a string 'palindrome' for testing palindrome or non-palindrome strings.
        #palindrome = "madam"
        palindrome = "hello"
        print("Test palindrome:", palindrome)
        # Assert that the string is a palindrome.
        self.assertTrue(is_palindrome(palindrome), "The string is not a palindrome")

    # Define a test method 'test_non_palindrome_string' to test non-palindrome strings.
    def test_non_palindrome_string(self):
        # Define a string 'non_palindrome' for testing palindrome or non-palindrome strings.
        #non_palindrome = "hello"
        non_palindrome = "madam"
        print("Test non palindrome:", non_palindrome)
        # Assert that the string is not a palindrome.
        self.assertFalse(is_palindrome(non_palindrome), "The string is a palindrome")

# Check if the script is run as the main program.
if __name__ == '__main__':
    # Run the test cases using 'unittest.main()'.
    unittest.main()
