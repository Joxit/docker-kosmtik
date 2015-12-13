# docker-kosmtik
Light docker for ksomtik https://github.com/kosmtik/kosmtik

# Build
```sh
docker build -t kosmtik .
```

# Run
```sh
docker run -d -p 6789:6789 kosmtik node index.js serve
```