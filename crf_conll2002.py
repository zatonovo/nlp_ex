# Taken from
# https://github.com/tpeng/python-crfsuite/blob/master/examples/CoNLL%202002.ipynb
from itertools import chain
import nltk
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.preprocessing import LabelBinarizer
import sklearn
import pycrfsuite

print(sklearn.__version__)

train_sents = list(nltk.corpus.conll2002.iob_sents('esp.train'))
test_sents = list(nltk.corpus.conll2002.iob_sents('esp.testb'))

