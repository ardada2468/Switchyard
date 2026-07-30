from app import greet


def test_greet_says_hello():
    assert greet() == "hello"
