cordova.define("com.mysoft.container.container", function(require, exports, module) {
const CODE_CREATE = 0;
const CODE_DESTROY = 1;
const CODE_SHOW = 2;
const CODE_HIDE = 3;

let exec = require('cordova/exec');
let channel = require('cordova/channel');

// 宿主 API
let hostAPI = {
    create: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'create', [obj.id, obj.path, obj.config]);
    },

    destroy: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'destroy', [obj.id]);
    },

    show: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'show', [obj.id]);
    },

    hide: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'hide', [obj.id]);
    },

    getInfo: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'getInfo', [obj.ids]);
    },

    addEventListener: function (object) {
        let obj = object || {};
        let callback = function (ret) {
            let code = ret[0];
            let id = ret[1];
            switch (code) {
                case CODE_CREATE:
                    obj.onCreate && obj.onCreate(id);
                    break;
                case CODE_DESTROY:
                    obj.onDestroy && obj.onDestroy(id);
                    break;
                case CODE_SHOW:
                    obj.onShow && obj.onShow(id);
                    break;
                case CODE_HIDE:
                    obj.onHide && obj.onHide(id);
                    break;
                default:
                    obj.onFail && obj.onFail(id, ret[2]);
                    break;
            }
        }
        exec(callback, callback, 'container', 'addEventListener', []);
    },
};

// 容器 API
let containerAPI = {
    destroy: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'destroy', []);
    },

    show: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'show', []);
    },

    hide: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'hide', []);
    },

    getInfo: function (object) {
        let obj = object || {};
        exec(obj.success, obj.fail, 'container', 'getInfo', []);
    },

    addEventListener: function (object) {
        let obj = object || {};
        let callback = function (ret) {
            let code = ret[0];
            switch (code) {
                case CODE_SHOW:
                    obj.onShow && obj.onShow();
                    break;
                case CODE_HIDE:
                    obj.onHide && obj.onHide();
                    break;
                default:
                    obj.onFail && obj.onFail(ret[1]);
                    break;
            }
        }
        exec(callback, callback, 'container', 'addEventListener', []);
    },
}

channel.onCordovaReady.subscribe(function () {
    exec(
        function (isHost) {
            if (isHost != undefined) {
                window.container = isHost ? hostAPI : containerAPI;
            }
        },
        function (e) {
            console.log(e);
        },
        'container',
        'ready',
        []
    );
});
});
