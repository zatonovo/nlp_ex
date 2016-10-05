FROM python:3.6

RUN apt-get update && apt-get install -y liblapack-dev libatlas-base-dev gfortran
RUN pip install nltk numpy scipy scikit-learn python-crfsuite spacy
RUN python -m nltk.downloader treebank stopwords wordnet brown punkt hmm_treebank_pos_tagger
RUN python -m spacy.en.download --force all

WORKDIR /code
CMD ["python"]
