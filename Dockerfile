FROM python:3.9
COPY requirements.txt ./requirements.txt
RUN pip install -r requirements.txt
COPY . ./
EXPOSE 80
CMD gunicorn -b 0.0.0.0:80 app:server