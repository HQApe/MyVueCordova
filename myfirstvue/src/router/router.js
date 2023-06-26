import VueRouter from 'vue-router'
import Vue from 'vue'

import MyHomePage from '../pages/home/MyHomePage'
import MyCategoriesPage from '../pages/categoties/MyCategoriesPage'
import MyShopPage from '../pages/shop/MyShopPage'
import MyProfilePage from '../pages/profile/MyProfilePage'

Vue.use(VueRouter)

const routes = [
    { path: '/', redirect: '/home'},
    { path: '/home', component: MyHomePage},
    { path: '/categories', component: MyCategoriesPage},
    { path: '/shop', component: MyShopPage},
    { path:'/me', component: MyProfilePage}
]

const router = new VueRouter({
    routes // (缩写) 相当于 routes: routes
})

export default router