const express = require('express');
const cors = require('cors');
const path = require('path');
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'skycheck-super-secret-2024';

app.use(cors());
app.use(express.json());
// Serve the web folder as static files
app.use(express.static(path.join(__dirname, '../web')));

// ─────────────────────────────────────────────
// MIDDLEWARE
// ─────────────────────────────────────────────
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Токен не найден' });
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Недействительный токен' });
  }
};

const adminMiddleware = (req, res, next) => {
  authMiddleware(req, res, () => {
    if (req.user.role !== 'admin') return res.status(403).json({ error: 'Только для администраторов' });
    next();
  });
};

// ─────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────
app.post('/auth/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    if (!email || !password || !name) return res.status(400).json({ error: 'Все поля обязательны' });
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: { email, password: hashedPassword, name, role: 'user' },
    });
    const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user.id, name: user.name, email: user.email, role: user.role } });
  } catch (e) {
    if (e.code === 'P2002') return res.status(400).json({ error: 'Email уже используется' });
    res.status(500).json({ error: e.message });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return res.status(401).json({ error: 'Пользователь не найден' });
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) return res.status(401).json({ error: 'Неверный пароль' });
    const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user.id, name: user.name, email: user.email, role: user.role } });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/auth/me', authMiddleware, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: { id: true, email: true, name: true, role: true, createdAt: true },
    });
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─────────────────────────────────────────────
// ZONES
// ─────────────────────────────────────────────
app.get('/zones', async (req, res) => {
  try {
    const zones = await prisma.zone.findMany();
    res.json(zones);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/zones', adminMiddleware, async (req, res) => {
  try {
    const { name, type, coordinates, maxAltitude } = req.body;
    const zone = await prisma.zone.create({ data: { name, type, coordinates, maxAltitude: parseInt(maxAltitude) } });
    res.json(zone);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/zones/:id', adminMiddleware, async (req, res) => {
  try {
    const { name, type, coordinates, maxAltitude } = req.body;
    const zone = await prisma.zone.update({
      where: { id: parseInt(req.params.id) },
      data: { name, type, coordinates, maxAltitude: parseInt(maxAltitude) },
    });
    res.json(zone);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/zones/:id', adminMiddleware, async (req, res) => {
  try {
    await prisma.zone.delete({ where: { id: parseInt(req.params.id) } });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─────────────────────────────────────────────
// NEWS
// ─────────────────────────────────────────────
app.get('/news', async (req, res) => {
  try {
    const news = await prisma.news.findMany({ orderBy: { publishedAt: 'desc' } });
    res.json(news);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/news/:id', async (req, res) => {
  try {
    const item = await prisma.news.findUnique({ where: { id: parseInt(req.params.id) } });
    if (!item) return res.status(404).json({ error: 'Не найдено' });
    res.json(item);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/news', adminMiddleware, async (req, res) => {
  try {
    const { title, content, imageUrl, author } = req.body;
    const item = await prisma.news.create({ data: { title, content, imageUrl, author } });
    res.json(item);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/news/:id', adminMiddleware, async (req, res) => {
  try {
    const { title, content, imageUrl, author } = req.body;
    const item = await prisma.news.update({
      where: { id: parseInt(req.params.id) },
      data: { title, content, imageUrl, author },
    });
    res.json(item);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/news/:id', adminMiddleware, async (req, res) => {
  try {
    await prisma.news.delete({ where: { id: parseInt(req.params.id) } });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─────────────────────────────────────────────
// COURSES
// ─────────────────────────────────────────────
app.get('/courses', async (req, res) => {
  try {
    const courses = await prisma.course.findMany({
      include: { steps: { orderBy: { order: 'asc' } } },
      orderBy: { id: 'asc' },
    });
    res.json(courses);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/courses/:id', async (req, res) => {
  try {
    const course = await prisma.course.findUnique({
      where: { id: parseInt(req.params.id) },
      include: { steps: { orderBy: { order: 'asc' } } },
    });
    if (!course) return res.status(404).json({ error: 'Не найдено' });
    res.json(course);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/courses', adminMiddleware, async (req, res) => {
  try {
    const { title, description, iconType, color } = req.body;
    const course = await prisma.course.create({ data: { title, description, iconType, color } });
    res.json(course);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/courses/:id', adminMiddleware, async (req, res) => {
  try {
    const { title, description, iconType, color } = req.body;
    const course = await prisma.course.update({
      where: { id: parseInt(req.params.id) },
      data: { title, description, iconType, color },
    });
    res.json(course);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/courses/:id', adminMiddleware, async (req, res) => {
  try {
    await prisma.course.delete({ where: { id: parseInt(req.params.id) } });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Course Steps
app.post('/courses/:id/steps', adminMiddleware, async (req, res) => {
  try {
    const { type, title, content, questions, order } = req.body;
    const step = await prisma.courseStep.create({
      data: { courseId: parseInt(req.params.id), type, title, content, questions, order: parseInt(order) },
    });
    res.json(step);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/courses/:courseId/steps/:stepId', adminMiddleware, async (req, res) => {
  try {
    const { type, title, content, questions, order } = req.body;
    const step = await prisma.courseStep.update({
      where: { id: parseInt(req.params.stepId) },
      data: { type, title, content, questions, order: parseInt(order) },
    });
    res.json(step);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/courses/:courseId/steps/:stepId', adminMiddleware, async (req, res) => {
  try {
    await prisma.courseStep.delete({ where: { id: parseInt(req.params.stepId) } });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─────────────────────────────────────────────
// ADMIN — USERS & STATS
// ─────────────────────────────────────────────
app.get('/admin/users', adminMiddleware, async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      select: { id: true, email: true, name: true, role: true, createdAt: true },
      orderBy: { createdAt: 'desc' },
    });
    res.json(users);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put('/admin/users/:id/role', adminMiddleware, async (req, res) => {
  try {
    const { role } = req.body;
    const user = await prisma.user.update({
      where: { id: parseInt(req.params.id) },
      data: { role },
      select: { id: true, email: true, name: true, role: true, createdAt: true },
    });
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/admin/users/:id', adminMiddleware, async (req, res) => {
  try {
    await prisma.user.delete({ where: { id: parseInt(req.params.id) } });
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/admin/stats', adminMiddleware, async (req, res) => {
  try {
    const [users, news, courses, zones] = await Promise.all([
      prisma.user.count(),
      prisma.news.count(),
      prisma.course.count(),
      prisma.zone.count(),
    ]);
    res.json({ users, news, courses, zones });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// SPA fallback — admin
app.get('/admin/*', (req, res) => {
  res.sendFile(path.join(__dirname, '../web/admin/index.html'));
});

// SPA fallback — public
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../web/index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ SkyCheck Backend запущен на порту ${PORT}`);
  console.log(`🌐 Публичный сайт: http://localhost:${PORT}`);
  console.log(`🔐 Admin панель:  http://localhost:${PORT}/admin`);
});