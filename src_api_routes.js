module.exports = function(app, browserController) {
  // Get browser status
  app.get('/api/status', async (req, res) => {
    try {
      const status = browserController.browser ? 'running' : 'not running';
      res.json({ status });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  // Navigate to URL
  app.post('/api/navigate', async (req, res) => {
    try {
      const { url } = req.body;
      if (!url) {
        return res.status(400).json({ error: 'URL is required' });
      }
      
      await browserController.navigateTo(url);
      res.json({ success: true, url });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  // Take screenshot
  app.get('/api/screenshot', async (req, res) => {
    try {
      const screenshot = await browserController.takeScreenshot();
      res.send(Buffer.from(screenshot, 'base64'));
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  // Execute script in the browser
  app.post('/api/execute', async (req, res) => {
    try {
      const { script } = req.body;
      if (!script) {
        return res.status(400).json({ error: 'Script is required' });
      }
      
      const result = await browserController.executeScript(script);
      res.json({ success: true, result });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  // Restart browser
  app.post('/api/restart', async (req, res) => {
    try {
      await browserController.close();
      await browserController.init();
      res.json({ success: true });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
};