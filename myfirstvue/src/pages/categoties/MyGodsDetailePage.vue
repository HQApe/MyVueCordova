<template>
    <div class="gods-detail">
        <my-navigation-bar :title="title" color="#f00" backgroud="#00f"></my-navigation-bar>
        <p class="my-params">{{$route.params.goodsId}}</p>
    </div>
</template>

<script>
import MyNavigationBar from '../../components/navbar/MyNavigationBar'

export default {
    name:'godsDetail',
    components:{MyNavigationBar},
    data () {
        return {
            title: "详情"
        }
    }
}
</script>

<style scoped>
.my-params {
    margin-top: 50px;
}
</style>