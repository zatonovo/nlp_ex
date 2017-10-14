FROM zatonovo/numpy:3.5

RUN python -m nltk.downloader treebank stopwords wordnet brown punkt hmm_treebank_pos_tagger

WORKDIR /code
CMD ["python"]
