FROM python:2.7
EXPOSE 80
WORKDIR /code
ADD . /code
RUN touch index.html
ENV AWS_SECRET_KEY="1234q38rujfkasdfgws"
CMD python index.py
