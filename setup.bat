@echo off
echo Setting up ProXDefend Security Monitoring System...

:: Create Python virtual environment
echo Creating Python virtual environment...
python -m venv venv
call venv\Scripts\activate.bat

:: Install backend dependencies
echo Installing backend dependencies...
cd backend
pip install -r requirements.txt

:: Initialize database
echo Initializing database...
python scripts\init_db.py

:: Install frontend dependencies
echo Installing frontend dependencies...
cd ..\frontend
call npm install

:: Create necessary directories
echo Creating system directories...
mkdir logs
mkdir data

:: Set up environment variables
echo Setting up environment variables...
if not exist backend\.env (
    copy backend\.env.example backend\.env
)
if not exist frontend\.env (
    copy frontend\.env.example frontend\.env
)

echo Setup completed successfully!
echo To start the system:
echo 1. Start MongoDB service
echo 2. Start Elasticsearch and Logstash (if using ELK stack)
echo 3. Start backend: cd backend ^& python app.py
echo 4. Start frontend: cd frontend ^& npm start

pause
