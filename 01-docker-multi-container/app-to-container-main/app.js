const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Rota de teste
app.get('/', (req, res) => {
    res.json({
        message: 'API Node.js em Contêiner está funcionando!',
        environment: process.env.NODE_ENV || 'development',
        container: {
            id: process.env.HOSTNAME,
            ip: process.env.HOST_IP
        }
    });
});

// Rota de health check
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString()
    });
});

// Rota para testar o ambiente
app.get('/env', (req, res) => {
    res.json({
        env: process.env
    });
});

// Iniciar o servidor
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
