import Vue from 'vue'
import App from './App.vue'

// import vConsole from './assets/js/vconsole'

import router from './router/router'

new Vue({
  render:h=>h(App),
  router,
}).$mount('#app')