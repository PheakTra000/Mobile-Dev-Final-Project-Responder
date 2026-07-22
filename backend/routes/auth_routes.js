const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { getFirestore } = require('../firebase/firebase_config');

const router = express.Router();
const SALT_ROUNDS = 10;

function signToken(uid, email) {
  return jwt.sign({ uid, email }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
}

// POST /auth/register
router.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: 'password must be at least 6 characters' });
    }

    const db = getFirestore();
    const usersRef = db.collection('users');

    const existing = await usersRef.where('email', '==', email).limit(1).get();
    if (!existing.empty) {
      return res.status(409).json({ error: 'An account with this email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    const newUser = await usersRef.add({
      email,
      password: hashedPassword,
      createdAt: new Date().toISOString(),
    });

    const token = signToken(newUser.id, email);
    return res.status(201).json({ token, uid: newUser.id, email });
  } catch (err) {
    console.error('Register error:', err);
    return res.status(500).json({ error: 'Something went wrong during registration' });
  }
});

// POST /auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const db = getFirestore();
    const usersRef = db.collection('users');

    const snapshot = await usersRef.where('email', '==', email).limit(1).get();
    if (snapshot.empty) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    const passwordMatches = await bcrypt.compare(password, userData.password);
    if (!passwordMatches) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const token = signToken(userDoc.id, userData.email);
    return res.status(200).json({ token, uid: userDoc.id, email: userData.email });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ error: 'Something went wrong during login' });
  }
});

module.exports = router;
