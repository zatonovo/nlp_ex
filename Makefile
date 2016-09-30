PYTHON?=python
.PHONY: all run bash python
HOST_DIR = ~/workspace/nlp_ex
IMAGE_NAME = zatonovo/nlpx


all:
	docker build -t ${IMAGE_NAME} .

bash:
	docker run -it --rm -v ${HOST_DIR}:/code ${IMAGE_NAME} bash

python:
	docker run -it --rm -v ${HOST_DIR}:/code ${IMAGE_NAME} python
