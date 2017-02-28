#include <emscripten.h>

void loop() {
}

// callbacks to initialize the first electron window
void electron_create_window()
{
EM_ASM(
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
      delete windows['0'];
    });
    main.once('ready-to-show', function () {
      var menu = new electron.Menu();
      main.setMenuBarVisibility(false);
      main.setMenu(menu);
      main.webContents.openDevTools();
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
);
}

int main(int argc, char* argv[])
{
  // Javascript preamble stuff (i.e., globals and modules)
  // are loaded in main-pre.js
  electron_create_window();

  emscripten_set_main_loop(loop, 60, 1);
}
