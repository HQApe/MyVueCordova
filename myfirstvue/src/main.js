import Vue from 'vue'
import App from './App.vue'

// import vConsole from './assets/js/vconsole'

import router from './router/router'
import store from './store/index'

new Vue({
  el:"#app",
  render:h=>h(App),
  router,
  store
}).$mount('#app')