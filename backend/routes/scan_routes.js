const express = require('express');
const { getFirestore } = require('../firebase/firebase_config');

const router = express.Router();

// POST /scans  - save a completed scan session
router.post('/', async (req, res) => {
  try {
    const { profileName, scanType, deviceCount, devices } = req.body;

    if (!profileName || !scanType) {
      return res.status(400).json({ error: 'profileName and scanType are required' });
    }

    const db = getFirestore();
    const scansRef = db.collection('scans');

    const newSession = {
      userId: req.user.uid,
      profileName,
      scanType, // "Quick" or "Deep"
      deviceCount: deviceCount ?? (devices ? devices.length : 0),
      devices: devices || [], // [{ ip, mac, hostname, ports: [{ port, serviceType, riskLevel }] }]
      date: new Date().toISOString(),
    };

    const docRef = await scansRef.add(newSession);
    return res.status(201).json({ id: docRef.id, ...newSession });
  } catch (err) {
    console.error('Create scan error:', err);
    return res.status(500).json({ error: 'Failed to save scan session' });
  }
});

// GET /scans - list this user's scan history
router.get('/', async (req, res) => {
  try {
    const db = getFirestore();
    const snapshot = await db
      .collection('scans')
      .where('userId', '==', req.user.uid)
      .orderBy('date', 'desc')
      .get();

    const sessions = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(sessions);
  } catch (err) {
    console.error('Fetch scans error:', err);
    return res.status(500).json({ error: 'Failed to fetch scan history' });
  }
});

// GET /scans/:id - detail for a single session (device list + ports)
router.get('/:id', async (req, res) => {
  try {
    const db = getFirestore();
    const docRef = db.collection('scans').doc(req.params.id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Scan session not found' });
    }
    if (doc.data().userId !== req.user.uid) {
      return res.status(403).json({ error: 'Not authorized to view this session' });
    }

    return res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (err) {
    console.error('Fetch scan detail error:', err);
    return res.status(500).json({ error: 'Failed to fetch scan detail' });
  }
});

// PUT /scans/:id - rename a session's profile name
router.put('/:id', async (req, res) => {
  try {
    const { profileName } = req.body;
    if (!profileName) {
      return res.status(400).json({ error: 'profileName is required' });
    }

    const db = getFirestore();
    const docRef = db.collection('scans').doc(req.params.id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Scan session not found' });
    }
    if (doc.data().userId !== req.user.uid) {
      return res.status(403).json({ error: 'Not authorized to modify this session' });
    }

    await docRef.update({ profileName });
    return res.status(200).json({ id: doc.id, ...doc.data(), profileName });
  } catch (err) {
    console.error('Update scan error:', err);
    return res.status(500).json({ error: 'Failed to update scan session' });
  }
});

// DELETE /scans/:id - remove a session from history
router.delete('/:id', async (req, res) => {
  try {
    const db = getFirestore();
    const docRef = db.collection('scans').doc(req.params.id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Scan session not found' });
    }
    if (doc.data().userId !== req.user.uid) {
      return res.status(403).json({ error: 'Not authorized to delete this session' });
    }

    await docRef.delete();
    return res.status(200).json({ message: 'Scan session deleted' });
  } catch (err) {
    console.error('Delete scan error:', err);
    return res.status(500).json({ error: 'Failed to delete scan session' });
  }
});

module.exports = router;
