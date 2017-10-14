# sudo docker run -it --rm -e PYTHONPATH=python -v ~/workspace/nlp_ex:/root/workspace/nlp_ex -v /opt/nltk_data:/root/nltk_data zatonovo/numpy:3.5 bash
from nltk.corpus import wordnet as wn
from nltk.corpus import stopwords
from nltk.tokenize import RegexpTokenizer
from functools import reduce

tokenizer = RegexpTokenizer(r'\w+')
stopset = set(stopwords.words("english"))

def tokenize(sent):
  return set([ tk.lower() for tk in tokenizer.tokenize(sent)]) - stopset

def simple_lesk(w, sent):
  #import pdb; pdb.set_trace()
  w = wn.morphy(w)
  ss = wn.synsets(w)
  context = tokenize(sent)

  def fn(acc, idx):
    signature = reduce(lambda a,x: a | tokenize(x), 
      ss[idx].examples(), tokenize(ss[idx].definition()))
    ol = len(context & signature)
    if ol > acc[1]: acc = (idx,ol)
    return acc
    
  (idx,overlap) = reduce(fn, range(len(ss)), (0,0))
  return ss[idx]
