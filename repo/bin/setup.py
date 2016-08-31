from setuptools import setup, find_packages
import os
import sys
from codecs import open

here = os.path.abspath(os.path.dirname(__file__))

#with open(os.path.join(here, 'DESCRIPTION.rst'), encoding='utf-8') as f:
#    long_description = f.read()

#with open(os.path.join(here, 'VERSION.txt'), encoding='utf-8') as f:
#    version = f.read()

setup(name="gtron",
      version="1.0.0",
      long_description="Tools for building and maintaining Gadgetron",
      author="NVSL, University of California San Diego",
      py_modules=['gtron'],
      #install_requires=['webapp2', 'wsgiref', 'httplib2', 'google-api-python-client']
      entry_points={
          'console_scripts': [
              'gtron = gtron:main'
          ]
      }
      )
