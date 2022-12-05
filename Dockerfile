FROM python:3.6.1-alpine
RUN pip install --upgrade pip
WORKDIR /pythonwebapp
ADD . /pythonwebapp
RUN pip install -r requirements.txt
EXPOSE 80
CMD ["python", "app.py"]
