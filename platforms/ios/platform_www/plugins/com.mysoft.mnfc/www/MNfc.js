cordova.define("com.mysoft.mnfc.MNfc", function(require, exports, module) {
var exec = require('cordova/exec');
function MNfc() {
}

MNfc.prototype.success = function (options) {
    return function (result) {
        // onStart 0
        // onScan 1
        // onClose 2
        // onError 3
        if (options == null) {
            return;
        }

        var code = result[0];
        switch (code) {
            case 0:
                if (options.onStart != undefined && options.onStart != null) {
                    options.onStart();
                }
                break;
            case 1: {
                if (options.onScan != undefined && options.onScan != null) {
                    var data = result[1];
                    options.onScan(data);
                }
            }
                break;
            case 2: {
                if (options.onClose != undefined && options.onClose != null) {
                    options.onClose();
                }
            }
                break;
            case 3: {
                if (options.onError != undefined && options.onError != null) {
                    var err = result[1];
                    options.onError(err);
                }
            }
                break;
            default:
                if (options.onError != undefined && options.onError != null) {
                    options.onError(result);
                }
                break;
        }
    };
};

MNfc.prototype.startScan = function (options) {
    exec(this.success(options), this.success(options), 'MNfc', 'startScan', []);
};

MNfc.prototype.cancelScan = function (succeed, error) {
    exec(succeed, error, 'MNfc', 'cancelScan', []);
};

MNfc.prototype.isSupportNFC = function (succeed) {
    exec(succeed, null, 'MNfc', 'isSupportNFC', []);
};
module.exports = new MNfc();

});
