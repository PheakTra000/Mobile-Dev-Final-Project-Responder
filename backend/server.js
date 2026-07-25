require('dotenv').config();
const { initFirebase } = require('./firebase/firebase_config');
const express = require('express');
const cors = require('cors');

initFirebase();

const authRoutes = require('./routes/auth_routes');
const scanRoutes = require('./routes/scan_routes');
const verifyToken = require('./middleware/auth_middleware');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ status: 'Responder backend is running' });
});

app.use('/auth', authRoutes);
app.use('/scans', verifyToken, scanRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Responder backend listening on port ${PORT}`);
});

module.exports = app;
