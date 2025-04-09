const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');
const browserController = require('./browser/controller');

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Serve static files from UI directory
app.use(express.static(path.join(__dirname, 'ui/public')));
app.use(express.json());

// Serve main UI page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'ui/index.html'));
});

// Setup API routes
require('./api/routes')(app, browserController);

// Socket.io for real-time communication
io.on('connection', (socket) => {
  console.log('Client connected');
  
  // Handle browser screenshot events
  socket.on('takeScreenshot', async () => {
    try {
      const screenshot = await browserController.takeScreenshot();
      socket.emit('screenshot', { data: screenshot });
    } catch (error) {
      socket.emit('error', { message: error.message });
    }
  });
  
  // Handle page navigation
  socket.on('navigate', async (url) => {
    try {
      await browserController.navigateTo(url);
      socket.emit('navigated', { url });
    } catch (error) {
      socket.emit('error', { message: error.message });
    }
  });
  
  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// Initialize browser controller
browserController.init().catch(console.error);

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Handle shutdown gracefully
process.on('SIGTERM', async () => {
  console.log('Shutting down...');
  await browserController.close();
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});