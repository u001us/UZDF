const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.send('SkyCheck Backend is running!');
});

// Пример эндпоинта для получения зон
app.get('/zones', async (req, res) => {
    try {
        const zones = await prisma.zone.findMany();
        res.json(zones);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Backend running on port ${PORT}`);
});