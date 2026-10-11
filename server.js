// =============================================
// server.js — Local Test Server
// Run: node server.js
// Open: http://localhost:3000
// =============================================

const express = require('express')
const path    = require('path')
const app     = express()
const PORT    = 3000

// Serve all static files (html, css, js) from current folder
app.use(express.static(path.join(__dirname)))

// Default route → login page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'login.html'))
})

// Fallback for any unknown route
app.use((req, res) => {
  res.status(404).sendFile(path.join(__dirname, 'login.html'))
})

app.listen(PORT, () => {
  console.log('=============================================')
  console.log(' Smart Attendance System - Local Server')
  console.log('=============================================')
  console.log(` Server running at: http://localhost:${PORT}`)
  console.log('')
  console.log(' Pages:')
  console.log(` Login             → http://localhost:${PORT}/login.html`)
  console.log(` Student Dashboard → http://localhost:${PORT}/student-dashboard.html`)
  console.log(` Scan QR           → http://localhost:${PORT}/scan-qr.html`)
  console.log(` Teacher Dashboard → http://localhost:${PORT}/teacher-dashboard.html`)
  console.log(` Generate QR       → http://localhost:${PORT}/generate-qr.html`)
  console.log(` Attendance Report → http://localhost:${PORT}/attendance-report.html`)
  console.log(` Admin Dashboard   → http://localhost:${PORT}/admin-dashboard.html`)
  console.log(` Manage Users      → http://localhost:${PORT}/manage-users.html`)
  console.log('=============================================')
  console.log(' Press Ctrl+C to stop the server')
  console.log('=============================================')
})
