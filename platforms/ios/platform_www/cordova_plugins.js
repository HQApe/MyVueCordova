cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "com.mysoft.mnfc.MNfc",
      "file": "plugins/com.mysoft.mnfc/www/MNfc.js",
      "pluginId": "com.mysoft.mnfc",
      "clobbers": [
        "MNfc"
      ]
    },
    {
      "id": "com.mysoft.container.container",
      "file": "plugins/com.mysoft.container/www/container.js",
      "pluginId": "com.mysoft.container",
      "clobbers": [
        "container"
      ],
      "runs": true
    }
  ];
  module.exports.metadata = {
    "com.mysoft.mnfc": "1.0.3",
    "com.mysoft.container": "1.1.0"
  };
});