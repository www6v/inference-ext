"""Test vllm_benchmark module."""

import unittest

from vllm_benchmark import __version__


class TestVersion(unittest.TestCase):
    """Test version string."""

    def test_version_exists(self):
        """Version should be defined."""
        self.assertIsNotNone(__version__)
        self.assertIsInstance(__version__, str)


if __name__ == "__main__":
    unittest.main()
