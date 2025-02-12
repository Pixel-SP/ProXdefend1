# Security Monitoring System

A comprehensive security monitoring system built for real-time threat detection, system monitoring, and security analytics.

## Features

- Real-time security event monitoring and analysis
- System performance monitoring (CPU, Memory, Disk usage)
- Security alerts and notifications
- Compliance monitoring and reporting
- Integration with ELK Stack for log analysis
- Advanced security analysis engine
- Interactive dashboard with real-time metrics
- Historical data analysis and reporting

## Tech Stack

- **Frontend**: JavaScript, CSS, React
- **Backend**: Python (Flask)
- **Database**: MongoDB
- **Log Analysis**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Security Analysis**: Custom Security Engine

## Prerequisites

- Python 3.8+
- Node.js 14+
- MongoDB 4.4+
- Elasticsearch 7.x
- Docker (optional, for containerization)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/security-monitoring-system.git
cd security-monitoring-system
```

2. Set up the backend:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Set up the frontend:
```bash
cd ../frontend
npm install
```

5. Start MongoDB:
```bash
# Make sure MongoDB is running on your system
mongod
```

6. Start Elasticsearch:
```bash
# Make sure Elasticsearch is running on your system
# Default URL: http://localhost:9200
```

## Running the Application

1. Start the backend server:
```bash
cd backend
python app.py
```

2. Start the frontend development server:
```bash
cd frontend
npm start
```

3. Access the application:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- API Documentation: http://localhost:5000/api/docs

## API Endpoints

### Security Events
- GET `/api/security-events` - Get all security events
- POST `/api/security-events` - Create a new security event

### System Monitoring
- GET `/api/system-status` - Get current system status
- GET `/api/alerts` - Get security alerts
- GET `/api/compliance` - Get compliance status
- GET `/api/analytics` - Get security analytics

## Testing

```bash
# Run backend tests
cd backend
pytest

# Run frontend tests
cd frontend
npm test
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built as a final year university project
- Special thanks to the open-source community
"# ProXdefend" 
