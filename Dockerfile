FROM python:3.12-alpine
WORKDIR /app
COPY . /app
EXPOSE 3000
CMD ["python3", "-m", "http.server", "3000"]
