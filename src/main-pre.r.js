// what the base Electron main needs
var electron = require('electron');
var path = require('path');
var url = require('url');
var windows = {};

// callbacks to initialize the first electron window
var createMainWindow = function createWindow() {
  var main = new electron.BrowserWindow({ 
    width: 800, 
    height: 600,
    show: false
  });

  main.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true
  }));

  main.on('closed', function () {
    delete windows['main'];
  });

  main.once('ready-to-show', function () {
    var menu = new electron.Menu();
    main.setMenuBarVisibility(false);
    main.setMenu(menu);
    main.show();
  });

  windows['main'] = main;
};

electron.app.on('ready', createMainWindow);

electron.app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') {
    electron.app.quit();
  }
});

electron.app.on('activate', function () {
  if (!('main' in Object.keys(windows))) {
    createMainWindow();
  }
});

