FROM python:3.6

RUN apt-get update && apt-get install -y liblapack-dev libatlas-base-dev gfortran
RUN pip install nltk numpy scipy scikit-learn python-crfsuite
RUN python -m nltk.downloader brown

WORKDIR /code
CMD ["python"]
