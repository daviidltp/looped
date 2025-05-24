# Usar una imagen base de Python
FROM python:3.11-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Instalar las dependencias del sistema necesarias para psycopg2 y otras
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    # netcat-traditional ya no es estrictamente necesario aquí si docker-compose lo maneja
    && rm -rf /var/lib/apt/lists/*

# Copiar los archivos de requisitos primero para aprovechar la caché de Docker
COPY requirements.txt .

# Instalar las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el archivo de configuración principal
COPY config.py .

# Copiar el paquete src (donde reside tu aplicación Flask)
COPY src/ src/

# Copia la carpeta instance si es necesario (para db.sqlite en desarrollo si lo usas ahí)
# Si tu .env está en la raíz y lo carga docker-compose, no necesitas copiar .env aquí.
# COPY instance/ instance/

# Expone el puerto en el que se ejecutará la aplicación
EXPOSE 5000

# Variables de entorno para Flask
ENV FLASK_APP=src
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=development 
ENV PYTHONUNBUFFERED=1

# Comando para correr la aplicación usando Flask CLI
CMD ["flask", "run"] 