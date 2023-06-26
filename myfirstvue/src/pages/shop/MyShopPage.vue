<template>
    <div class="page-shop">
        <my-navigation-bar :title="title" color="#f00" backgroud="#00f"></my-navigation-bar>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'shopPage',
    components:{MyNavigationBar},
    data () {
        return {
            title: "购物车"
        }
    }
}
</script>