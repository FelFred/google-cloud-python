"""A setup module for the GAPIC Stackdriver Trace API library.

See:
https://packaging.python.org/en/latest/distributing.html
https://github.com/pypa/sampleproject
"""

from setuptools import setup, find_packages

install_requires = [
    'google-cloud-core[grpc] >= 0.28.0, < 0.29dev',
    'google-api-core >= 0.1.1, < 0.2.0dev',
    'google-gax >= 0.15.7, < 0.16dev',
]

setup(
    name='google-cloud-trace',
    version='0.16.1.dev1',
    author='Google Inc',
    author_email='googleapis-packages@google.com',
    classifiers=[
        'Intended Audience :: Developers',
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
    description='GAPIC library for the Stackdriver Trace API',
    include_package_data=True,
    long_description=open('README.rst').read(),
    install_requires=install_requires,
    license='Apache-2.0',
    packages=find_packages(),
    namespace_packages=[
        'google',
        'google.cloud',
        'google.cloud.gapic',
        'google.cloud.gapic.trace',
        'google.cloud.proto',
        'google.cloud.proto.devtools',
        'google.cloud.proto.devtools.cloudtrace',
    ],
    url='https://github.com/googleapis/googleapis')
