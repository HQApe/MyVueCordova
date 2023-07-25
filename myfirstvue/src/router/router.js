import VueRouter from 'vue-router'
import Vue from 'vue'

import MyHomePage from '../pages/home/MyHomePage'
import MyCategoriesPage from '../pages/categoties/MyCategoriesPage'
import MyShopPage from '../pages/shop/MyShopPage'
import MyProfilePage from '../pages/profile/MyProfilePage'
import MyGodsDetailePage from '../pages/categoties/MyGodsDetailePage'
import MyStudyPage from '../pages/mystudy/MyStudyPage'
import MyVuexPage from '../pages/mystudy/MyVuexPage'

Vue.use(VueRouter)

const routes = [
    { path: '/', redirect: '/home'},
    { path: '/home', name:'首页', component: MyHomePage},
    { path: '/categories', name:'分类', component: MyCategoriesPage},
    { path: '/shop', name:'购物车', component: MyShopPage},
    { path: '/me', name:'我的', component: MyProfilePage, children:[
        {
            path:'study',
            component:MyStudyPage
        },
        {
            path:'vuex',
            component:MyVuexPage
        }
    ]},
    { path: '/detail/:goodsId', name:'详情', component: MyGodsDetailePage}
]

const router = new VueRouter({
    routes // (缩写) 相当于 routes: routes
})

router.beforeEach((to, from, next)=>{
    document.title = to.name
    console.log('++++++')
    next()
})
router.afterEach((to, from)=>{
    console.log('------')
})

export default router