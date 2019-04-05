import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

registerServiceWorker();

var app = Elm.Main.init({ node: document.getElementById('root'), flags: "" })
// you can use ports and stuff here

app.ports.fileSelected.subscribe(function (obj) {
  var node = document.getElementById(obj.id);
  if (node === null) {
    return;
  }
  var files = obj.event.dataTransfer.files
  var fileArray = [];
  for (var i = 0; i < files.length; i++) {
    (function (file) {
      if (file == null) { return; }
      var fileSize = ((file.size / 1024) / 1024).toFixed(4) || 0;
      var reader = new FileReader();
      if (fileSize < 3.5) {
        reader.onload = (function (event) {
          var base64Encoded = event.target.result;
          var portData = {
            contents: base64Encoded,
            fileName: file.name,
            id: obj.id,
            totalFiles: files.length
          };
          fileArray.push(portData)
          if (file == files[files.length - 1]) { app.ports.fileContentRead.send(fileArray); };
        });

      } else {
        reader.onload = (function (event) {
          var portData = {
            contents: "",
            fileName: "Too Big",
            id: obj.id,
            totalFiles: files.length
          };
          fileArray.push(portData)
          if (file == files[files.length - 1]) { app.ports.fileContentRead.send(fileArray); };

        });
      }


      reader.readAsDataURL(file)
    })(files[i])
  }
  fileArray = [];
  // reader.readAsBinaryString(file)
});