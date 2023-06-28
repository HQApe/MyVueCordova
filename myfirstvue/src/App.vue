<template>
  
  <div id="app">
    <router-view></router-view>
    <my-tab-bar>
      <my-tab-bar-item v-for="(tab, index) in tabBarList" :key="index" :path="tab.path">
        <img slot="item-icon" :src="tab.image_n" alt=""/>
        <img slot="item-icon-active" :src="tab.image_s" alt=""/>
        <div slot="item-text" activeColor="#FF999999">{{ tab.title }}</div>
      </my-tab-bar-item>
    </my-tab-bar>
  </div>
</template>

<script>
import MyTabBar from './components/tabbar/MyTabBar.vue'
import MyTabBarItem from './components/tabbar/MyTabBarItem.vue'
export default {
  name: 'app',
  components: {MyTabBar, MyTabBarItem},
  data () {
    return {
      tabBarList:[
        {
          path: '/home',
          title:'首页',
          image_n:require('./assets/images/icon-tab-home-n.png'),
          image_s:require('./assets/images/icon-tab-home-s.png'),
          activeColor:'#FF999999'
        },
        {
          path: '/categories',
          title:'分类',
          image_n:require('./assets/images/icon-tab-found-n.png'),
          image_s:require('./assets/images/icon-tab-found-s.png'),
          activeColor:''
        },
        {
          path: '/shop',
          title:'购物车',
          image_n:require('./assets/images/icon-tab-shop-n.png'),
          image_s:require('./assets/images/icon-tab-shop-s.png'),
          activeColor:''
        },
        {
          path: '/me',
          title:'首页',
          image_n:require('./assets/images/icon-tab-profile-n.png'),
          image_s:require('./assets/images/icon-tab-profile-s.png'),
          activeColor:''
        }
      ]
    }
  }
}
</script>

<style scoped>
@import url('./assets/base.css');

</style>
